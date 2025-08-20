// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module locked_stake::locked_stake;

use locked_stake::epoch_time_lock::{Self, EpochTimeLock};
use one::balance::{Self, Balance};
use one::coin;
use one::oct::OCT;
use one::vec_map::{Self, VecMap};
use one_system::staking_pool::StakedOct;
use one_system::one_system::{Self, SuiSystemState};

const EInsufficientBalance: u64 = 0;
const EStakeObjectNonExistent: u64 = 1;

/// An object that locks SUI tokens and stake objects until a given epoch, and allows
/// staking and unstaking operations when locked.
public struct LockedStake has key {
    id: UID,
    staked_oct: VecMap<ID, StakedOct>,
    sui: Balance<OCT>,
    locked_until_epoch: EpochTimeLock,
}

// ============================= basic operations =============================

/// Create a new LockedStake object with empty staked_oct and sui balance given a lock time.
/// Aborts if the given epoch has already passed.
public fun new(locked_until_epoch: u64, ctx: &mut TxContext): LockedStake {
    LockedStake {
        id: object::new(ctx),
        staked_oct: vec_map::empty(),
        sui: balance::zero(),
        locked_until_epoch: epoch_time_lock::new(locked_until_epoch, ctx),
    }
}

/// Unlocks and returns all the assets stored inside this LockedStake object.
/// Aborts if the unlock epoch is in the future.
public fun unlock(ls: LockedStake, ctx: &TxContext): (VecMap<ID, StakedOct>, Balance<OCT>) {
    let LockedStake { id, staked_oct, sui, locked_until_epoch } = ls;
    epoch_time_lock::destroy(locked_until_epoch, ctx);
    object::delete(id);
    (staked_oct, sui)
}

/// Deposit a new stake object to the LockedStake object.
public fun deposit_staked_oct(ls: &mut LockedStake, staked_oct: StakedOct) {
    let id = object::id(&staked_oct);
    // This insertion can't abort since each object has a unique id.
    vec_map::insert(&mut ls.staked_oct, id, staked_oct);
}

/// Deposit sui balance to the LockedStake object.
public fun deposit_sui(ls: &mut LockedStake, sui: Balance<OCT>) {
    balance::join(&mut ls.sui, sui);
}

/// Take `amount` of SUI from the sui balance, stakes it, and puts the stake object
/// back into the staked sui vec map.
public fun stake(
    ls: &mut LockedStake,
    sui_system: &mut SuiSystemState,
    amount: u64,
    validator_address: address,
    ctx: &mut TxContext,
) {
    assert!(balance::value(&ls.sui) >= amount, EInsufficientBalance);
    let stake = one_system::request_add_stake_non_entry(
        sui_system,
        coin::from_balance(balance::split(&mut ls.sui, amount), ctx),
        validator_address,
        ctx,
    );
    deposit_staked_oct(ls, stake);
}

/// Unstake the stake object with `staked_oct_id` and puts the resulting principal
/// and rewards back into the locked sui balance.
/// Returns the amount of SUI unstaked, including both principal and rewards.
/// Aborts if no stake exists with the given id.
public fun unstake(
    ls: &mut LockedStake,
    sui_system: &mut SuiSystemState,
    staked_oct_id: ID,
    ctx: &mut TxContext,
): u64 {
    assert!(vec_map::contains(&ls.staked_oct, &staked_oct_id), EStakeObjectNonExistent);
    let (_, stake) = vec_map::remove(&mut ls.staked_oct, &staked_oct_id);
    let (sui_balance, coin_vesting) = one_system::request_withdraw_stake_non_entry(sui_system, stake, ctx);
    if(coin_vesting.is_some()){
        transfer::public_transfer(coin_vesting.destroy_some(),ctx.sender());
    }else {
        coin_vesting.destroy_none();
    };
    let amount = balance::value(&sui_balance);
    deposit_sui(ls, sui_balance);
    amount
}

// ============================= getters =============================

public fun staked_oct(ls: &LockedStake): &VecMap<ID, StakedOct> {
    &ls.staked_oct
}

public fun sui_balance(ls: &LockedStake): u64 {
    balance::value(&ls.sui)
}

public fun locked_until_epoch(ls: &LockedStake): u64 {
    epoch_time_lock::epoch(&ls.locked_until_epoch)
}

// TODO: possibly add some scenarios like switching stake, creating a new LockedStake and transferring
// it to the sender, etc. But these can also be done as PTBs.

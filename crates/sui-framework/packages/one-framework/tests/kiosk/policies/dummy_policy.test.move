// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

#[test_only]
/// Dummy policy which showcases all of the methods.
module one::dummy_policy;

use one::coin::Coin;
use one::oct::OCT;
use one::transfer_policy::{Self as policy, TransferPolicy, TransferPolicyCap, TransferRequest};

public struct Rule has drop {}
public struct Config has drop, store {}

public fun set<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
    policy::add_rule(Rule {}, policy, cap, Config {})
}

public fun pay<T>(
    policy: &mut TransferPolicy<T>,
    request: &mut TransferRequest<T>,
    payment: Coin<OCT>,
) {
    policy::add_to_balance(Rule {}, policy, payment);
    policy::add_receipt(Rule {}, request);
}

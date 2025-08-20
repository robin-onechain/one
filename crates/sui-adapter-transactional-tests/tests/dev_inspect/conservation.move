// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// conservation checks disabled for dev inspect

//# init --addresses test=0x0 --accounts A B

//# publish

module test::m {
    use one::oct::OCT;
    use one::coin::Coin;

    public fun transfer_back(c: Coin<OCT>, ctx: &mut TxContext) {
        one::transfer::public_transfer(c, tx_context::sender(ctx))
    }
}

//# programmable --sender A --inputs struct(@empty,1) --dev-inspect
//> 0: test::m::transfer_back(Input(0));

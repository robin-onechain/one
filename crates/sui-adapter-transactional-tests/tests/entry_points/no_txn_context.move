// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

//# init --addresses Test=0x0 --accounts A

//# publish
module Test::M {
    public struct Obj has key {
        id: one::object::UID,
        value: u64
    }

    public entry fun mint(ctx: &mut TxContext) {
        one::transfer::transfer(
            Obj { id: one::object::new(ctx), value: 0 },
            tx_context::sender(ctx),
        )
    }

    public entry fun incr(obj: &mut Obj) {
        obj.value = obj.value + 1
    }
}

//# run Test::M::mint --sender A

//# run Test::M::incr --sender A --args object(2,0)

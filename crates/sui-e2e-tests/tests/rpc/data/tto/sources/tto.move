// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module tto::M1 {
    use one::coin::Coin;
    use one::oct::OCT;
    use one::object::{Self, UID};
    use one::tx_context::{Self, TxContext};
    use one::transfer::{Self, Receiving};

    public struct A has key, store {
        id: UID,
    }

    public fun start(coin: Coin<OCT>, ctx: &mut TxContext) {
        let a = A { id: object::new(ctx) };
        let a_address = object::id_address(&a);

        transfer::public_transfer(a, tx_context::sender(ctx));
        transfer::public_transfer(coin, a_address);
    }

    public entry fun receive(parent: &mut A, x: Receiving<Coin<OCT>>) {
        let coin = transfer::public_receive(&mut parent.id, x);
        transfer::public_transfer(coin, @tto);
    }
}

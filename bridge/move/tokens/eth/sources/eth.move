// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module bridged_eth::eth {
    use std::option;

    use one::coin;
    use one::transfer;
    use one::tx_context;
    use one::tx_context::TxContext;

    struct ETH has drop {}

    const DECIMAL: u8 = 8;

    fun init(otw: ETH, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            otw,
            DECIMAL,
            b"ETH",
            b"Ethereum",
            b"Bridged Ethereum token",
            option::none(),
            ctx
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx))
    }
}

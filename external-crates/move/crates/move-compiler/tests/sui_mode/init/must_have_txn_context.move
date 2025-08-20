// must have TxContext
module a::m {
    fun init() {
        abort 0
    }
}

// cannot have mroe than one TxContext
module a::n {
    use one::tx_context;
    fun init(_ctx: &mut tx_context::TxContext, _ctx2: &mut tx_context::TxContext) {
        abort 0
    }
}

module one::tx_context {
    struct TxContext has drop {}
}

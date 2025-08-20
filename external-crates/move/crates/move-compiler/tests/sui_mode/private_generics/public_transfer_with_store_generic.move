// tests modules can use transfer functions outside of the defining module, if the type
// has store.

module a::m {
    use one::transfer::{Self, Receiving};
    use a::other;
    use one::object::UID;

    public fun t<T: store>(s: other::S<T>) {
        transfer::public_transfer(s, @0x100)
    }
    public fun t_gen<T: key + store>(s: T) {
        transfer::public_transfer(s, @0x100)
    }

    public fun f<T: store>(s: other::S<T>) {
        transfer::public_freeze_object(s)
    }
    public fun f_gen<T: key + store>(s: T) {
        transfer::public_freeze_object(s)
    }

    public fun s<T: store>(s: other::S<T>) {
        transfer::public_share_object(s)
    }
    public fun s_gen<T: key + store>(s: T) {
        transfer::public_share_object(s)
    }

    public fun r<T: store>(p: &mut UID, s: Receiving<other::S<T>>): other::S<T> {
        transfer::public_receive(p, s)
    }

    public fun r_gen<T: key + store>(p: &mut UID, s: Receiving<T>): T {
        transfer::public_receive(p, s)
    }

    public fun m<T: store>(s: other::S<T>, p: one::party::Party) {
        transfer::public_party_transfer(s, p)
    }
    public fun m_gen<T: key + store>(s: T, p: one::party::Party) {
        transfer::public_party_transfer(s, p)
    }
}

module a::other {
    struct S<T> has key, store {
        id: one::object::UID,
        value: T,
    }
}

module one::object {
    struct UID has store {
        id: address,
    }
}

module one::transfer {
    use one::object::UID;

    struct Receiving<phantom T: key> { }

    public fun transfer<T: key>(_: T, _: address) {
        abort 0
    }

    public fun public_transfer<T: key + store>(_: T, _: address) {
        abort 0
    }

    public fun party_transfer<T: key>(_: T, _: one::party::Party) {
        abort 0
    }

    public fun public_party_transfer<T: key + store>(_: T, _: one::party::Party) {
        abort 0
    }

    public fun freeze_object<T: key>(_: T) {
        abort 0
    }

    public fun public_freeze_object<T: key + store>(_: T) {
        abort 0
    }

    public fun share_object<T: key>(_: T) {
        abort 0
    }

    public fun public_share_object<T: key + store>(_: T) {
        abort 0
    }

    public fun receive<T: key>(_: &mut UID, _: Receiving<T>): T {
        abort 0
    }

    public fun public_receive<T: key + store>(_: &mut UID, _: Receiving<T>): T {
        abort 0
    }
}

module one::party {
    struct Party has copy, drop {}
}

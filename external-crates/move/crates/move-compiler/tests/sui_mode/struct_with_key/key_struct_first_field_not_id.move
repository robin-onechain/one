// invalid, first field of an object must be one::object::UID
module a::m {
    struct S has key {
        flag: bool
    }
}

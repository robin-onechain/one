// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module basics::clock;

use one::clock::Clock;
use one::event;

public struct TimeEvent has copy, drop, store {
    timestamp_ms: u64,
}

entry fun access(clock: &Clock) {
    event::emit(TimeEvent { timestamp_ms: clock.timestamp_ms() });
}

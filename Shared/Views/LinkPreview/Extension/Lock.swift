//
//  Lock.swift
//  URLEmbeddedView
//
//  Created by marty-suzuki on 2018/07/15.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

final class Lock: NSLocking {

    @available(iOS 10.0, tvOS 10.0, *)
    private final class _OSUnfairLock: NSLocking {
        private var _lock = os_unfair_lock()

        func lock() {
            os_unfair_lock_lock(&_lock)
        }

        func unlock() {
            os_unfair_lock_unlock(&_lock)
        }
    }

    @available(iOS, deprecated: 10.0)
    @available(tvOS, deprecated: 10.0)
    private final class _OSSpinLock: NSLocking {
        private var _lock = OS_SPINLOCK_INIT

        func lock() {
            OSSpinLockLock(&_lock)
        }

        func unlock() {
            OSSpinLockUnlock(&_lock)
        }
    }

    private let _lock: NSLocking = {
        if #available(iOS 10.0, tvOS 10.0, *) {
            return _OSUnfairLock()
        } else {
            return _OSSpinLock()
        }
    }()

    func lock() {
        _lock.lock()
    }

    func unlock() {
        _lock.unlock()
    }

    func synchronized(_ block: () -> ()) {
        lock(); defer { unlock() }
        block()
    }
}

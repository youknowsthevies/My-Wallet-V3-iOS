// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public func with<T>(_ value: T, _ yield: (T) throws -> T) rethrows -> T {
    try yield(value)
}

public func with<T>(_ value: T, _ yield: (T) throws -> Void) rethrows -> T where T: AnyObject {
    try yield(value)
    return value
}

public func with<T>(_ value: T, _ yield: (inout T) throws -> Void) rethrows -> T {
    var value = value
    try yield(&value)
    return value
}

public func with<T>(_ value: inout T, _ yield: (inout T) throws -> Void) rethrows -> T {
    try yield(&value)
    return value
}

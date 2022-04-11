// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped

    var wrapped: Wrapped? { get }
    static var none: Self { get }

    static func some(_ newValue: Wrapped) -> Self
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

extension OptionalProtocol {
    public var isNil: Bool { wrapped == nil }
    public var isNotNil: Bool { wrapped == nil }
}

extension Optional: OptionalProtocol {
    public var wrapped: Wrapped? { self }
}

extension Optional {

    @discardableResult
    public func or<E>(throw error: @autoclosure () -> E) throws -> Wrapped where E: Error {
        guard let value = self else { throw error() }
        return value
    }

    public func or(default defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        guard let value = self else { return defaultValue() }
        return value
    }

    public func `as`<T>(_ type: T.Type) -> T? {
        wrapped as? T
    }

    public subscript<T>(_: T.Type = T.self) -> T? {
        wrapped as? T
    }
}

// Optional Assignment
infix operator ?=: AssignmentPrecedence

public func ?= <A>(l: inout A, r: A?) {
    if let r = r { l = r }
}

extension Optional {

    @inlinable public func map<T>(_ type: T.Type) -> T? { self as? T }
}

extension Collection {

    public var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}

extension Optional where Wrapped: Collection {

    @inlinable public var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            return wrapped.isEmpty
        }
    }

    @inlinable public var isNotNilOrEmpty: Bool {
        !isNilOrEmpty
    }

    @inlinable public var nilIfEmpty: Optional {
        isNilOrEmpty ? nil : self
    }
}

extension Optional where Wrapped: Collection & ExpressibleByArrayLiteral {

    @inlinable public var emptyIfNil: Wrapped {
        switch self {
        case .none:
            return []
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension Optional where Wrapped: Collection & ExpressibleByStringLiteral {

    @inlinable public var emptyIfNil: Wrapped {
        switch self {
        case .none:
            return ""
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension Optional: CustomStringConvertible {

    public var description: String {
        switch self {
        case .none:
            return "nil \(Wrapped.self)"
        case .some(let wrapped):
            return "\(wrapped)"
        }
    }
}

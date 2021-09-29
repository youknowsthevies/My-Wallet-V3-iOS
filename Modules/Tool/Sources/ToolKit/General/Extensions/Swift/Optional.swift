// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped

    var wrapped: Wrapped? { get }

    static var none: Self { get }

    static func some(_ newValue: Wrapped) -> Self
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

extension Optional: OptionalProtocol {
    public var wrapped: Wrapped? { self }
}

extension Optional {

    @discardableResult
    public func or<E>(throw error: E) throws -> Wrapped where E: Error {
        guard let value = self else { throw error }
        return value
    }
}

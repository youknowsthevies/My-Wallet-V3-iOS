// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension StringProtocol {

    public func dropPrefix<S>(_ contents: S) -> SubSequence where S: StringProtocol {
        hasPrefix(contents) ? self[index(startIndex, offsetBy: contents.count)...] : self[...]
    }

    public func dropSuffix<S>(_ contents: S) -> SubSequence where S: StringProtocol {
        hasSuffix(contents) ? self[..<index(endIndex, offsetBy: -contents.count)] : self[...]
    }
}

extension StringProtocol {
    public var string: String { String(self) }
}

extension StringProtocol {

    public func interpolating(_ args: CVarArg...) -> String {
        String(format: string, arguments: args)
    }
}

public protocol NewTypeString: Codable, Hashable, Comparable, ExpressibleByStringLiteral, LosslessStringConvertible {
    var value: String { get }
    init(_ value: String)
}

extension NewTypeString {
    public init(stringLiteral value: String) { self.init(value) }
    public init(from decoder: Decoder) throws { try self.init(String(from: decoder)) }
    public func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
    public init?(_ description: String) { self.init(description) }
    public var description: String { value }
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.value < rhs.value }
}

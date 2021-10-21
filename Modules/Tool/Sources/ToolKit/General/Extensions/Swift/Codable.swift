// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Decodable {

    public init(json any: Any, using decoder: JSONDecoder = .init()) throws {
        let data = try JSONSerialization.data(withJSONObject: any, options: .fragmentsAllowed)
        self = try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {

    public func data(using encoder: JSONEncoder = .init()) throws -> Data {
        try encoder.encode(self)
    }

    public func json(using encoder: JSONEncoder = .init()) throws -> Any {
        try data(using: encoder).json()
    }
}

extension Data {

    public func json() throws -> Any {
        try JSONSerialization.jsonObject(with: self, options: .allowFragments)
    }
}

extension Optional where Wrapped == Data {

    public func json() throws -> Any {
        switch self {
        case nil:
            return NSNull()
        case let wrapped?:
            return try wrapped.json()
        }
    }
}

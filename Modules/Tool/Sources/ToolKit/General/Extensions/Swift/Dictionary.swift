// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Dictionary where Key == String, Value == Any {

    public func json(options: JSONSerialization.WritingOptions = []) throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: options)
    }
}

extension Array where Element == Any {

    public func json(options: JSONSerialization.WritingOptions = []) throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: options)
    }
}

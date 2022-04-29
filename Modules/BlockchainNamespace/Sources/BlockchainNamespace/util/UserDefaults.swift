// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol Preferences {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
}

extension Preferences {

    public func transaction(_ key: String, _ yield: (inout Any?) -> Void) {
        var object = object(forKey: key)
        yield(&object)
        set(object, forKey: key)
    }
}

extension UserDefaults: Preferences {}

extension Mock {

    public class Preferences: BlockchainNamespace.Preferences {

        var store: [String: Any] = [:]

        public init() {}

        public func object(forKey defaultName: String) -> Any? {
            store[defaultName]
        }

        public func set(_ value: Any?, forKey defaultName: String) {
            store[defaultName] = value
        }
    }
}

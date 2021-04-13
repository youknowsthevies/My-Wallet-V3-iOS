//
//  ProcessInfo.swift
//  ToolKit
//
//  Created by Paulo on 13/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension ProcessInfo {
    /// Return Boolean value for given key.
    ///
    /// If the value for the given key is any string other than `"true"` or
    /// `"false"` (case insensitive), the result is `nil`.
    public func environmentBoolean(for key: String) -> Bool? {
        guard let object = environment[key] else {
            return nil
        }
        return Bool(object.lowercased())
    }

    /// Checks for the presence of `XCTestConfigurationFilePath` in the environment dictionary,
    ///  this indicates we are running unit tests.
    public var isUnitTesting: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}

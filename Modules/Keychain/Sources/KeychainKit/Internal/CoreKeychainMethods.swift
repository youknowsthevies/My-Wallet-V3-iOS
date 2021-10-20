// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

typealias CoreKeychainReader = (_ query: CFDictionary) -> ReadOutput
typealias CoreKeychainAction = (_ query: CFDictionary) -> OSStatus
typealias CoreKeychainUpdater = (_ query: CFDictionary, _ attributesToUpdate: CFDictionary) -> OSStatus

struct ReadOutput {
    let object: AnyObject?
    let status: OSStatus
}

/// Reads a value for the specific query
/// - Parameter query: A CFDictionary value for the query
/// - Returns: A `ReadOutput` which contains the return object and a error status
func keychainReader(_ query: CFDictionary) -> ReadOutput {
    var returnValue: AnyObject?
    let status = SecItemCopyMatching(query, &returnValue)
    guard status == errSecSuccess else {
        return ReadOutput(object: nil, status: status)
    }
    return ReadOutput(object: returnValue, status: status)
}

/// Writes using the given query
/// - Parameter query: A CFDictionary value for the query
/// - Returns: A result code of `OSStatus`
func keychainWriter(_ query: CFDictionary) -> OSStatus {
    SecItemAdd(query, nil)
}

/// Removes using the given query
/// - Parameter query: A CFDictionary value for the query
/// - Returns: A result code of `OSStatus`
func keychainRemover(_ query: CFDictionary) -> OSStatus {
    SecItemDelete(query)
}

/// Updates the specific query
/// - Parameter query: A CFDictionary value for the query
/// - Returns: A result code of `OSStatus`
func keychainUpdater(_ query: CFDictionary, _ attributesToUpdate: CFDictionary) -> OSStatus {
    SecItemUpdate(query, attributesToUpdate)
}

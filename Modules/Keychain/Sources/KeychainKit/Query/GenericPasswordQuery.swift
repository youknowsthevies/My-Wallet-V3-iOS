// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct GenericPasswordQuery: KeychainQueryProvider, Equatable {
    let itemClass: KeychainItemClass = .genericPassword
    let service: String
    let permission: KeychainPermission
    let accessGroup: String?
    let synchronizable: Bool

    public init(
        service: String
    ) {
        self.service = service
        accessGroup = nil
        permission = .afterFirstUnlock
        synchronizable = false
    }

    public init(
        service: String,
        accessGroup: String
    ) {
        self.service = service
        self.accessGroup = accessGroup
        permission = .afterFirstUnlock
        synchronizable = false
    }

    public init(
        service: String,
        accessGroup: String?,
        permission: KeychainPermission,
        synchronizable: Bool
    ) {
        self.service = service
        self.accessGroup = accessGroup
        self.permission = permission
        self.synchronizable = synchronizable
    }

    // MARK: - KeychainQuery

    public func query() -> [String: Any] {
        var query = [String: Any]()
        query[kSecClass as String] = itemClass.queryValue
        query[kSecAttrService as String] = service
        query[kSecAttrAccessible as String] = permission.queryValue

        if synchronizable {
            query[kSecAttrSynchronizable as String] = kCFBooleanTrue
        }

        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        #endif

        return query
    }
}

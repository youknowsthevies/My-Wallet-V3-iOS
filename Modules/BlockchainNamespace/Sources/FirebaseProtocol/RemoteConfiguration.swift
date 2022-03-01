// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol RemoteConfiguration_p {

    associatedtype FetchStatus: RemoteConfigurationFetchStatus_p
    associatedtype Source: RemoteConfigurationSource_p
    associatedtype Value: RemoteConfigurationValue_p

    func fetch(withExpirationDuration expirationDuration: TimeInterval) async throws -> FetchStatus
    func activate() async throws -> Bool
    func allKeys(from source: Source) -> [String]

    subscript(key: String) -> Value { get }
}

public protocol RemoteConfigurationValue_p {
    var dataValue: Data { get }
}

public protocol RemoteConfigurationSource_p: Hashable {
    static var remote: Self { get }
    static var `default`: Self { get }
    static var `static`: Self { get }
}

public protocol RemoteConfigurationFetchStatus_p: Hashable {
    static var noFetchYet: Self { get }
    static var success: Self { get }
    static var failure: Self { get }
    static var throttled: Self { get }
}

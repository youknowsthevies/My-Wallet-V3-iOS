// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WalletPayload: Equatable {

    public let guid: String
    public let authType: Int
    public let language: String
    public let shouldSyncPubKeys: Bool
    public let time: Date
    public let payload: WalletPayloadWrapper?

    public init(
        guid: String,
        authType: Int,
        language: String,
        shouldSyncPubKeys: Bool,
        time: Date,
        payload: WalletPayloadWrapper?
    ) {
        self.guid = guid
        self.authType = authType
        self.language = language
        self.shouldSyncPubKeys = shouldSyncPubKeys
        self.time = time
        self.payload = payload
    }
}

extension WalletPayload {
    var authenticatorType: WalletAuthenticatorType {
        WalletAuthenticatorType(rawValue: authType) ?? .standard
    }
}

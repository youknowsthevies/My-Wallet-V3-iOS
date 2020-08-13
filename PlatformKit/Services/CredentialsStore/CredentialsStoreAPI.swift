//
//  CredentialsStoreAPI.swift
//  PlatformKit
//
//  Created by Paulo on 23/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CredentialsStoreAPI {
    func backup(pinDecryptionKey: String) -> Completable
    func pinData() -> CredentialsPinData?
    func walletData(pinDecryptionKey: String) -> Single<CredentialsWalletData>
    func synchronize()
    func erase()
}

public struct CredentialsPinData {
    public let pinKey: String
    public let encryptedPinPassword: String
}

public struct CredentialsWalletData {
    public let guid: String
    public let sharedKey: String
}

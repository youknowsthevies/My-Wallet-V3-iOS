//
//  NabuServiceProvider.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

public protocol NabuServiceProviderAPI: AnyObject {
    var authenticator: NabuAuthenticator { get }
    var walletSynchronizer: WalletNabuSynchronizerServiceAPI { get }
    var jwtToken: JWTServiceAPI { get }
}

public final class NabuServiceProvider: NabuServiceProviderAPI {
    
    public let authenticator: NabuAuthenticator
    public let walletSynchronizer: WalletNabuSynchronizerServiceAPI
    public let jwtToken: JWTServiceAPI
    
    public init(jwtClient: JWTClientAPI,
                updateWalletInformationClient: UpdateWalletInformationClientAPI,
                walletRepository: WalletRepositoryAPI,
                settingsService: SettingsServiceAPI,
                deviceInfo: DeviceInfo) {
        jwtToken = JWTService(
            client: jwtClient,
            credentialsRepository: walletRepository
        )
        authenticator = NabuAuthenticator(
            offlineTokenRepository: walletRepository,
            authenticationExecutor: NabuAuthenticationExecutor(
                settingsService: settingsService,
                jwtService: jwtToken,
                credentialsRepository: walletRepository,
                deviceInfo: deviceInfo
            )
        )
        walletSynchronizer = WalletNabuSynchronizerService(
            jwtService: jwtToken,
            updateUserInformationClient: updateWalletInformationClient
        )
    }
}

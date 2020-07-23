//
//  NabuServiceProvider.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ToolKit
import NetworkKit

public protocol NabuServiceProviderAPI: AnyObject {
    var authenticator: AuthenticatorAPI { get }
    var walletSynchronizer: WalletNabuSynchronizerServiceAPI { get }
    var jwtToken: JWTServiceAPI { get }
}

public final class NabuServiceProvider: NabuServiceProviderAPI {
    
    @Inject public var authenticator: AuthenticatorAPI
    @Inject public var walletSynchronizer: WalletNabuSynchronizerServiceAPI
    @Inject public var jwtToken: JWTServiceAPI
}

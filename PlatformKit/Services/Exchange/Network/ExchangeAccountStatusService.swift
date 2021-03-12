//
//  ExchangeLinkStatusService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/9/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol ExchangeAccountStatusServiceAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }
    var hasEnabled2FA: Single<Bool> { get }
}

public final class ExchangeAccountStatusService: ExchangeAccountStatusServiceAPI {
    
    // MARK: - ExchangeLinkStatusServiceAPI
    
    public var hasLinkedExchangeAccount: Single<Bool> {
        client.hasLinkedExchangeAccount
    }
    
    public var hasEnabled2FA: Single<Bool> {
        client.hasEnabled2FA
    }
    
    // MARK: - Private Properties
    
    private let client: ExchangeAccountStatusClientAPI
    
    // MARK: - Init
    
    init(client: ExchangeAccountsClientAPI = resolve()) {
        self.client = client
    }
}

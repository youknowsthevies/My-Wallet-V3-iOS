//
//  CustodyWithdrawalRequestService.swift
//  PlatformKit
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift

/// Client facing API for submitting a withdrawal.
public protocol CustodyWithdrawalServiceAPI: class {
    
    /// Submit a withdrawal with a `CryptoValue` and corresponding wallet address.
    func makeWithdrawal(amount: CryptoValue, destination: String) -> Single<CustodialWithdrawalResponse>
}

public final class CustodyWithdrawalRequestService: CustodyWithdrawalServiceAPI {
    
    // MARK: - Private Properties
    
    private let client: CustodyWithdrawalClientAPI
    
    // MARK: - Init
    
    public convenience init() {
        self.init(client: resolve())
    }
    
    init(client: CustodyWithdrawalClientAPI) {
        self.client = client
    }
    
    // MARK: - SimpleBuyWithdrawalServiceAPI
    
    public func makeWithdrawal(amount: CryptoValue, destination: String) -> Single<CustodialWithdrawalResponse> {
        self.client.withdraw(cryptoValue: amount, destination: destination)
    }
}

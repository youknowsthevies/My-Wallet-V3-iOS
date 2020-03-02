//
//  CustodyWithdrawalRequestService.swift
//  PlatformKit
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Client facing API for submitting a withdrawal.
public protocol CustodyWithdrawalServiceAPI: class {
    
    /// Submit a withdrawal with a `CryptoValue` and corresponding wallet address.
    func makeWithdrawal(amount: CryptoValue, destination: String) -> Single<CustodialWithdrawalResponse>
}

public final class CustodyWithdrawalRequestService: CustodyWithdrawalServiceAPI {
    
    // MARK: - Private Properties
    
    private let client: CustodyWithdrawalClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    
    // MARK: - Init
    
    public init(client: CustodyWithdrawalClientAPI = CustodialClient(),
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.authenticationService = authenticationService
    }
    
    // MARK: - SimpleBuyWithdrawalServiceAPI
    
    public func makeWithdrawal(amount: CryptoValue, destination: String) -> Single<CustodialWithdrawalResponse> {
        return authenticationService
            .getSessionToken()
            .map { $0.token }
            .flatMap(weak: self) { (self, authToken) -> Single<CustodialWithdrawalResponse> in
                self.client.withdraw(cryptoValue: amount, destination: destination, authToken: authToken)
            }
    }
}

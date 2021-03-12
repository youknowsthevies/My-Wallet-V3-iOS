//
//  ExchangeAccountsClient.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/4/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import RxSwift

protocol ExchangeAccountStatusClientAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }
    var hasEnabled2FA: Single<Bool> { get }
}

protocol ExchangeAccountsProviderClientAPI {
    func exchangeAddress(with currency: CryptoCurrency) -> Single<CryptoExchangeAddressResponse>
}

protocol ExchangeAccountsClientAPI: ExchangeAccountStatusClientAPI,
                                    ExchangeAccountsProviderClientAPI { }

final class ExchangeAccountsClient: ExchangeAccountsClientAPI {
    
    enum ExchangeAccountsClientError {
        /// Two factor authentication required
        case twoFactorRequired
    }
    
    private enum Path {
        static let exchangeAddress = [ "payments", "accounts", "linked" ]
    }
    
    // MARK: - Properties
    
    private let featureConfigurator: FeatureConfiguring
    private let nabuUserService: NabuUserServiceAPI
    private let communicator: NetworkCommunicatorAPI
    private let requestBuilder: RequestBuilder
    
    // MARK: - Setup
    
    init(featureConfigurator: FeatureConfiguring = resolve(),
         nabuUserService: NabuUserServiceAPI = resolve(),
         communicator: NetworkCommunicatorAPI = resolve(tag: DIKitContext.retail),
         requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)) {
        self.communicator = communicator
        self.featureConfigurator = featureConfigurator
        self.requestBuilder = requestBuilder
        self.nabuUserService = nabuUserService
    }
    
    // MARK: - ExchangeAccountsClientAPI
    
    func exchangeAddress(with currency: CryptoCurrency) -> Single<CryptoExchangeAddressResponse> {
        let model = CryptoExchangeAddressRequest(currency: currency)
        let request = requestBuilder.put(
            path: Path.exchangeAddress,
            body: try? JSONEncoder().encode(model),
            authenticated: true
        )!
        return communicator.perform(request: request)
    }
    
    var hasLinkedExchangeAccount: Single<Bool> {
        nabuUserService
            .fetchUser()
            .map(\.hasLinkedExchangeAccount)
    }
    
    var hasEnabled2FA: Single<Bool> {
        /// It does not matter what asset we fetch.
        exchangeAddress(with: .bitcoin)
            /// If the user has accounts returned,
            /// then they have 2FA enabled.
            .map { _ in true }
            /// If an error is thrown when fetching accounts
            /// parse the error to determine if it is because 2FA is
            /// not enabled.
            .catchError { error in
                guard let networkError = error as? NetworkCommunicatorError else {
                    throw error
                }
                if case let .serverError(serverError) = networkError,
                   let nabuError = serverError.nabuError,
                   nabuError.code == .bad2fa {
                    return .just(false)
                } else {
                    throw networkError
                }
            }
    }
}

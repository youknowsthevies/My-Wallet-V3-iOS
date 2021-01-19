//
//  StellarAssetAccountDetailsService.swift
//  StellarKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarAssetAccountDetailsService: AssetAccountDetailsAPI {
    typealias AccountDetails = StellarAssetAccountDetails
    
    private let horizonProxy: HorizonProxyAPI

    init(horizonProxy: HorizonProxyAPI = resolve()) {
        self.horizonProxy = horizonProxy
    }
    
    func accountDetails(for accountID: String) -> Single<AccountDetails> {
        horizonProxy.accountResponse(for: accountID)
            .map { response -> AccountDetails in
                response.toAssetAccountDetails()
            }
            .catchError { error in
                // If the network call to Horizon fails due to there not being a default account (i.e. account is not yet
                // funded), catch that error and return a StellarAccount with 0 balance
                switch error {
                case StellarAccountError.noDefaultAccount:
                    return Single.just(AccountDetails.unfunded(accountID: accountID))
                default:
                    throw error
                }
            }
    }
}

fileprivate extension stellarsdk.AccountService {
    func getAccountDetails(accountId: String) -> Single<AccountResponse> {
        Single<AccountResponse>.create { [weak self] event -> Disposable in
            guard let self = self else {
                event(.error(ToolKitError.nullReference(Self.self)))
                return Disposables.create()
            }
            self.getAccountDetails(
                accountId: accountId,
                response: { response in
                    switch response {
                    case .success(details: let details):
                        event(.success(details))
                    case .failure(error: let error):
                        event(.error(error.toStellarServiceError()))
                    }
                }
            )
            return Disposables.create()
        }
    }
}

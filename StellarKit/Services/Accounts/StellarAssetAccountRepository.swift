//
//  StellarAssetAccountRepository.swift
//  StellarKit
//
//  Created by AlexM on 11/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift

open class StellarAssetAccountRepository: AssetAccountRepositoryAPI {
    public typealias Details = StellarAssetAccountDetails
    
    public var assetAccountDetails: Single<Details> {
        currentAssetAccountDetails(fromCache: true)
    }
    
    fileprivate let service: StellarAssetAccountDetailsService
    fileprivate let walletRepository: StellarWalletAccountRepository
    
    // MARK: Lifecycle
    
    public init(service: StellarAssetAccountDetailsService,
                walletRepository: StellarWalletAccountRepository) {
        self.service = service
        self.walletRepository = walletRepository
    }
    
    // MARK: Private Properties
    
    fileprivate var privateAccountDetails = BehaviorRelay<Details?>(value: nil)
    
    // MARK: AssetAccountRepositoryAPI
    
    public func currentAssetAccountDetails(fromCache: Bool) -> Single<Details> {
        if let cached = privateAccountDetails.value, fromCache == true {
            return .just(cached)
        }
        guard let walletAccount = walletRepository.defaultAccount else {
            return .error(StellarAccountError.noXLMAccount)
        }
        let accountID = walletAccount.publicKey
        return fetchAssetAccountDetails(accountID)
    }
    
    // MARK: Private Functions
    
    fileprivate func fetchAssetAccountDetails(_ accountID: String) -> Single<Details> {
        service
            .accountDetails(for: accountID)
            .do(onSuccess: { [weak self] account in
                self?.privateAccountDetails.accept(account)
            }
        )
    }
}

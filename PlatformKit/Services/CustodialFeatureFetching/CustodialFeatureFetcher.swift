//
//  CustodialFeatureFetcher.swift
//  PlatformKit
//
//  Created by Paulo on 18/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class CustodialFeatureFetcher: CustodialFeatureFetching {

    // MARK: Private Properties

    private let tiersService: KYCTiersServiceAPI
    private let featureFetching: FeatureFetching
    
    // MARK: Init
    
    public init(tiersService: KYCTiersServiceAPI,
                featureFetching: FeatureFetching) {
        self.tiersService = tiersService
        self.featureFetching = featureFetching
    }

    // MARK: Public Methods (CustodialFeatureFetching)

    public func featureEnabled(for key: AppFeature) -> Single<Bool> {
        guard let requiredState = requiredTierStatus(for: key) else {
            return featureFetching.fetchBool(for: key)
        }
        return fetchBool(for: key, given: requiredState.tier, is: requiredState.status)
    }

    // MARK: Private Methods

    private func requiredTierStatus(for key: AppFeature) -> (tier: KYC.Tier, status: KYC.AccountStatus)? {
        switch key {
        case .simpleBuyEnabled:
            return (.tier2, .approved)
        case .interestAccountEnabled:
            return (.tier2, .approved)
        default:
            assertionFailure("CustodialFeatureFetcher doesn't support \(key.rawValue)")
            return nil
        }
    }

    private func fetchBool(for key: AppFeature, given tier: KYC.Tier, is desiredStatus: KYC.AccountStatus) -> Single<Bool> {
        tiersService
            .tiers
            .map { $0.tierAccountStatus(for: tier) }
            .flatMap(weak: self) { (self, status) in
                if status != desiredStatus {
                    return Single<Bool>.just(false)
                }
                return self.featureFetching.fetchBool(for: key)
            }
    }
}

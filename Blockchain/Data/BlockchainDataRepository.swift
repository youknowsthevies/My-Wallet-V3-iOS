//
//  BlockchainDataRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift
import NetworkKit
import PlatformKit

/// TODO: Refactor and decompose into smaller services
/// Repository for fetching Blockchain data. Accessing properties in this repository
/// will be fetched from the cache (if available), otherwise, data will be fetched over
/// the network and subsequently cached for faster access.
class BlockchainDataRepository: DataRepositoryAPI {

    static let shared = BlockchainDataRepository()

    private let kycTiersService: KYCTiersServiceAPI
    private let authenticationService: NabuAuthenticationService
    private let communicator: NetworkCommunicatorAPI

    init(kycTiersService: KYCTiersServiceAPI = KYCServiceProvider.default.tiers,
         authenticationService: NabuAuthenticationService = NabuAuthenticationService.shared,
         communicator: NetworkCommunicatorAPI = NetworkCommunicator.shared) {
        self.kycTiersService = kycTiersService
        self.authenticationService = authenticationService
        self.communicator = communicator
    }

    // MARK: - Public Properties

    var user: Observable<User> {
        return nabuUser.map { $0 }
    }

    /// An Observable emitting the authenticated NabuUser. This Observable will first emit a value
    /// from the cache, if available, followed by the value over the network.
    var nabuUser: Observable<NabuUser> {
        return fetchDataStartingWithCache(
            cachedValue: cachedUser,
            networkValue: fetchNabuUser()
        )
    }
    
    var nabuUserSingle: Single<NabuUser> {
        nabuUser.take(1).asSingle()
    }

    var countries: Single<Countries> {
        let countriesFetchedOverNetwork = KYCNetworkRequest.request(
            get: .listOfCountries,
            type: Countries.self
        ).map { countries -> Countries in
            countries.sorted(by: { $0.name.uppercased() < $1.name.uppercased() })
        }

        return fetchData(
            cachedValue: cachedCountries,
            networkValue: countriesFetchedOverNetwork
        )
    }

    /// An Observable emitting the KYC Tiers for the current user. This Observable will
    /// first emit a value from the cache, if available, followed by the value over the network.
    var tiers: Observable<KYC.UserTiers> {
        return fetchDataStartingWithCache(
            cachedValue: cachedTiers,
            networkValue: fetchTiers()
        )
    }

    /// Fetches Tiers over the network.
    ///
    /// - Returns: the fetched KYC Tiers
    func fetchTiers() -> Single<KYC.UserTiers> {
        return kycTiersService.fetchTiers()
    }

    // MARK: - Private Properties

    private var cachedCountries = BehaviorRelay<Countries?>(value: nil)

    private var cachedUser = BehaviorRelay<NabuUser?>(value: nil)

    private var cachedTiers = BehaviorRelay<KYC.UserTiers?>(value: nil)

    // MARK: - Public Methods

    /// Prefetches data so that it can be cached
    func prefetchData() {
        _ = Observable.zip(
            nabuUser,
            countries.asObservable(),
            tiers
        ).subscribe()
    }

    /// Clears cached data in this repository
    func clearCache() {
        cachedUser = BehaviorRelay<NabuUser?>(value: nil)
        cachedCountries = BehaviorRelay<Countries?>(value: nil)
    }

    /// Fetches the NabuUser over the network and updates the cached NabuUser if successful
    ///
    /// - Returns: the fetched NabuUser
    func fetchNabuUser() -> Single<NabuUser> {
        return authenticationService.getSessionToken().flatMap { token in
            let headers = [HttpHeaderField.authorization: token.token]
            return KYCNetworkRequest.request(get: .currentUser, headers: headers, type: NabuUser.self)
        }.do(onSuccess: { [weak self] response in
            self?.cachedUser.accept(response)
        })
    }

    // MARK: - Private Methods

    private func fetchDataStartingWithCache<ResponseType: Decodable>(
        cachedValue: BehaviorRelay<ResponseType?>,
        networkValue: Single<ResponseType>
    ) -> Observable<ResponseType> {
        let networkObservable = networkValue.asObservable()
        guard let cachedValue = cachedValue.value else {
            return networkObservable
        }
        return networkObservable.startWith(cachedValue)
    }

    private func fetchData<ResponseType: Decodable>(
        cachedValue: BehaviorRelay<ResponseType?>,
        networkValue: Single<ResponseType>
    ) -> Single<ResponseType> {
        return Single.deferred {
            guard let cachedValue = cachedValue.value else {
                return networkValue
            }
            return Single.just(cachedValue)
        }.do(onSuccess: { response in
            cachedValue.accept(response)
        })
    }
}

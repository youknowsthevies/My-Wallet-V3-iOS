//
//  KYCTiersService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol KYCTiersServiceAPI: class {
    
    /// Returns the cached tiers. Fetches them if they are not already cached
    var tiers: Single<KYC.UserTiers> { get }
    
    /// Fetches the tiers from remote
    func fetchTiers() -> Single<KYC.UserTiers>
}

public final class KYCTiersService: KYCTiersServiceAPI {
    
    // MARK: - Exposed Properties
    
    public var tiers: Single<KYC.UserTiers> {
        _ = setup
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.semaphore.wait()
                let disposable = self.cachedTiers.valueSingle
                    .subscribe { event in
                        switch event {
                        case .success(let value):
                            observer(.success(value))
                        case .error(let value):
                            observer(.error(value))
                        }
                    }
                return Disposables.create {
                    disposable.dispose()
                    self.semaphore.signal()
                }
            }
            .subscribeOn(scheduler)
    }
        
    // MARK: - Private Properties
    
    private let cachedTiers = CachedValue<KYC.UserTiers>(configuration: .onSubscription())
    private let semaphore = DispatchSemaphore(value: 1)
    private let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    
    private lazy var setup: Void = {
        cachedTiers.setFetch(weak: self) { (self) in
            self.client.tiers()
        }
    }()
    
    private let client: KYCClientAPI
    
    // MARK: - Setup
    
    public convenience init() {
        self.init(client: KYCClient())
    }
    
    init(client: KYCClientAPI) {
        self.client = client
    }
    
    public func fetchTiers() -> Single<KYC.UserTiers> {
        _  = setup
        return cachedTiers.fetchValue
    }
}

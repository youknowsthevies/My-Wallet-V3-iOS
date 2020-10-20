//
//  NabuUserService.swift
//  PlatformKit
//
//  Created by Daniel on 02/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import DIKit

public protocol NabuUserServiceAPI: AnyObject {
    var user: Single<NabuUser> { get }
    func fetchUser() -> Single<NabuUser>
}

final class NabuUserService: NabuUserServiceAPI {
    
    // MARK: - Exposed Properties
    
    var user: Single<NabuUser> {
        _ = setup
        return Single.create(weak: self) { (self, observer) -> Disposable in
            guard case .success = self.semaphore.wait(timeout: .now() + .seconds(30)) else {
                observer(.error(ToolKitError.timedOut))
                return Disposables.create()
            }
            let disposable = self.cachedUser.valueSingle
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
    
    private let cachedUser = CachedValue<NabuUser>(configuration: .onSubscription())
    private let semaphore = DispatchSemaphore(value: 1)
    private let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    private let client: KYCClientAPI

    private lazy var setup: Void = {        
        cachedUser.setFetch(weak: self) { (self) in
            self.client.user()
        }
    }()
        
    // MARK: - Setup
    
    init(client: KYCClientAPI = resolve()) {
        self.client = client
    }
    
    func fetchUser() -> Single<NabuUser> {
        _  = setup
        return cachedUser.fetchValue
    }
}

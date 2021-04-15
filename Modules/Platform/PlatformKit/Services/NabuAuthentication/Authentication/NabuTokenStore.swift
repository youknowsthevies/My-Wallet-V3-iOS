//
//  NabuTokenStore.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import RxSwift
import ToolKit

final class NabuTokenStore {
    
    private let sessionTokenData = Atomic<NabuSessionTokenResponse?>(nil)
    
    var sessionTokenDataSingle: Single<NabuSessionTokenResponse?> {
        Single.just(sessionTokenData.value)
    }
    
    var requiresRefresh: Single<Bool> {
        .just(sessionTokenData.value == nil)
    }
    
    init() {
        NotificationCenter.when(.logout) { [weak self] _ in
            self?.sessionTokenData.mutate { $0 = nil }
        }
    }
    
    func invalidate() -> Completable {
        Completable.create(weak: self) { (self, observer) -> Disposable in
            self.sessionTokenData.mutate { $0 = nil }
            observer(.completed)
            return Disposables.create()
        }
    }
    
    func store(_ sessionTokenData: NabuSessionTokenResponse) -> Single<NabuSessionTokenResponse> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.sessionTokenData.mutate { $0 = sessionTokenData }
                observer(.success(sessionTokenData))
                return Disposables.create()
            }
    }
}

protocol NabuTokenStoreCombineAPI {
    
    var requiresRefreshPublisher: AnyPublisher<Bool, Never> { get }
    
    var sessionTokenDataPublisher: AnyPublisher<NabuSessionTokenResponse?, Never> { get }
    
    func invalidatePublisher() -> AnyPublisher<Void, Never>
    
    func storePublisher(
        _ sessionTokenData: NabuSessionTokenResponse
    ) -> AnyPublisher<NabuSessionTokenResponse, Never>
}

extension NabuTokenStore: NabuTokenStoreCombineAPI {
    
    var requiresRefreshPublisher: AnyPublisher<Bool, Never> {
        .just(sessionTokenData.value == nil)
    }
    
    var sessionTokenDataPublisher: AnyPublisher<NabuSessionTokenResponse?, Never> {
        .just(sessionTokenData.value)
    }
    
    func invalidatePublisher() -> AnyPublisher<Void, Never> {
        Deferred {
            Future { [weak self] promise in
                self?.sessionTokenData.mutate { $0 = nil }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func storePublisher(
        _ sessionTokenData: NabuSessionTokenResponse
    ) -> AnyPublisher<NabuSessionTokenResponse, Never> {
        Deferred {
            Future { [weak self] promise in
                self?.sessionTokenData.mutate { $0 = sessionTokenData }
                promise(.success(sessionTokenData))
            }
        }
        .eraseToAnyPublisher()
    }
}

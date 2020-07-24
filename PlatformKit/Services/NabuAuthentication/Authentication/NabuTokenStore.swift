//
//  NabuTokenStore.swift
//  PlatformKit
//
//  Created by Daniel on 26/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import NetworkKit

public final class NabuTokenStore {
    
    private let sessionTokenData = Atomic<NabuSessionTokenResponse?>(nil)
    
    var sessionTokenDataSingle: Single<NabuSessionTokenResponse?> {
        Single.just(sessionTokenData.value)
    }
    
    var requiresRefresh: Single<Bool> {
        .just(sessionTokenData.value == nil)
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
    
    public init() {
        NotificationCenter.when(.logout) { [weak self] _ in
            self?.sessionTokenData.mutate { $0 = nil }
        }
    }
}

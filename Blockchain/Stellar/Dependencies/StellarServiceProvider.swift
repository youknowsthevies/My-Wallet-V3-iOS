// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import StellarKit

final class StellarServiceProvider: NSObject {
    
    @objc static let shared: StellarServiceProvider = .init(services: .init())

    let services: StellarDependenciesAPI
    
    private lazy var setup: Void = {
        Observable
            .combineLatest(
                services.ledger.current,
                services.accounts.currentStellarAccount(fromCache: false).asObservable()
            )
            .subscribe()
            .disposed(by: disposeBag)
    }()

    private let disposeBag = DisposeBag()

    private init(services: StellarServices) {
        self.services = services
        super.init()
        _ = setup
    }
    
    func tearDown() {
        services.accounts.clear()
        services.operation.clear()
        services.operation.end()
    }
}

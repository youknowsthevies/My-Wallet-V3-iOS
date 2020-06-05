//
//  StellarServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import StellarKit

final class StellarServiceProvider: NSObject {
    
    @objc static let shared: StellarServiceProvider = .init(services: .init())

    let services: StellarDependenciesAPI

    private let disposeBag = DisposeBag()

    private init(services: StellarServices) {
        self.services = services
        super.init()
        setup()
    }

    private func setup() {
        Observable
            .combineLatest(
                services.ledger.current,
                services.accounts.currentStellarAccount(fromCache: false).asObservable()
            )
            .subscribe()
            .disposed(by: disposeBag)
    }

    func tearDown() {
        services.accounts.clear()
        services.operation.clear()
        services.operation.end()
    }
}

//
//  TodayViewInteractor.swift
//  TodayExtension
//
//  Created by Alex McGregor on 6/17/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import LocalAuthentication
import PlatformUIKit
import PlatformKit
import RxRelay
import RxSwift

final class TodayViewInteractor {
    
    // MARK: - Services
    
    let historicalProvider: HistoricalFiatPriceProviding
    let container: SharedContainerUserDefaults
    
    var isBalanceSyncingEnabled: Bool {
        container.shouldSyncPortfolio
    }
    
    var assetInteractors: Observable<[TodayExtensionCellInteractor]> {
        let values: [TodayExtensionCellInteractor] = CryptoCurrency
            .allCases
            .map {
                AssetPriceCellInteractor(
                    cryptoCurrency: $0,
                    historicalFiatPriceServiceAPI: historicalProvider[$0]
                )
            }
            .map { .assetPrice($0) }
        return Observable.just(values)
    }
    
    var portfolioInteractor: Observable<TodayExtensionCellInteractor?> {
        Observable.just(container.portfolio)
            .map { portfolio in
                guard let value = portfolio else { return nil }
                return .portfolio(.init(portfolio: value))
            }
    }
    
    private let disposeBag = DisposeBag()
    
    init(historicalProvider: HistoricalFiatPriceProviding = DataProvider.default.historicalPrices,
         container: SharedContainerUserDefaults = .default) {
        self.container = container
        self.historicalProvider = historicalProvider
    }
    
    /// Returns the supported device biometrics, regardless if currently configured in app
    private var supportsBioAuthentication: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    /// Performs authentication
    private func performAuthentication() -> Single<Void> {
        return Single.create { observer -> Disposable in
            let context = LAContext()
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "See your balances",
                reply: { authenticated, error in
                    if let error = error {
                        let biometryError = Biometry.BiometryError(with: error, type: Biometry.BiometryType(with: context.biometryType))
                        observer(.error(Biometry.EvaluationError.system(biometryError)))
                    } else if !authenticated {
                        observer(.error(Biometry.EvaluationError.notAllowed))
                    } else { // Success
                        observer(.success(()))
                    }
                }
            )
            return Disposables.create()
        }
    }
    
    func refresh() {
        self.historicalProvider.refresh(window: .day(.oneHour))
    }
}

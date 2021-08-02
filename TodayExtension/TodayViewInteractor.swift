// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import LocalAuthentication
import PlatformKit
import PlatformUIKit
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
        let values: [TodayExtensionCellInteractor] = enabledCurrenciesService.allEnabledCryptoCurrencies
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

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let disposeBag = DisposeBag()

    init(
        historicalProvider: HistoricalFiatPriceProviding = resolve(),
        container: SharedContainerUserDefaults = .default,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.container = container
        self.historicalProvider = historicalProvider
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    /// Returns the supported device biometrics, regardless if currently configured in app
    private var supportsBioAuthentication: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    /// Performs authentication
    private func performAuthentication() -> Single<Void> {
        Single.create { observer -> Disposable in
            let context = LAContext()
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "See your balances",
                reply: { authenticated, error in
                    if let error = error {
                        let biometryError = Biometry.BiometryError(
                            with: error,
                            type: Biometry.BiometryType(with: context.biometryType)
                        )
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
        historicalProvider.refresh(window: .day(.oneHour))
    }
}

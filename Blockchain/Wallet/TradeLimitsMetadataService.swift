// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import NetworkKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

final class TradeLimitsMetadataService: TradeLimitsMetadataServiceAPI {

    private let disposables = CompositeDisposable()

    private var cachedLimits = BehaviorRelay<TradeLimitsMetadata?>(value: nil)
    private var cachedLimitsTimer: Timer?
    private let clearCachedLimitsInterval: TimeInterval = 60
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        cachedLimitsTimer = Timer.scheduledTimer(
            withTimeInterval: clearCachedLimitsInterval,
            repeats: true
        ) { [weak self] _ in
            self?.clearCachedLimits()
        }
        cachedLimitsTimer?.tolerance = clearCachedLimitsInterval / 10
        cachedLimitsTimer?.fire()
    }

    deinit {
        cachedLimitsTimer?.invalidate()
        cachedLimitsTimer = nil
        disposables.dispose()
    }

    enum TradeLimitsAPIError: Error {
        case generic
    }

    /// Initializes this TradeLimitsMetadataService so that the trade limits for the current
    /// user is pre-fetched and cached
    func initialize(withFiatCurrency currency: String) {
        let disposable = getTradeLimits(withFiatCurrency: currency, ignoringCache: false)
            .subscribe(on: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                Logger.shared.debug("Successfully initialized TradeLimitsMetadataService.")
            }, onFailure: { error in
                Logger.shared.error("Failed to initialize TradeLimitsMetadataService: \(error)")
            })
        _ = disposables.insert(disposable)
    }

    func getTradeLimits(
        withFiatCurrency currency: String,
        withCompletion: @escaping ((Result<TradeLimitsMetadata, Error>) -> Void)
    ) {
        let disposable = getTradeLimits(withFiatCurrency: currency, ignoringCache: false)
            .subscribe(on: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { payload in
                withCompletion(.success(payload))
            }, onFailure: { error in
                withCompletion(.failure(error))
            })
        _ = disposables.insert(disposable)
    }

    func getTradeLimits(withFiatCurrency currency: String, ignoringCache: Bool) -> Single<TradeLimitsMetadata> {
        Single.deferred { [unowned self] in
            guard let cachedLimits = self.cachedLimits.value,
                  cachedLimits.currency == currency,
                  ignoringCache == false
            else {
                return self.getTradeLimitsNetwork(withFiatCurrency: currency)
                    .asSingle()
            }
            return Single.just(cachedLimits)
        }
        .do(onSuccess: { [weak self] response in
            self?.cachedLimits.accept(response)
        })
    }

    // MARK: - Private

    private func getTradeLimitsNetwork(
        withFiatCurrency currency: String
    ) -> AnyPublisher<TradeLimitsMetadata, NabuNetworkError> {
        let path = ["trades", "limits"]
        let parameters = [
            URLQueryItem(name: "currency", value: currency)
        ]
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    private func clearCachedLimits() {
        cachedLimits = BehaviorRelay<TradeLimitsMetadata?>(value: nil)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import RxSwift
import ToolKit

public protocol KYCTiersServiceAPI: AnyObject {

    /// Returns the cached tiers. Fetches them if they are not already cached
    var tiers: Single<KYC.UserTiers> { get }

    /// Fetches the tiers from remote
    func fetchTiers() -> Single<KYC.UserTiers>

    /// Fetches the Simplified Due Diligence Eligibility Status returning the whole response
    func simplifiedDueDiligenceEligibility() -> Single<SimplifiedDueDiligenceResponse>

    /// Fetches Simplified Due Diligence Eligibility Status
    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never>

    /// Fetches the Simplified Due Diligence Verification Status. It pools the API until a valid result is available. If the check fails, it returns `false`.
    func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<Bool, Never>
}

final class KYCTiersService: KYCTiersServiceAPI {

    // MARK: - Exposed Properties

    var tiers: Single<KYC.UserTiers> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            guard case .success = self.semaphore.wait(timeout: .now() + .seconds(30)) else {
                observer(.error(ToolKitError.timedOut))
                return Disposables.create()
            }
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

    private let client: KYCClientAPI
    private let featureFlagsService: InternalFeatureFlagServiceAPI
    private let cachedTiers = CachedValue<KYC.UserTiers>(configuration: .onSubscription())
    private let semaphore = DispatchSemaphore(value: 1)
    private let scheduler = SerialDispatchQueueScheduler(qos: .default)

    // MARK: - Setup

    init(
        client: KYCClientAPI = resolve(),
        featureFlagsService: InternalFeatureFlagServiceAPI = resolve()
    ) {
        self.client = client
        self.featureFlagsService = featureFlagsService
        cachedTiers.setFetch(weak: self) { (self) in
            self.client.tiers()
        }
    }

    func fetchTiers() -> Single<KYC.UserTiers> {
        cachedTiers.fetchValue
    }

    func simplifiedDueDiligenceEligibility() -> Single<SimplifiedDueDiligenceResponse> {
        guard featureFlagsService.isEnabled(.sddEnabled) else {
            return .just(SimplifiedDueDiligenceResponse(eligible: false, tier: KYC.Tier.tier0.rawValue))
        }
        return client.checkSimplifiedDueDiligenceEligibility()
            .asObservable()
            .asSingle()
    }

    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never> {
        simplifiedDueDiligenceEligibility()
            .asPublisher()
            .map(\.eligible)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<Bool, Never> {
        guard featureFlagsService.isEnabled(.sddEnabled) else {
            return .just(false)
        }

        func pollingHelper(attemptsCount: Int = 1) -> AnyPublisher<SimplifiedDueDiligenceVerificationResponse, NabuNetworkError> {
            // Poll the API every 5 seconds until `taskComplete` is `true` or an error is returned from the upstream for a maximum of 10 times
            client.checkSimplifiedDueDiligenceVerification()
                .flatMap { [pollingHelper] result -> AnyPublisher<SimplifiedDueDiligenceVerificationResponse, NabuNetworkError> in
                    let shouldRetry = !result.taskComplete && attemptsCount <= 10
                    guard shouldRetry else {
                        return .just(result)
                    }
                    return pollingHelper(attemptsCount + 1)
                        .delay(for: 5, scheduler: RunLoop.main)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }

        return pollingHelper()
            .replaceError(with: SimplifiedDueDiligenceVerificationResponse(verified: false, taskComplete: true))
            .map(\.verified)
            .eraseToAnyPublisher()
    }
}

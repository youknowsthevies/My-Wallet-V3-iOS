import Combine
import PlatformKit
import RxSwift

public final class MockEligibilityService: EligibilityServiceAPI {

    var value: Eligibility

    public init(
        _ value: Eligibility = .init(
            eligible: true,
            simpleBuyTradingEligible: true,
            simpleBuyPendingTradesEligible: true,
            pendingDepositSimpleBuyTrades: 0,
            pendingConfirmationSimpleBuyTrades: 0,
            maxPendingDepositSimpleBuyTrades: 3,
            maxPendingConfirmationSimpleBuyTrades: 100
        )
    ) {
        self.value = value
    }

    public var isEligible: Single<Bool> { .just(value.eligible) }
    public var isEligiblePublisher: AnyPublisher<Bool, Never> { .just(value.eligible) }

    public func fetch() -> Single<Bool> { .just(value.eligible) }
    public func eligibility() -> AnyPublisher<Eligibility, Error> { .just(value) }
}

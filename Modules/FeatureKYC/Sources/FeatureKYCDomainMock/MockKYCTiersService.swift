// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import PlatformKit
import RxSwift

public final class MockKYCTiersService: PlatformKit.KYCTiersServiceAPI {

    public struct RecordedInvocations {
        public var fetchTiers: [Void] = []
        public var fetchOverview: [Void] = []
        public var simplifiedDueDiligenceEligibility: [KYC.Tier] = []
        public var checkSimplifiedDueDiligenceEligibility: [KYC.Tier] = []
        public var checkSimplifiedDueDiligenceVerification: [KYC.Tier] = []
    }

    public struct StubbedResponses {
        public var fetchTiers: AnyPublisher<KYC.UserTiers, Nabu.Error> = .empty()
        public var simplifiedDueDiligenceEligibility: AnyPublisher<SimplifiedDueDiligenceResponse, Never> = .empty()
        public var checkSimplifiedDueDiligenceEligibility: AnyPublisher<Bool, Never> = .empty()
        public var checkSimplifiedDueDiligenceVerification: AnyPublisher<Bool, Never> = .empty()
        public var fetchOverview: AnyPublisher<KYCLimitsOverview, Nabu.Error> = .empty()
    }

    public private(set) var recordedInvocations = RecordedInvocations()
    public var stubbedResponses = StubbedResponses()

    public var tiers: AnyPublisher<KYC.UserTiers, Nabu.Error> {
        fetchTiers()
    }

    public var tiersStream: AnyPublisher<KYC.UserTiers, Nabu.Error> {
        fetchTiers()
    }

    public func fetchTiers() -> AnyPublisher<KYC.UserTiers, Nabu.Error> {
        recordedInvocations.fetchTiers.append(())
        return stubbedResponses.fetchTiers
    }

    public func simplifiedDueDiligenceEligibility(for tier: KYC.Tier) -> AnyPublisher<SimplifiedDueDiligenceResponse, Never> {
        recordedInvocations.simplifiedDueDiligenceEligibility.append(tier)
        return stubbedResponses.simplifiedDueDiligenceEligibility
    }

    public func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never> {
        checkSimplifiedDueDiligenceEligibility(for: .tier0)
    }

    public func checkSimplifiedDueDiligenceEligibility(for tier: KYC.Tier) -> AnyPublisher<Bool, Never> {
        recordedInvocations.checkSimplifiedDueDiligenceEligibility.append(tier)
        return stubbedResponses.checkSimplifiedDueDiligenceEligibility
    }

    public func checkSimplifiedDueDiligenceVerification(
        for tier: KYC.Tier,
        pollUntilComplete: Bool
    ) -> AnyPublisher<Bool, Never> {
        recordedInvocations.checkSimplifiedDueDiligenceVerification.append(tier)
        return stubbedResponses.checkSimplifiedDueDiligenceVerification
    }

    public func checkSimplifiedDueDiligenceVerification(pollUntilComplete: Bool) -> AnyPublisher<Bool, Never> {
        checkSimplifiedDueDiligenceVerification(for: .tier0, pollUntilComplete: pollUntilComplete)
    }

    public func fetchOverview() -> AnyPublisher<KYCLimitsOverview, Nabu.Error> {
        recordedInvocations.fetchOverview.append(())
        return stubbedResponses.fetchOverview
    }
}

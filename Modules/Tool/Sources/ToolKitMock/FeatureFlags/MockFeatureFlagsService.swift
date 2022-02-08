// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public final class MockFeatureFlagsService: FeatureFlagsServiceAPI {

    public struct RecordedInvocations {
        public var enable: [FeatureFlag] = []
        public var disable: [FeatureFlag] = []
        public var isEnabled: [FeatureFlag] = []
        public var object: [FeatureFlag] = []
    }

    public struct StubbedResults {
        public var object: AnyPublisher<Codable?, FeatureFlagError> = .empty()
    }

    public private(set) var recordedInvocations = RecordedInvocations()
    public var stubbedResults = StubbedResults()

    public init() {
        // required
    }

    private var features: [FeatureFlag: Bool] = [:]

    public func enable(_ feature: FeatureFlag) -> AnyPublisher<Void, Never> {
        features[feature] = true
        recordedInvocations.enable.append(feature)
        return .just(())
    }

    public func disable(_ feature: FeatureFlag) -> AnyPublisher<Void, Never> {
        features[feature] = false
        recordedInvocations.disable.append(feature)
        return .just(())
    }

    public func isEnabled(_ feature: FeatureFlag) -> AnyPublisher<Bool, Never> {
        recordedInvocations.isEnabled.append(feature)
        return .just(features[feature] ?? false)
    }

    public func object<Feature: Codable>(
        for feature: FeatureFlag,
        type: Feature.Type
    ) -> AnyPublisher<Feature?, FeatureFlagError> {
        recordedInvocations.object.append(feature)
        return stubbedResults.object
            .map { $0 as? Feature }
            .eraseToAnyPublisher()
    }
}

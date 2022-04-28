// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public final class MockFeatureFlagsService: FeatureFlagsServiceAPI {

    public struct RecordedInvocations {
        public var object: [AppFeature] = []
    }

    public struct StubbedResults {
        public var object: AnyPublisher<Any?, FeatureFlagError> = .empty()
    }

    public private(set) var recordedInvocations = RecordedInvocations()
    public var stubbedResults = StubbedResults()

    public init() {
        // required
    }

    private var features: [AppFeature: Bool] = [:]

    public func enable(_ feature: AppFeature) -> AnyPublisher<Void, Never> {
        features[feature] = true
        return .just(())
    }

    public func disable(_ feature: AppFeature) -> AnyPublisher<Void, Never> {
        features[feature] = false
        return .just(())
    }

    public func object<Feature: Codable>(
        for feature: AppFeature,
        type: Feature.Type
    ) -> AnyPublisher<Feature, FeatureFlagError> {
        recordedInvocations.object.append(feature)
        if Feature.self is Bool.Type, let feature = features[feature] {
            return .just(feature as! Feature)
        }
        return stubbedResults.object
            .flatMap { output -> AnyPublisher<Feature, FeatureFlagError> in
                if let feature = output as? Feature {
                    return Just(feature).setFailureType(to: FeatureFlagError.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(outputType: Feature.self, failure: FeatureFlagError.missingKeyRawValue)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

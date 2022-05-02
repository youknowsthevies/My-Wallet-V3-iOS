// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public class NoOpFeatureFlagsService: FeatureFlagsServiceAPI {

    public init() {}

    public func object<Feature>(
        for feature: AppFeature,
        type: Feature.Type
    ) -> AnyPublisher<Feature, FeatureFlagError> where Feature: Decodable, Feature: Encodable {
        .empty()
    }
}

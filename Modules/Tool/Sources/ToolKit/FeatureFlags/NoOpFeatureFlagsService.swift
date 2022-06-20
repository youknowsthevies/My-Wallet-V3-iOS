// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public class NoOpFeatureFlagsService: FeatureFlagsServiceAPI {

    public init() {}

    public func fetch<Feature>(
        for key: AppFeature,
        as type: Feature.Type
    ) -> AnyPublisher<Feature, FeatureFlagError> where Feature: Decodable {
        .empty()
    }
}

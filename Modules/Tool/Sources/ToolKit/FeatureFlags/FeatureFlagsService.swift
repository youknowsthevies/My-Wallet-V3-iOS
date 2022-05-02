// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit

public enum BuildFlag {
    public static var isAlpha: Bool = false
    public static var isInternal: Bool = false
}

public enum FeatureFlagError: Error {
    case decodingError(Error)
    case missingKeyRawValue
    case timeout
}

/// This is the interface all modules should use for feature flags.
/// It replaces `InternalFeatureFlagServiceAPI` and `FeatureFetching` by wrapping them under a unified set of APIs.
/// This is to avoid having to change business logic when moving from internally-driven to externally-driven feature flags and may be extended to allow the use of either at the same time.
public protocol FeatureFlagsServiceAPI {
    func object<Feature: Codable>(
        for feature: AppFeature,
        type: Feature.Type
    ) -> AnyPublisher<Feature, FeatureFlagError>
}

extension FeatureFlagsServiceAPI {

    public func isEnabled(_ feature: AppFeature) -> AnyPublisher<Bool, Never> {
        object(for: feature, type: Bool.self).replaceError(with: false).eraseToAnyPublisher()
    }

    public func object<Feature: Codable>(for feature: AppFeature) -> AnyPublisher<Feature?, FeatureFlagError> {
        object(for: feature, type: Feature?.self)
    }
}

public protocol FeatureFetching: AnyObject {
    func fetch<Feature: Decodable>(
        for key: AppFeature,
        as type: Feature.Type
    ) -> AnyPublisher<Feature, FeatureFlagError>
}

final class FeatureFlagsService: FeatureFlagsServiceAPI {

    private let remoteFeatureFlagsService: FeatureFetching

    init(remoteFeatureFlagsService: FeatureFetching = resolve()) {
        self.remoteFeatureFlagsService = remoteFeatureFlagsService
    }

    func object<Feature: Codable>(
        for feature: AppFeature,
        type: Feature.Type
    ) -> AnyPublisher<Feature, FeatureFlagError> {
        remoteFeatureFlagsService
            .fetch(for: feature, as: Feature.self)
            .eraseToAnyPublisher()
    }
}

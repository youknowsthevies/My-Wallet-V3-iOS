// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit
import ToolKit

public class AttributionService: AttributionServiceAPI {
    private var skAdNetworkService: SkAdNetworkServiceAPI
    private var errorRecorder: ErrorRecording
    private var featureFlagService: FeatureFlagsServiceAPI
    private var attributionRepository: AttributionRepositoryAPI

    public init(
        authenticator: AuthenticatorAPI,
        skAdNetworkService: SkAdNetworkServiceAPI,
        errorRecorder: ErrorRecording,
        attributionRepository: AttributionRepositoryAPI,
        featureFlagService: FeatureFlagsServiceAPI
    ) {
        self.skAdNetworkService = skAdNetworkService
        self.errorRecorder = errorRecorder
        self.attributionRepository = attributionRepository
        self.featureFlagService = featureFlagService
    }

    public func registerForAttribution() {
        skAdNetworkService.firstTimeRegister()
    }

    public func startUpdatingConversionValues() -> AnyPublisher<Void, NetworkError> {
        featureFlagService
            .isEnabled(.skAdNetworkAttribution)
            .filter { $0 }
            .flatMap { [weak self] _ -> AnyPublisher<Void, NetworkError> in
                guard let self = self else { return .just(()) }
                return self.startObservingValues()
            }
            .eraseToAnyPublisher()
    }

    private func startObservingValues() -> AnyPublisher<Void, NetworkError> {
        attributionRepository
            .fetchAttributionValues()
            .handleEvents(receiveOutput: { [skAdNetworkService] conversionValue in
                skAdNetworkService.update(with: conversionValue)
            })
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit

/// Intend for SwiftUI Previews and only available in DEBUG
final class NoOpDeviceVerificationService: DeviceVerificationServiceAPI {

    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        .empty()
    }

    func sendDeviceVerificationEmail(
        to emailAddress: String
    ) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        .empty()
    }

    func handleLoginRequestDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError> {
        .empty()
    }

    func pollForWalletInfo() -> AnyPublisher<
        Result<WalletInfo, WalletInfoPollingError>,
        DeviceVerificationServiceError
    > {
        .empty()
    }

    func authorizeVerifyDevice(
        from sessionToken: String,
        payload: String,
        confirmDevice: Bool?
    ) -> AnyPublisher<Void, AuthorizeVerifyDeviceError> {
        .empty()
    }
}

final class NoOpInternalFeatureFlagService: InternalFeatureFlagServiceAPI {
    func isEnabled(_ feature: InternalFeature) -> Bool {
        true
    }

    func enable(_ feature: InternalFeature) {}

    func enable(_ features: [InternalFeature]) {}

    func disable(_ feature: InternalFeature) {}
}

final class NoOpFeatureConfigurator: FeatureConfiguratorAPI {
    func initialize() {}

    func configuration(for feature: AppFeature) -> AppFeatureConfiguration {
        AppFeatureConfiguration(isEnabled: false)
    }

    func configuration<Feature>(
        for feature: AppFeature
    ) -> Result<Feature, FeatureConfigurationError> where Feature: Decodable {
        .failure(.missingValue)
    }
}

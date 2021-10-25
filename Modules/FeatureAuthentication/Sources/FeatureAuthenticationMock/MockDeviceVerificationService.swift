// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import Foundation

final class MockDeviceVerificationService: DeviceVerificationServiceAPI {

    // swiftlint:disable line_length
    static let validDeeplink = URL(string: "https://login.blockchain.com/#/login/eyJndWlkIjoiNzRjNzZlOTMtZWUwZi00ZjllLWJmYTYtNzE2ZTg0N2EwMmQ5IiwiZW1haWwiOiJncmF5c29uQGJsb2NrY2hhaW4uY29tIiwiaXNfbW9iaWxlX3NldHVwIjpmYWxzZSwiaGFzX2Nsb3VkX2JhY2t1cCI6ZmFsc2UsImVtYWlsX2NvZGUiOiJCcmgxa252NFh6eEg3bmZITnRzZE5uWVpWbFZvQ1BTWlBJVUNBUWIvTDB6eG1xVFg0OVNDR0QxRURhQ3FWMFJ1R3VxQ2xacHYyUjBVTldHdGdnd08rV29aZTd3SzlPUTRNWE5uZEFxdTVDQkJsQUpXaFIrWUttbTRmbVlBN25KRklpMi9MQjlsMkFpSmZuWUpMMndmUnN4czNNc0RzbGFud1lmc1c4Yyt2NVJHb3dvVk91V1BoYUZnSXZyakg4MzUifQ")!

    static let invalidDeeplink = URL(string: "https://")!
    static let deeplinkWithValidGuid = URL(string: "https://login.blockchain.com/#/login/cd76e920-7a39-4458-829a-1bb752ef628d")!

    static let mockWalletInfo = WalletInfo(
        guid: "cd76e920-7a39-4458-829a-1bb752ef628d",
        email: "test@example.com",
        emailCode: "example email code",
        isMobileSetup: false,
        hasCloudBackup: false,
        nabuInfo: nil
    )

    static let mockWalletInfoWithGuidOnly = WalletInfo(
        guid: "cd76e920-7a39-4458-829a-1bb752ef628d"
    )

    func sendDeviceVerificationEmail(
        to emailAddress: String
    ) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        // always succeed
        .just(())
    }

    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        // always succeed
        .just(())
    }

    func extractWalletInfoFromDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError> {
        if deeplink == MockDeviceVerificationService.validDeeplink {
            return .just(MockDeviceVerificationService.mockWalletInfo)
        } else if deeplink == MockDeviceVerificationService.deeplinkWithValidGuid {
            return .just(MockDeviceVerificationService.mockWalletInfoWithGuidOnly)
        } else {
            return .failure(.failToDecodeBase64Component)
        }
    }

    func pollForWalletInfo() -> AnyPublisher<WalletInfo, DeviceVerificationServiceError> {
        .just(MockDeviceVerificationService.mockWalletInfo)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAppUpgradeDomain
import FeatureAppUpgradeUI
import Foundation
import ToolKit

protocol AppUpgradeStateServiceAPI {
    var state: AnyPublisher<AppUpgradeState?, Never> { get }
}

final class AppUpgradeStateService: AppUpgradeStateServiceAPI {

    private let deviceInfo: DeviceInfo
    private let featureFetcher: FeatureFetching

    init(
        deviceInfo: DeviceInfo,
        featureFetcher: FeatureFetching
    ) {
        self.deviceInfo = deviceInfo
        self.featureFetcher = featureFetcher
    }

    var state: AnyPublisher<AppUpgradeState?, Never> {
        featureFetcher
            .fetch(for: .announcements, as: AppUpgradeData?.self)
            .replaceError(with: nil)
            .map { [deviceInfo] data in
                data
                    .flatMap { data in
                        AppUpgradeState(
                            data: data,
                            appVersion: Bundle.applicationVersion ?? "0",
                            currentOSVersion: deviceInfo.systemVersion
                        )
                    }
            }
            .eraseToAnyPublisher()
    }
}

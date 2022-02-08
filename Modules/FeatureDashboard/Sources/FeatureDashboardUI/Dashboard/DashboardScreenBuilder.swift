// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformUIKit
import ToolKit
import UIKit

public final class DashboardScreenBuilder {

    private let drawerRouter: DrawerRouting
    private let fiatBalanceCellProvider: FiatBalanceCellProviding
    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let qrCodeScannerRouter: QRCodeScannerRouting
    private let featureFlagService: FeatureFlagsServiceAPI

    public init(
        drawerRouter: DrawerRouting = resolve(),
        fiatBalanceCellProvider: FiatBalanceCellProviding = resolve(),
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        qrCodeScannerRouter: QRCodeScannerRouting = resolve(),
        featureFlagService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.drawerRouter = drawerRouter
        self.fiatBalanceCellProvider = fiatBalanceCellProvider
        self.internalFeatureFlagService = internalFeatureFlagService
        self.qrCodeScannerRouter = qrCodeScannerRouter
        self.featureFlagService = featureFlagService
    }

    public func build() -> UIViewController {
        SegmentedViewController(
            presenter: DashboardSegmentedViewScreenPresenter(
                drawerRouter: drawerRouter,
                fiatBalanceCellProvider: fiatBalanceCellProvider,
                dashboardScreenPresenter: .init(),
                qrCodeScannerRouter: qrCodeScannerRouter,
                featureFlagService: featureFlagService
            ),
            selectedSegmentBinding: .constant(0)
        )
    }
}

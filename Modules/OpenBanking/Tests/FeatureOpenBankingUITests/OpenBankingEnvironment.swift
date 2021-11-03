// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import NetworkKit
@testable import FeatureOpenBankingUI
import FeatureOpenBankingTestFixture
import ToolKit

extension OpenBankingEnvironment {

    public static func test(
        scheduler: Scheduler = .init(
            main: DispatchQueue.test.eraseToAnyScheduler()
        ),
        showTransferDetails: @escaping () -> Void = {},
        dismiss: @escaping () -> Void = {},
        openURL: @escaping (URL) -> Void = { _ in }
    ) -> (environment: OpenBankingEnvironment, network: ReplayNetworkCommunicator) {
        let (banking, network) = OpenBanking.test(using: scheduler.main)
        return (
            OpenBankingEnvironment(
                scheduler: scheduler,
                openBanking: banking,
                showTransferDetails: showTransferDetails,
                dismiss: dismiss,
                openURL: OpenURL(yield: openURL),
                fiatCurrencyFormatter: NoFormatFiatCurrencyFormatter(),
                currency: "GBP"
            ),
            network
        )
    }
}

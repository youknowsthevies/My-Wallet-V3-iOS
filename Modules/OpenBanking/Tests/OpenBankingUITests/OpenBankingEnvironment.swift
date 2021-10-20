// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineSchedulers
@testable import OpenBankingUI
import NetworkKit
import ToolKit

extension OpenBankingEnvironment {

    public static func test(
        scheduler: Scheduler = .init(
            main: DispatchQueue.test.eraseToAnyScheduler(),
            background: DispatchQueue.test.eraseToAnyScheduler()
        ),
        showTransferDetails: @escaping () -> Void = {},
        dismiss: @escaping () -> Void = {}
    ) -> (environment: OpenBankingEnvironment, network: ReplayNetworkCommunicator) {
        let (banking, network) = OpenBanking.test(using: scheduler.main)
        return (
            OpenBankingEnvironment(
                scheduler: scheduler,
                openBanking: banking,
                showTransferDetails: showTransferDetails,
                dismiss: dismiss,
                openURL: PrintAppOpen(),
                currency: "GBP"
            ),
            network
        )
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineSchedulers
import Foundation
import NetworkKit
@testable import OpenBanking

extension OpenBanking {

    static func test(_ requests: [URLRequest: Data] = [:]) -> (
        banking: OpenBanking,
        communicator: ReplayNetworkCommunicator
    ) {
        test(requests, using: DispatchQueue.immediate)
    }

    static func test<S: Scheduler>(
        _ requests: [URLRequest: Data] = [:],
        using scheduler: S
    ) -> (
        banking: OpenBanking,
        communicator: ReplayNetworkCommunicator
    ) where
        S.SchedulerTimeType == DispatchQueue.SchedulerTimeType,
        S.SchedulerOptions == DispatchQueue.SchedulerOptions
    {
        let communicator = ReplayNetworkCommunicator(requests, in: Bundle.module)
        return (
            OpenBanking(
                requestBuilder: RequestBuilder(
                    config: Network.Config(
                        scheme: "https",
                        host: "api.blockchain.info",
                        components: ["nabu-gateway"]
                    ),
                    headers: [
                        "Authorization": "Bearer Token"
                    ]
                ),
                network: NetworkAdapter(
                    communicator: communicator
                ),
                scheduler: scheduler.eraseToAnyScheduler(),
                state: .init([.currency: "GBP", .callback.base.url: "https://blockchainwallet.page.link" as URL])
            ),
            communicator
        )
    }
}

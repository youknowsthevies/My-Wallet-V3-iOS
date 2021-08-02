// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import BitcoinKit
import DIKit
import ERC20Kit
import EthereumKit
import PlatformKit
import StellarKit

extension DependencyContainer {

    public static var activityKit = module {

        factory { TransactionDetailService() as TransactionDetailServiceAPI }

        factory { ActivityServiceContainer() as ActivityServiceContaining }

        // MARK: Public

        factory { BuySellActivityItemEventService() as BuySellActivityItemEventServiceAPI }
    }
}

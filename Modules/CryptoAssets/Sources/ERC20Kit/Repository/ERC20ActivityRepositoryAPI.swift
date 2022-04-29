// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import NetworkError

public protocol ERC20ActivityRepositoryAPI {

    func transactions(
        erc20Asset: AssetModel,
        address: EthereumAddress
    ) -> AnyPublisher<[ERC20HistoricalTransaction], NetworkError>
}

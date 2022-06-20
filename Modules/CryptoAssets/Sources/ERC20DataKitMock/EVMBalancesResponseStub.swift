// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20DataKit
import MoneyKit
import PlatformKit

extension EVMBalancesResponse {

    /// Creates a stubbed ERC-20 token account.
    ///
    /// - Parameter cryptoCurrency: An ERC-20 crypto currency.
    ///
    /// - Returns: A stubbed ERC-20 token account.
    static func stubbed(cryptoCurrency: CryptoCurrency) -> EVMBalancesResponse {
        let balance = EVMBalancesResponse.Balance(
            identifier: cryptoCurrency.assetModel.kind.erc20ContractAddress!,
            amount: "2"
        )
        let item = EVMBalancesResponse.Item(
            address: "",
            balances: [balance]
        )
        return EVMBalancesResponse(
            results: [item]
        )
    }
}

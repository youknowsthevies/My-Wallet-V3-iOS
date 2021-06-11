// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public protocol BlockchainAccountFetching {
    func accounts(for currencyType: CurrencyType) -> Single<[BlockchainAccount]>
    func account(for currencyType: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount>
}

final class BlockchainAccountFetcher: BlockchainAccountFetching {

    private let blockchainAccountProvider: BlockchainAccountProviding

    init(blockchainAccountProvider: BlockchainAccountProviding = resolve()) {
        self.blockchainAccountProvider = blockchainAccountProvider
    }

    // MARK: - BlockchainAccountFetching

    func accounts(for currencyType: CurrencyType) -> Single<[BlockchainAccount]> {
        blockchainAccountProvider.accounts(for: currencyType)
    }

    func account(for currencyType: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount> {
        blockchainAccountProvider
            .account(
                for: currencyType,
                accountType: accountType
            )
    }
}

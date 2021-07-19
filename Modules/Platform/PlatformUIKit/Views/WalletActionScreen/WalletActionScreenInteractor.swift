// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

public protocol WalletActionScreenInteracting: AnyObject {
    var currency: CurrencyType { get }
    var accountType: SingleAccountType { get }
    var availableActions: Single<AvailableActions> { get }
    var balanceCellInteractor: CurrentBalanceCellInteracting { get }
}

public final class WalletActionScreenInteractor: WalletActionScreenInteracting {

    public var availableActions: Single<AvailableActions> {
        account.actions
    }

    public var accountType: SingleAccountType {
        balanceCellInteractor.accountType
    }
    public let currency: CurrencyType
    public let balanceCellInteractor: CurrentBalanceCellInteracting

    // MARK: - Private Properties

    private let account: BlockchainAccount

    // MARK: - Init

    public init(account: BlockchainAccount) {
        self.account = account
        currency = account.currencyType
        self.balanceCellInteractor = CurrentBalanceCellInteractor(
            account: account
        )
    }
}

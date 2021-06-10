// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public class LinkedBankAccount: FiatAccount, BankAccount {

    // MARK: - Public

    public var withdrawFeeAndMinLimit: Single<WithdrawalFeeAndLimit> {
        withdrawService
            .withdrawFeeAndLimit(for: fiatCurrency)
    }

    // MARK: - BlockchainAccount

    public let isDefault: Bool = false

    public var actions: Single<AvailableActions> {
        .just(.init())
    }

    public var actionableBalance: Single<MoneyValue> {
        .just(.zero(currency: fiatCurrency))
    }

    public var sourceState: Single<SourceState> {
        .just(.canTransact)
    }

    public var canWithdrawFunds: Single<Bool> {
        .just(false)
    }

    public var receiveAddress: Single<ReceiveAddress> {
        .just(BankAccountReceiveAddress(address: id, label: label))
    }

    public var balance: Single<MoneyValue> {
        .just(.zero(currency: fiatCurrency))
    }
    public var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: fiatCurrency))
    }

    public var isFunded: Single<Bool> {
        .just(false)
    }

    public let fiatCurrency: FiatCurrency
    public let id: String
    public let label: String
    public let accountNumber: String
    public let paymentType: PaymentMethodPayloadType

    // MARK: - Private Properties

    private let withdrawService: WithdrawalServiceAPI

    // MARK: - Init

    public init(label: String,
                accountNumber: String,
                accountId: String,
                currency: FiatCurrency,
                paymentType: PaymentMethodPayloadType,
                withdrawServiceAPI: WithdrawalServiceAPI = resolve()) {
        self.label = label
        self.accountNumber = accountNumber
        self.fiatCurrency = currency
        self.id = accountId
        self.paymentType = paymentType
        self.withdrawService = withdrawServiceAPI
    }

    // MARK: - BlockchainAccount

    public func balancePair(fiatCurrency: FiatCurrency) -> Observable<MoneyValuePair> {
        .just(.zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currency))
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }
}

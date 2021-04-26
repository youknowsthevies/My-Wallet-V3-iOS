//
//  LinkedBankAccount.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/20/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public class LinkedBankAccount: FiatAccount, BankAccount {
    
    // MARK: - Public
    
    public var withdrawFeeAndMinLimit: Single<WithdrawalFeeAndLimit> {
        unimplemented()
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
    public let accountType: SingleAccountType
    public let id: String
    public let label: String
    public let accountNumber: String
    public let paymentType: PaymentMethodPayloadType
    
    public init(label: String,
                accountNumber: String,
                accountId: String,
                accountType: SingleAccountType,
                currency: FiatCurrency,
                paymentType: PaymentMethodPayloadType) {
        self.label = label
        self.accountNumber = accountNumber
        self.fiatCurrency = currency
        self.accountType = accountType
        self.id = accountId
        self.paymentType = paymentType
    }
    
    // MARK: - BlockchainAccount
    
    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        .just(.zero(currency: fiatCurrency))
    }
    
    public func can(perform action: AssetAction) -> Single<Bool> {
        actions.map { $0.contains(action) }
    }
}

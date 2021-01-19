//
//  ERC20OnChainTransactionEngine.swift
//  ERC20Kit
//
//  Created by Alex McGregor on 12/1/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

final class AnyERC20OnChainTransactionEngine<Token: ERC20Token>: OnChainTransactionEngine {
    
    typealias AskForRefreshConfirmations = (Bool) -> Completable
    
    // MARK: - OnChainTransactionEngine

    var askForRefreshConfirmation: (AskForRefreshConfirmations)!
    
    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }
    
    var sourceAccount: CryptoAccount!
    var transactionTarget: TransactionTarget!
    
    let requireSecondPassword: Bool

    // MARK: - Private Properties
    
    private let feeService: AnyCryptoFeeService<EthereumTransactionFee>
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let ethereumWalletService: EthereumWalletServiceAPI
    private let priceService: PriceServiceAPI
    private let bridge: EthereumWalletBridgeAPI
    private let balanceFetching: CryptoAccountBalanceFetching
    private let erc20service: AnyERC20Service<Token>
    private var target: ERC20ReceiveAddress {
        transactionTarget as! ERC20ReceiveAddress
    }
    
    // MARK: - Init
    
    init(requireSecondPassword: Bool,
         balanceFetching: CryptoAccountBalanceFetching = { () -> CryptoAccountBalanceFetching in resolve(tag: CryptoCurrency.ethereum) }(),
         priceService: PriceServiceAPI = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
         feeService: AnyCryptoFeeService<EthereumTransactionFee> = resolve(),
         ethereumWalletService: EthereumWalletServiceAPI = resolve(),
         ethereumWalletBridgeAPI: EthereumWalletBridgeAPI = resolve(),
         erc20service: AnyERC20Service<Token> = resolve()) {
        self.balanceFetching = balanceFetching
        self.fiatCurrencyService = fiatCurrencyService
        self.feeService = feeService
        self.ethereumWalletService = ethereumWalletService
        self.requireSecondPassword = requireSecondPassword
        self.priceService = priceService
        self.bridge = ethereumWalletBridgeAPI
        self.erc20service = erc20service
    }
    
    // MARK: - OnChainTransactionEngine
    
    func assertInputsValid() {
        precondition(sourceAccount.asset.isERC20)
    }
    
    func initializeTransaction() -> Single<PendingTransaction> {
        fiatCurrencyService
            .fiatCurrency
            .map { fiatCurrency -> PendingTransaction in
                .init(
                    amount: .zero(currency: Token.assetType),
                    available: .zero(currency: Token.assetType),
                    fees: MoneyValue.zero(currency: .ethereum),
                    feeLevel: .regular,
                    selectedFiatCurrency: fiatCurrency
                )
            }
    }
    
    func start(
        sourceAccount: CryptoAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmations
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
    }
    
    func restart(transactionTarget: TransactionTarget, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultRestart(
            transactionTarget: transactionTarget,
            pendingTransaction: pendingTransaction
        )
    }
    
    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.zip(fiatAmoutAndFees(from: pendingTransaction),
                   makeFeeSelectionOption(pendingTransaction: pendingTransaction))
            .map(weak: self) { (self, input) -> [TransactionConfirmation] in
                let (values, option) = input
                let (amount, fees) = values
                return [
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label)),
                    .feedTotal(
                        .init(
                            amount: pendingTransaction.amount,
                            fee: pendingTransaction.fees,
                            exchangeAmount: amount.moneyValue,
                            exchangeFee: fees.moneyValue
                        )
                    ),
                    .feeSelection(option),
                    .description(.init())
                ]
            }
            .map { pendingTransaction.insert(confirmations: $0) }
    }
    
    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceAccount != nil else {
            return .just(pendingTransaction)
        }
        guard let crypto = amount.cryptoValue else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        guard crypto.currencyType == Token.assetType else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        return Single.zip(
            sourceAccount.actionableBalance,
            absoluteFee(with: pendingTransaction.feeLevel)
        )
        .map { (values) -> PendingTransaction in
            let (actionableBalance, fee) = values
            return pendingTransaction.update(
                amount: amount,
                available: actionableBalance,
                fees: fee.moneyValue
            )
        }
    }
    
    func doOptionUpdateRequest(pendingTransaction: PendingTransaction, newConfirmation: TransactionConfirmation) -> Single<PendingTransaction> {
        guard case let .feeSelection(value) = newConfirmation else {
            return defaultDoOptionUpdateRequest(
                pendingTransaction: pendingTransaction,
                newConfirmation: newConfirmation
            )
        }
        guard value.selectedLevel != pendingTransaction.feeLevel else {
            return defaultDoOptionUpdateRequest(
                pendingTransaction: pendingTransaction,
                newConfirmation: newConfirmation
            )
        }
        return updateFeeSelection(
            cryptoCurrency: Token.assetType,
            pendingTransaction: pendingTransaction,
            newConfirmation: value
        )
    }
    
    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientGas(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }
    
    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAddresses()
            .andThen(validateAmounts(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientGas(pendingTransaction: pendingTransaction))
            .andThen(validateNoPendingTransaction())
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }
    
    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        guard let crypto = pendingTransaction.amount.cryptoValue else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        guard let erc20value = try? ERC20TokenValue<Token>(crypto: crypto) else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        return Single.just(target)
            .map(\.address)
            .flatMap(weak: self) { (self, address) -> Single<TransactionResult> in
                self.erc20service
                    .transfer(
                        to: EthereumAddress(stringLiteral: address),
                        amount: erc20value
                    )
                    .flatMap(weak: self) { (self, candidate) -> Single<EthereumTransactionPublished> in
                        self.ethereumWalletService.send(transaction: candidate)
                    }
                    .map(\.transactionHash)
                    .map { transactionHash in
                        .hashed(txHash: transactionHash, amount: pendingTransaction.amount)
                    }
            }
    }
    
    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }
    
    // MARK: - Private Functions
    
    private func validateNoPendingTransaction() -> Completable {
        bridge
            .isWaitingOnTransaction
            .map { (isWaitingOnTransaction) -> Void in
                guard isWaitingOnTransaction == false else {
                    throw TransactionValidationFailure(state: .transactionInFlight)
                }
            }
            .asCompletable()
    }
    
    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            if try pendingTransaction.amount <= CryptoValue.zero(currency: Token.assetType).moneyValue {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
        }
    }
    
    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> Completable {
        guard sourceAccount != nil else {
            fatalError("sourceAccount should never be nil when this is called")
        }
        return sourceAccount
            .actionableBalance
            .map { (balance) -> Bool in
                if try pendingTransaction.amount > balance {
                    throw TransactionValidationFailure(state: .insufficientFunds)
                } else {
                    return true
                }
            }
            .asCompletable()
    }
    
    private func validateSufficientGas(pendingTransaction: PendingTransaction) -> Completable {
        Single.zip(ethereumAccountBalance,
                   gasLimit(isContract: true))
            .map { (balance: $0.0.moneyValue, gas: $0.1.moneyValue) }
            .map { (balance: MoneyValue, gas: MoneyValue) -> Bool in
                guard try balance > gas else {
                    throw TransactionValidationFailure(state: .insufficientGas)
                }
                return true
            }
            .asCompletable()
    }
    
    private func validateAddresses() -> Completable {
        Single.just(target)
            .map(\.address.isContractAddress)
            .map { isContractAddress -> Bool in
                // TODO: Handle contract address
                guard !isContractAddress else {
                    unimplemented()
                }
                return isContractAddress
            }
            .asCompletable()
    }
    
    private func makeFeeSelectionOption(pendingTransaction: PendingTransaction) -> Single<TransactionConfirmation.Model.FeeSelection> {
        fiatAmoutAndFees(from: pendingTransaction)
            .map { ($0.fees) }
            .map(weak: self) { (self, fees) -> TransactionConfirmation.Model.FeeSelection in
                .init(feeState: try self.getFeeState(pendingTransaction: pendingTransaction),
                      exchange: fees.moneyValue,
                      selectedFeeLevel: pendingTransaction.feeLevel,
                      customFeeAmount: .zero(currency: fees.currency),
                      availableLevels: [.regular, .priority],
                      asset: .ethereum)
            }
    }
    
    private func fiatAmoutAndFees(from pendingTransaction: PendingTransaction) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            Single.just(pendingTransaction.amount.cryptoValue ?? .zero(currency: Token.assetType)),
            Single.just(pendingTransaction.fees.cryptoValue ?? .zero(currency: Token.assetType))
        )
        .map({ (quote: ($0.0.quote.fiatValue ?? .zero(currency: .USD)), amount: $0.1, fees: $0.2) })
        .map { (quote: (FiatValue), amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convertToFiatValue(exchangeRate: quote)
            let fiatFees = fees.convertToFiatValue(exchangeRate: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }
    
    private func absoluteFee(with feeLevel: FeeLevel, isContract: Bool = false) -> Single<CryptoValue> {
        Single.zip(
            gasLimit(isContract: isContract),
            feeService.fees
        )
        .map { (gas: $0.0, ethereumTransactionFee: $0.1) }
        .map { (gas: CryptoValue, transactionFee: EthereumTransactionFee) -> CryptoValue in
            switch feeLevel {
            case .none:
                return try .etherZero + gas
            case .priority,
                 .custom:
                return try transactionFee.priority + gas
            case .regular:
                return try transactionFee.regular + gas
            }
        }
    }
    
    private func gasLimit(isContract: Bool = false) -> Single<CryptoValue> {
        feeService
            .fees
            .map { fees -> Int in
                isContract ? fees.gasLimitContract : fees.gasLimit
            }
            .map { BigUInt($0) }
            .map { value -> CryptoValue in
                guard let crypto = CryptoValue.ether(minor: "\(value)") else {
                    impossible()
                }
                return crypto
            }
    }
    
    private var ethereumAccountBalance: Single<CryptoValue> {
        balanceFetching.balance
    }
    
    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(for: self.sourceAccount.currencyType, in: fiatCurrency)
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.sourceAccount.currencyType), quote: $0) }
            }
    }
}

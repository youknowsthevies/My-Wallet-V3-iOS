//
//  TransactionInteractor.swift
//  TransactionUIKit
//
//  Created by Paulo on 13/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit
import TransactionKit

final class TransactionInteractor {

    private let coincore: Coincore
    private let availablePairsService: AvailableTradingPairsServiceAPI
    private let swapEligibilityService: EligibilityServiceAPI
    private var transactionProcessor: TransactionProcessor?

    init(coincore: Coincore = resolve(),
         availablePairsService: AvailableTradingPairsServiceAPI = resolve(),
         swapEligibilityService: EligibilityServiceAPI = resolve()) {
        self.coincore = coincore
        self.availablePairsService = availablePairsService
        self.swapEligibilityService = swapEligibilityService
    }

    func initializeTransaction(sourceAccount: SingleAccount,
                               transactionTarget: TransactionTarget,
                               action: AssetAction) -> Observable<PendingTransaction> {
        coincore
            .createTransactionProcessor(
                with: sourceAccount,
                target: transactionTarget,
                action: action
            )
            .do(onSuccess: { [weak self] transactionProcessor in
                guard let self = self else { return }
                self.transactionProcessor = transactionProcessor
            })
            .asObservable()
            .flatMap(\.initializeTransaction)
    }

    func update(amount: MoneyValue) -> Completable {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.updateAmount(amount: amount)
    }

    func getAvailableSourceAccounts(action: AssetAction) -> Single<[CryptoAccount]> {
        switch action {
        case .swap:
            let tradingPairs = availablePairsService.availableTradingPairs
            let allAccounts = coincore.allAccounts
                .map(\.accounts)
                .flatMapFilter(action: action)
                .map { accounts in
                    accounts.compactMap { account in
                        account as? CryptoAccount
                    }
                }
            return Single.zip(allAccounts, tradingPairs)
                .map { (allAccounts: [CryptoAccount], tradingPairs: [OrderPair]) -> [CryptoAccount] in
                    allAccounts.filter { account -> Bool in
                        account.isAvailableToSwapFrom(tradingPairs: tradingPairs)
                    }
                }
        default:
            preconditionFailure("Source account should be preselected for action \(action)")
        }
    }

    func getTargetAccounts(sourceAccount: CryptoAccount, action: AssetAction) -> Single<[SingleAccount]> {
        let transactionTargets = coincore.getTransactionTargets(sourceAccount: sourceAccount, action: action)
        switch action {
        case .swap:
            let tradingPairs = availablePairsService.availableTradingPairs
            let isEligible = swapEligibilityService.isEligible
            return Single.zip(transactionTargets, tradingPairs, isEligible)
                .map { (accounts: [SingleAccount], pairs: [OrderPair], isEligible: Bool) -> [SingleAccount] in
                    accounts
                        .filter { $0 is CryptoAccount }
                        .filter { pairs.contains(source: sourceAccount.currencyType, destination: $0.currencyType) }
                        .filter { isEligible || $0 is NonCustodialAccount }
                }
        default:
            return transactionTargets
        }
    }

    func verifyAndExecute(secondPassword: String) -> Single<TransactionResult> {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.execute(secondPassword: secondPassword)
    }

    func modifyOptionValue(newOption: TransactionConfirmation) -> Completable {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.set(transactionOptionValue: newOption)
    }

    func reset() {
        transactionProcessor?.reset()
    }

    var startCryptoRatePairFetch: Observable<MoneyValuePair> {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.transactionExchangeRatePair
    }

    var startFiatRatePairsFetch: Observable<TransactionMoneyValuePairs> {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.fiatExchangeRatePairs
    }

    var canTransactFiat: Bool {
        transactionProcessor?.canTransactFiat ?? false
    }

    var validateTransaction: Completable {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.validateAll()
    }

    private func invalidObservable<T>(with message: String) -> Observable<T> {
        .error(platformKitError(with: message))
    }

    private func invalidCompletable(with message: String) -> Completable {
        .just(event: .error(platformKitError(with: message)))
    }
    
    private func invalidSingle<T>(with message: String) -> Single<T> {
        .error(platformKitError(with: message))
    }

    private func platformKitError(with message: String) -> PlatformKitError {
        .illegalStateException(message: message)
    }
}

fileprivate extension Array where Element == OrderPair {
    func contains(source: CurrencyType, destination: CurrencyType) -> Bool {
        contains(where: { $0.sourceCurrencyType == source && $0.destinationCurrencyType == destination })
    }
}

fileprivate extension CryptoAccount {
    func isAvailableToSwapFrom(tradingPairs: [OrderPair]) -> Bool {
        tradingPairs.contains { pair in
            pair.sourceCurrencyType == asset
        }
    }
}

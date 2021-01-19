//
//  Coincore+TransactionKit.swift
//  TransactionKit
//
//  Created by Alex McGregor on 11/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

extension Coincore {
    
    public func createTransactionProcessor(
        with account: SingleAccount,
        target: TransactionTarget,
        action: AssetAction
    ) -> Single<TransactionProcessor> {
        switch account {
        case is CryptoNonCustodialAccount:
            return createOnChainProcessor(
                with: account as! CryptoNonCustodialAccount,
                target: target,
                action: action
            )
        case is CryptoTradingAccount:
            return createTradingProcessor(
                with: account as! CryptoTradingAccount,
                target: target,
                action: action
            )
        default:
            impossible()
        }
    }

    private func createOnChainProcessor(with account: CryptoNonCustodialAccount,
                                        target: TransactionTarget,
                                        action: AssetAction) -> Single<TransactionProcessor> {
        switch (target, action) {
        case (is CryptoAccount, .swap):
            let factory = { () -> OnChainTransactionEngineFactory in resolve(tag: account.asset) }()
            return account
                .requireSecondPassword
                .map { (requiresSecondPassword) -> TransactionProcessor in
                    .init(sourceAccount: account,
                          transactionTarget: target,
                          engine: OnChainSwapTransactionEngine(
                            quotesEngine: SwapQuotesEngine(),
                            requireSecondPassword: requiresSecondPassword,
                            onChainEngine: factory.build(requiresSecondPassword: requiresSecondPassword)
                          )
                    )
                }
        default:
            unimplemented()
        }
    }

    private func createTradingProcessor(with account: CryptoTradingAccount,
                                        target: TransactionTarget,
                                        action: AssetAction) -> Single<TransactionProcessor> {
        let engine: TransactionEngine
        switch target {
        case is CryptoReceiveAddress:
            unimplemented() // TradingToOnChainTxEngine
        case is TradingAccount:
            engine = TradingToTradingSwapTransactionEngine(
                quotesEngine: SwapQuotesEngine()
            )
        case is CryptoAccount:
            unimplemented() // TradingToOnChainTxEngine
        case is FiatAccount:
            unimplemented() // CustodialSellTxEngine
        default:
            impossible()
        }
        let processor = TransactionProcessor(
            sourceAccount: account,
            transactionTarget: target,
            engine: engine
        )
        return .just(processor)
    }
}

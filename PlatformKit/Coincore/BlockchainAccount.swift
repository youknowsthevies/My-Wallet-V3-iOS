//
//  BlockchainAccount.swift
//  PlatformKit
//
//  Created by Paulo on 29/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol TradingAccount { }

public protocol NonCustodialAccount { }

public protocol BlockchainAccount {
    var id: String { get }

    var label: String { get }

    var balance: Single<MoneyValue> { get }

    var pendingBalance: Single<MoneyValue> { get }

    var actions: Single<AvailableActions> { get }

    var isFunded: Single<Bool> { get }

    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue>
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == Array<BlockchainAccount> {
    public func flatMapFilter(action: AssetAction) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<Element.Element?>] = accounts.map { account in
                account.can(perform: action)
            }
            return Single.zip(elements)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == Array<SingleAccount> {
    public func flatMapFilter(action: AssetAction) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<Element.Element?>] = accounts.map { account in
                account.can(perform: action).map { $0 as? Element.Element }
            }
            return Single.zip(elements)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }
}

extension BlockchainAccount {
    fileprivate func can(perform action: AssetAction) -> Single<BlockchainAccount?> {
        actions.map { actions in
            actions.contains(action) ? self : nil
        }
    }
}

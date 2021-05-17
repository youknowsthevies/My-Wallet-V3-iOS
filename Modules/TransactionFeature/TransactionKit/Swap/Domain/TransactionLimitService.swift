// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

enum TransactionLimitsProduct {
    // TICKET: IOS-4657: Add a Simple Buy case 'case simpleBuy(BUY|SELL)'
    case swap(OrderDirection)
}

protocol TransactionLimitsServiceAPI {
    func fetchTransactionLimits(currency: CurrencyType,
                                networkFee: CurrencyType,
                                product: TransactionLimitsProduct) -> Single<TransactionLimits>
}

final class TransactionLimitsService: TransactionLimitsServiceAPI {

    // MARK: - Properties

    private let client: OrderTransactionLimitsClientAPI

    // MARK: - Setup

    init(client: OrderTransactionLimitsClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - TransactionLimitServiceAPI

    func fetchTransactionLimits(currency: CurrencyType,
                                networkFee: CurrencyType,
                                product: TransactionLimitsProduct) -> Single<TransactionLimits> {
        self.client
            .fetchTransactionLimits(
                currency: currency,
                networkFee: networkFee,
                product: product
            )
    }
}

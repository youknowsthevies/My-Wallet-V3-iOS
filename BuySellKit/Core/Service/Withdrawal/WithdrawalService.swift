//
//  WithdrawalService.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 19/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public protocol WithdrawalServiceAPI {
    func withdrawal(for checkout: WithdrawalCheckoutData) -> Single<Result<FiatValue, Error>>
    func withdrawalFee(for currency: FiatCurrency) -> Single<FiatValue>
}

final class WithdrawalService: WithdrawalServiceAPI {

    private let client: WithdrawalClientAPI

    init(client: WithdrawalClientAPI = resolve()) {
        self.client = client
    }

    func withdrawalFee(for currency: FiatCurrency) -> Single<FiatValue> {
        client.withdrawFee(currency: currency)
            .map { response -> CurrencyFeeResponse? in
                response.fees.first(where: { $0.symbol == currency.symbol })
            }
            .map { feeResponse -> FiatValue in
                guard let feeResponse = feeResponse,
                      let amount = Decimal(string: feeResponse.value) else {
                    return .zero(currency: currency)
                }
                return FiatValue.create(major: amount, currency: currency)
            }
    }

    func withdrawal(for checkout: WithdrawalCheckoutData) -> Single<Result<FiatValue, Error>> {
        client.withdraw(data: checkout)
            .mapToResult { (response) -> FiatValue in
                guard let amount = FiatValue.create(minor: response.amount.value, currency: checkout.currency) else {
                    fatalError("Couldn't create FiatValue from withdrawal response: \(response)")
                }
                return amount
            }
    }
}


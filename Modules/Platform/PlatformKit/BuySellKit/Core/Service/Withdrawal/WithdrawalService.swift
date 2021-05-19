// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
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
                response.fees.first(where: { $0.symbol == currency.code })
            }
            .map { feeResponse -> FiatValue in
                guard let feeResponse = feeResponse,
                      let minorValue = BigInt(feeResponse.minorValue) else {
                    return .zero(currency: currency)
                }
                return FiatValue(amount: minorValue, currency: currency)
            }
    }

    func withdrawal(for checkout: WithdrawalCheckoutData) -> Single<Result<FiatValue, Error>> {
        client.withdraw(data: checkout)
            .mapToResult { (response) -> FiatValue in
                guard let amount = FiatValue.create(major: response.amount.value, currency: checkout.currency) else {
                    fatalError("Couldn't create FiatValue from withdrawal response: \(response)")
                }
                return amount
            }
    }
}

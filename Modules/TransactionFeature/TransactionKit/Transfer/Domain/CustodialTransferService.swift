//
//  CustodialTransferService.swift
//  TransactionKit
//
//  Created by Alex McGregor on 2/3/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

struct CustodialTransferFee {
    let fee: [CurrencyType: MoneyValue]
    let minimumAmount: [CurrencyType: MoneyValue]

    subscript(fee currency: CurrencyType) -> MoneyValue {
        self.fee[currency] ?? .zero(currency: currency)
    }
    subscript(minimumAmount currency: CurrencyType) -> MoneyValue {
        self.minimumAmount[currency] ?? .zero(currency: currency)
    }
}

protocol CustodialTransferServiceAPI {
    // MARK: - Types

    typealias CustodialWithdrawalIdentifier = String

    // MARK: - Methods

    func transfer(moneyValue: MoneyValue, destination: String) -> Single<CustodialWithdrawalIdentifier>
    func fees() -> Single<CustodialTransferFee>
}

final class CustodialTransferService: CustodialTransferServiceAPI {

    // MARK: - Properties
    
    private let client: CustodialTransferClientAPI
    
    // MARK: - Setup
    
    init(client: CustodialTransferClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - CustodialTransferServiceAPI

    func transfer(moneyValue: MoneyValue, destination: String) -> Single<CustodialWithdrawalIdentifier> {
        client
            .send(transferRequest: .init(address: destination, moneyValue: moneyValue))
            .map(\.identifier)
    }

    func fees() -> Single<CustodialTransferFee> {
        client
            .custodialTransferFees()
            .map { response in
                CustodialTransferFee(
                    fee: response.fees,
                    minimumAmount: response.minAmounts
                )
            }
    }
}

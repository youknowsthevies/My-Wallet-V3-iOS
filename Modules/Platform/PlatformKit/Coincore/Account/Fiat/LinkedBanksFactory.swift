// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol LinkedBanksFactoryAPI {
    var linkedBanks: Single<[LinkedBankAccount]> { get }
    var nonWireTransferBanks: Single<[LinkedBankAccount]> { get }
    func bankPaymentMethods(for currency: FiatCurrency) -> Single<[PaymentMethodType]>
}

final class LinkedBanksFactory: LinkedBanksFactoryAPI {

    private let linkedBankService: LinkedBanksServiceAPI
    private let paymentMethodService: PaymentMethodTypesServiceAPI

    init(linkedBankService: LinkedBanksServiceAPI = resolve(),
         paymentMethodService: PaymentMethodTypesServiceAPI = resolve()) {
        self.linkedBankService = linkedBankService
        self.paymentMethodService = paymentMethodService
    }

    var linkedBanks: Single<[LinkedBankAccount]> {
        linkedBankService
            .linkedBanks
            .map { linkedBankData in
                linkedBankData.filter { $0.isActive }
            }
            .map { linkedBankData in
                linkedBankData.map { data in
                    LinkedBankAccount(
                        label: data.account?.name ?? "",
                        accountNumber: data.account?.number ?? "",
                        accountId: data.identifier,
                        currency: data.currency,
                        paymentType: data.paymentMethodType
                    )
                }
            }
    }

    var nonWireTransferBanks: Single<[LinkedBankAccount]> {
        // TICKET: IOS-4632
        linkedBankService
            .linkedBanks
            .map { banks in
                banks
                    .filter {
                        $0.isActive && $0.paymentMethodType == .bankTransfer
                    }
            }
            .map { linkedBankData in
                linkedBankData.map { data in
                    // TICKET: IOS-4632
                    LinkedBankAccount(
                        label: data.account?.name ?? "",
                        accountNumber: data.account?.number ?? "",
                        accountId: data.identifier,
                        currency: data.currency,
                        paymentType: data.paymentMethodType
                    )
                }
            }
    }

    func bankPaymentMethods(for currency: FiatCurrency) -> Single<[PaymentMethodType]> {
        paymentMethodService
            .paymentMethodTypes
            .map { $0.filter { $0.method == .bankAccount(.fiat(currency)) || $0.method == .bankTransfer(.fiat(currency)) } }
    }
}

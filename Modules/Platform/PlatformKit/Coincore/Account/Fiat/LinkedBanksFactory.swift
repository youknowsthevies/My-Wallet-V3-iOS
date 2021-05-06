// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol LinkedBanksFactoryAPI {
    var linkedBanks: Single<[LinkedBankAccount]> { get }
    var nonWireTransferBanks: Single<[LinkedBankAccount]> { get }
}

final class LinkedBanksFactory: LinkedBanksFactoryAPI {
    
    private let linkedBankService: LinkedBanksServiceAPI
    
    init(linkedBankService: LinkedBanksServiceAPI = resolve()) {
        self.linkedBankService = linkedBankService
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
                        paymentType: .bankAccount
                    )
                }
            }
    }
    
    var nonWireTransferBanks: Single<[LinkedBankAccount]> {
        // TODO: Filter for the correct payment method type.
        // TICKET: IOS-4632
        linkedBankService
            .linkedBanks
            .map { linkedBankData in
                linkedBankData.filter { $0.isActive }
            }
            .map { linkedBankData in
                linkedBankData.map { data in
                    // TICKET: IOS-4632
                    LinkedBankAccount(
                        label: data.account?.name ?? "",
                        accountNumber: data.account?.number ?? "",
                        accountId: data.identifier,
                        currency: data.currency,
                        paymentType: .bankAccount
                    )
                }
            }
    }
}

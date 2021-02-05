//
//  InternalTransferService.swift
//  TransactionKit
//
//  Created by Alex McGregor on 2/3/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

protocol InternalTransferServiceAPI {
    func transfer(moneyValue: MoneyValue, destination: String) -> Single<CustodialWithdrawalResponse>
}

final class InternalTransferService: InternalTransferServiceAPI {
    
    // MARK: - Properties
    
    private let client: InternalTransferClientAPI
    
    // MARK: - Setup
    
    init(client: InternalTransferClientAPI = resolve()) {
        self.client = client
    }
    
    // MARK: - InternalTransferServiceAPI
    
    func transfer(moneyValue: MoneyValue, destination: String) -> Single<CustodialWithdrawalResponse> {
        client.send(transferRequest: .init(address: destination, moneyValue: moneyValue))
    }
}

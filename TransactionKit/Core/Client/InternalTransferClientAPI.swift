//
//  InternalTransferClientAPI.swift
//  TransactionKit
//
//  Created by Alex McGregor on 2/3/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

/// This is for transfering or sending custodial funds to
/// a non-custodial wallet
protocol InternalTransferClientAPI {
    /// A `403` means an internal send is pending.
    /// A `409` means you have insufficient funds for the internal send.
    // TODO: `CustodialWithdrawalResponse` should either be renamed or
    // reduced to just an identifier
    func send(transferRequest: InternalTransferRequest) -> Single<CustodialWithdrawalResponse>
}

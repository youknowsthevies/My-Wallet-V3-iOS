//
//  InternalTransferError.swift
//  TransactionKit
//
//  Created by Alex McGregor on 2/3/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum InternalTransferError: Error {
    case transferBalanceLocked
    case transferAlreadyPending
    case insufficientFunds
    case unexpectedError
}

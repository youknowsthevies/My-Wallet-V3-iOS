//
//  TransactionConfirmationModelable.swift
//  TransactionKit
//
//  Created by Paulo on 17/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol TransactionConfirmationModelable: Hashable {
    var type: TransactionConfirmation.Kind { get }
    var formatted: (String, String)? { get }
}

extension TransactionConfirmationModelable {

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

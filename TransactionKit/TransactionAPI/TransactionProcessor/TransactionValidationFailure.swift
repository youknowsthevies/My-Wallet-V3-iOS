//
//  TransactionValidationFailure.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct TransactionValidationFailure: Error {
    public let state: TransactionValidationState
    
    public init(state: TransactionValidationState) {
        self.state = state
    }
}

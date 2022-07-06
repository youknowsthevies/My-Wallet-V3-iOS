// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol TransactionConfirmation {
    var id: UUID { get }
    var type: TransactionConfirmationKind { get }
    var formatted: (title: String, subtitle: String)? { get }
}

extension TransactionConfirmations {
    static func areEqual(_ lhs: [TransactionConfirmation], _ rhs: [TransactionConfirmation]) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        if Swift.zip(lhs, rhs).contains(where: { $0.0.id != $0.1.id }) {
            return false
        }
        return true
    }
}

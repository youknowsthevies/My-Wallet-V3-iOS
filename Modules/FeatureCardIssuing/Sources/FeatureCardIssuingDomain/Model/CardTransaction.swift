// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct CardTransaction: Decodable, Identifiable, Equatable {

    public enum Status: String, Decodable {
        case pending = "PENDING"
        case failed = "FAILED"
        case settled = "SETTLED"
    }

    public let id: String
    public let value: Money
    public let date: Date
    public let status: Status
    public let merchantName: String
    public let errorDescription: String?

    public init(
        id: String,
        value: Money,
        date: Date,
        status: CardTransaction.Status,
        merchantName: String,
        errorDescription: String? = nil
    ) {
        self.id = id
        self.value = value
        self.date = date
        self.status = status
        self.merchantName = merchantName
        self.errorDescription = errorDescription
    }
}

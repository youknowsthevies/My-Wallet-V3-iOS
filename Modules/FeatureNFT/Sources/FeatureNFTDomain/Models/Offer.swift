// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Offer {
    let devSellerFeeBasisPoints: Int
    let identifier: Int
    let createdDate: String
    let bidAmount: String
    let collectionSlug: String
    let contractAddress: String
    let eventType: String
    let quantity: String

    public init(
        devSellerFeeBasisPoints: Int,
        identifier: Int,
        createdDate: String,
        bidAmount: String,
        collectionSlug: String,
        contractAddress: String,
        eventType: String,
        quantity: String
    ) {
        self.devSellerFeeBasisPoints = devSellerFeeBasisPoints
        self.identifier = identifier
        self.createdDate = createdDate
        self.bidAmount = bidAmount
        self.collectionSlug = collectionSlug
        self.contractAddress = contractAddress
        self.eventType = eventType
        self.quantity = quantity
    }
}

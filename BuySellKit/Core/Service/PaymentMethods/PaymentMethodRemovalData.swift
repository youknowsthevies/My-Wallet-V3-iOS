//
//  PaymentMethodRemovalData.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 23/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

public struct PaymentMethodRemovalData {
    public enum MethodType {
        case card
        case beneficiary(Beneficiary.AccountType)
    }
    public let id: String
    public let title: String
    public let description: String
    public let image: String
    public let event: AnalyticsEvents.SimpleBuy
    public let type: MethodType

    public init(id: String,
                title: String,
                description: String,
                image: String,
                event: AnalyticsEvents.SimpleBuy,
                type: MethodType) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.event = event
        self.type = type
    }
}

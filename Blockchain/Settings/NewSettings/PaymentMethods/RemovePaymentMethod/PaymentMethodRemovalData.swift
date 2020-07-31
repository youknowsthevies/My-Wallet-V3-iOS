//
//  PaymentMethodRemovalData.swift
//  Blockchain
//
//  Created by Daniel on 30/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import ToolKit

struct PaymentMethodRemovalData {
    let id: String
    let title: String
    let description: String
    let image: String
    let event: AnalyticsEvents.SimpleBuy
    
    init(cardData: CardData) {
        id = cardData.identifier
        title = cardData.type.name
        description = "•••• \(cardData.suffix)"
        image = cardData.type.thumbnail ?? "icon-card"
        event = .sbRemoveCard
    }
    
    init(beneficiary: Beneficiary) {
        id = beneficiary.identifier
        title = beneficiary.name
        description = beneficiary.account
        image = "icon-bank"
        event = .sbRemoveBank
    }
}

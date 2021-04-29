// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BuySellKit
import ToolKit

extension PaymentMethodRemovalData {

    init(cardData: CardData) {
        self.init(
            id: cardData.identifier,
            title: cardData.type.name,
            description: "•••• \(cardData.suffix)",
            image: cardData.type.thumbnail ?? "icon-card",
            event: .sbRemoveCard,
            type: .card
        )
    }
    
    init(beneficiary: Beneficiary) {
        self.init(
            id: beneficiary.identifier,
            title: beneficiary.name,
            description: beneficiary.account,
            image: "icon-bank",
            event: .sbRemoveBank,
            type: .beneficiary(beneficiary.type)
        )
    }
}

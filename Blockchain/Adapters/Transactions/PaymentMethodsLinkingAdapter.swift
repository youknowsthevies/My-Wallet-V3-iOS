// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsUI
import FeatureTransactionUI

final class PaymentMethodsLinkingAdapter {

    private let cardLinker: CardLinkerAPI

    init(cardLinker: CardLinkerAPI = resolve()) {
        self.cardLinker = cardLinker
    }
}

extension PaymentMethodsLinkingAdapter: FeatureSettingsUI.PaymentMethodsLinkerAPI {

    func routeToCardLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        cardLinker.presentCardLinkingFlow(from: viewController) { _ in
            completion()
        }
    }
}

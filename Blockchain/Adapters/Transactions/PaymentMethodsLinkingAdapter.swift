// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsUI
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import UIKit

protocol PaymentMethodsLinkingAdapterAPI {

    /// Presents a screen where the user can select a linkable payment method among a list of eligible payment methods.
    /// The user is then redirected to a flow to actually link the selected payment method.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    )

    /// Presents the flow to link a credit or debit card to the user's account.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToCardLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    )

    /// Presents the flow to link a bank account to the user's account via Open Banking or ACH.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToBankLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    )

    /// Presents a screen showing bank wiring instructions to the user so that they can manually send funds to their Blockchain account.
    /// The bank account from which the user sends the funds will be linked to the user's Blockchain account available for withdrawals.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToWiringInstructionsFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    )
}

extension PaymentMethodsLinkingAdapterAPI {

    /// Presents a screen where the user can select a linkable payment method among a list of eligible payment methods.
    /// The user is then redirected to a flow to actually link the selected payment method.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        routeToPaymentMethodLinkingFlow(from: viewController, filter: { _ in true }, completion: completion)
    }
}

final class PaymentMethodsLinkingAdapter: PaymentMethodsLinkingAdapterAPI {

    private let router: PaymentMethodLinkingRouterAPI

    init(router: FeatureTransactionUI.PaymentMethodLinkingRouterAPI = resolve()) {
        self.router = router
    }

    func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        router.routeToPaymentMethodLinkingFlow(from: viewController, filter: filter, completion: completion)
    }

    func routeToBankLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        router.routeToBankLinkingFlow(from: viewController, completion: completion)
    }

    func routeToCardLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        router.routeToCardLinkingFlow(from: viewController, completion: completion)
    }

    func routeToWiringInstructionsFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        router.routeToWiringInstructionsFlow(for: currency, from: viewController, completion: completion)
    }
}

// MARK: - FeatureSettingsUI.PaymentMethodsLinkerAPI

extension PaymentMethodsLinkingAdapter: FeatureSettingsUI.PaymentMethodsLinkerAPI {

    func presentAccountLinkingFlow(
        from viewController: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping () -> Void
    ) {
        routeToPaymentMethodLinkingFlow(from: viewController, filter: filter) { _ in
            completion()
        }
    }

    func routeToBankWiringIntructions(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        routeToWiringInstructionsFlow(for: currency, from: viewController) { _ in
            completion()
        }
    }

    func routeToCardLinkingFlow(from viewController: UIViewController, completion: @escaping () -> Void) {
        routeToCardLinkingFlow(from: viewController) { _ in
            completion()
        }
    }

    func routeToBankLinkingFlow(from viewController: UIViewController, completion: @escaping () -> Void) {
        routeToBankLinkingFlow(from: viewController) { _ in
            completion()
        }
    }
}

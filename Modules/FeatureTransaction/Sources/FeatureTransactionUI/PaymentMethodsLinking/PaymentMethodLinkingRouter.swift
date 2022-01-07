// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import ToolKit
import UIKit

public enum PaymentMethodsLinkingFlowResult {
    case abandoned
    case completed
}

/// Use this protocol to present the end-to-end payment method linking flow (where the user selects which payment method to link among their linkable payment methods) and links it.
/// This protocol also provides methods to present each individual payment method linking flow directly, by-passing the selection screen.
public protocol PaymentMethodLinkingRouterAPI {

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

extension PaymentMethodLinkingRouterAPI {

    /// Presents a screen where the user can select a linkable payment method among a list of eligible payment methods.
    /// The user is then redirected to a flow to actually link the selected payment method.
    /// - NOTE: It's your responsability to dismiss the presented flow upon completion!
    public func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        routeToPaymentMethodLinkingFlow(from: viewController, filter: { _ in true }, completion: completion)
    }
}

final class PaymentMethodLinkingRouter: PaymentMethodLinkingRouterAPI {

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let paymentMethodsLinker: PaymentMethodLinkerAPI
    private let bankAccountLinker: BankAccountLinkerAPI
    private let bankWireLinker: BankWireLinkerAPI
    private let cardLinker: CardLinkerAPI

    private var cancellables = Set<AnyCancellable>()

    init(
        featureFlagsService: FeatureFlagsServiceAPI,
        paymentMethodsLinker: PaymentMethodLinkerAPI = PaymentMethodLinker(),
        bankAccountLinker: BankAccountLinkerAPI = BankAccountLinker(),
        bankWireLinker: BankWireLinkerAPI = BankWireLinker(),
        cardLinker: CardLinkerAPI = CardLinker()
    ) {
        self.featureFlagsService = featureFlagsService
        self.paymentMethodsLinker = paymentMethodsLinker
        self.bankAccountLinker = bankAccountLinker
        self.bankWireLinker = bankWireLinker
        self.cardLinker = cardLinker
    }

    func routeToPaymentMethodLinkingFlow(
        from viewController: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        paymentMethodsLinker.presentAccountLinkingFlow(from: viewController, filter: filter) { [weak self] result in
            viewController.dismiss(animated: true) {
                guard let self = self else { return }
                switch result {
                case .abandoned:
                    completion(.abandoned)

                case .completed(let paymentMethod):
                    switch paymentMethod.type {
                    case .card:
                        self.routeToCardLinkingFlow(from: viewController, completion: completion)

                    case .bankTransfer:
                        self.routeToBankLinkingFlow(from: viewController, completion: completion)

                    case .bankAccount:
                        switch paymentMethod.fiatCurrency {
                        case .USD:
                            self.routeToBankLinkingFlow(from: viewController, completion: completion)
                        case .GBP, .EUR:
                            self.featureFlagsService
                                .isEnabled(.remote(.openBanking))
                                .if(
                                    then: {
                                        self.routeToBankLinkingFlow(from: viewController, completion: completion)
                                    },
                                    else: {
                                        self.routeToWiringInstructionsFlow(
                                            for: paymentMethod.fiatCurrency,
                                            from: viewController,
                                            completion: completion
                                        )
                                    }
                                )
                                .store(in: &self.cancellables)
                        default:
                            self.routeToWiringInstructionsFlow(
                                for: paymentMethod.fiatCurrency,
                                from: viewController,
                                completion: completion
                            )
                        }

                    case .funds(let data):
                        self.routeToWiringInstructionsFlow(
                            for: data.fiatCurrency ?? .locale,
                            from: viewController,
                            completion: completion
                        )
                    }
                }
            }
        }
    }

    func routeToBankLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        bankAccountLinker.presentBankLinkingFlow(from: viewController) { result in
            let flowResult: PaymentMethodsLinkingFlowResult = result == .abandoned ? .abandoned : .completed
            completion(flowResult)
        }
    }

    func routeToCardLinkingFlow(
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        cardLinker.presentCardLinkingFlow(from: viewController) { result in
            let flowResult: PaymentMethodsLinkingFlowResult = result == .abandoned ? .abandoned : .completed
            completion(flowResult)
        }
    }

    func routeToWiringInstructionsFlow(
        for currency: FiatCurrency,
        from viewController: UIViewController,
        completion: @escaping (PaymentMethodsLinkingFlowResult) -> Void
    ) {
        bankWireLinker.present(from: viewController) {
            completion(.abandoned) // cannot end any other way
        }
    }
}

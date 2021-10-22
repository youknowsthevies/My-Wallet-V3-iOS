// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureSettingsUI
import FeatureTransactionUI
import OpenBanking
import OpenBankingUI
import PlatformKit
import PlatformUIKit

struct FiatCurrencyFormatter: OpenBankingUI.FiatCurrencyFormatter {

    func displayString(amountMinor: String, currency: String) -> String? {
        guard
            let currency = FiatCurrency(rawValue: currency),
            let fiat = FiatValue.create(minor: amountMinor, currency: currency)
        else { return nil }
        return fiat.displayString
    }
}

extension OpenBankingUI.OpenBankingViewController: StartOpenBanking {

    public static func link(
        _ data: BankLinkageData,
        currency: FiatCurrency,
        listener: LinkBankListener
    ) -> UIViewController {

        let viewController = OpenBankingViewController(
            environment: OpenBankingEnvironment(
                showTransferDetails: {
                    (resolve() as AppCoordinating).showFundTrasferDetails(fiatCurrency: currency, isOriginDeposit: true)
                },
                dismiss: {
                    listener.closeFlow(isInteractive: false)
                },
                currency: currency.code
            )
        )

        let navigationController = UINavigationController(rootViewController: viewController)

        viewController.event$.sink { [weak navigationController] event in
            switch event {
            case .linked:
                navigationController?.dismiss(animated: true) {
                    listener.updateBankLinked()
                }
            default:
                fatalError("\(event)")
            }
        }
        .store(withLifetimeOf: viewController)

        return navigationController
    }

    public static func pay(amountMinor: String, currency: FiatCurrency) -> UIViewController {
        fatalError("not yet implemented")
    }
}

struct PresentAccountLinkingFlowAdapter: PresentAccountLinkingFlow {

    let base: PaymentMethodLinkerAPI = resolve()

    func presentAccountLinkingFlow(
        from presenter: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (PresentAccountLinkingFlowCompletion) -> Void
    ) {
        base.presentAccountLinkingFlow(from: presenter, filter: filter) { result in
            switch result {
            case .abandoned: completion(.dismiss)
            case .completed(let method): completion(.select(method))
            }
        }
    }
}

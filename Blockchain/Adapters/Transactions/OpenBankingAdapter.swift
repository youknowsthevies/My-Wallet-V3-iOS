// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureOpenBankingDomain
import FeatureOpenBankingUI
import FeatureSettingsUI
import FeatureTransactionUI
import MoneyKit
import PlatformKit
import PlatformUIKit

struct FiatCurrencyFormatter: FeatureOpenBankingUI.FiatCurrencyFormatter {

    func displayString(amountMinor: String, currency: String) -> String? {
        guard
            let currency = FiatCurrency(rawValue: currency),
            let fiat = FiatValue.create(minor: amountMinor, currency: currency)
        else { return nil }
        return fiat.displayString
    }
}

extension FeatureOpenBankingUI.OpenBankingViewController: StartOpenBanking {

    convenience init(
        account: OpenBanking.BankAccount,
        currency: FiatCurrency,
        listener: LinkBankListener,
        app: AppCoordinating = resolve()
    ) {
        self.init(
            account: account,
            environment: OpenBankingEnvironment(
                showTransferDetails: {
                    app.showFundTrasferDetails(fiatCurrency: currency, isOriginDeposit: true)
                },
                dismiss: {
                    listener.closeFlow(isInteractive: false)
                },
                currency: currency.code
            )
        )
    }

    public static func link(
        account data: BankLinkageData,
        currency: FiatCurrency,
        listener: LinkBankListener
    ) -> UIViewController {

        let viewController = OpenBankingViewController(
            account: .init(data),
            currency: currency,
            listener: listener
        )

        let navigationController = UINavigationController(rootViewController: viewController)

        viewController.eventPublisher.sink { [weak navigationController] event in
            switch event {
            case .failure:
                break
            case .success:
                navigationController?.dismiss(animated: true) {
                    listener.updateBankLinked()
                }
            }
        }
        .store(withLifetimeOf: viewController)

        return navigationController
    }
}

struct AccountLinkingFlowPresenter: AccountLinkingFlowPresenterAPI {

    let base: PaymentMethodLinkerAPI = resolve()

    func presentAccountLinkingFlow(
        from presenter: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (AccountLinkingFlowPresenterCompletion) -> Void
    ) {
        base.presentAccountLinkingFlow(from: presenter, filter: filter) { result in
            switch result {
            case .abandoned:
                completion(.dismiss)
            case .completed(let method):
                completion(.select(method))
            }
        }
    }
}

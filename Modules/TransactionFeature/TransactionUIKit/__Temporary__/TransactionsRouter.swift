// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

public enum TransactionFlowResult {
    case abandoned
    case completed
}

public protocol TransactionsRouterAPI {
    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<TransactionFlowResult, Never>
}

public final class TransactionsRouter: TransactionsRouterAPI {

    private enum CrytoSelectionResult {
        case abandoned
        case select(CryptoCurrency)
    }

    private let cryptoCurrenciesService: CryptoCurrenciesServiceAPI
    private let kycService: KYCTiersServiceAPI

    private var buyRouter: PlatformUIKit.Router! // reference stored otherwise the app crashes for some reason 😕

    public init(
        cryptoCurrenciesService: CryptoCurrenciesServiceAPI = resolve(),
        kycService: KYCTiersServiceAPI = resolve()
    ) {
        self.cryptoCurrenciesService = cryptoCurrenciesService
        self.kycService = kycService
    }

    public func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<TransactionFlowResult, Never> {
        // Step 1. check SDD eligibility to understand which flow to show next
        checkSDDElibility()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] userIsSDDEligible -> AnyPublisher<TransactionFlowResult, Never> in
                guard let self = self else {
                    unexpectedDeallocation()
                }
                guard userIsSDDEligible else {
                    // Step 2 (non-SDD eligible). Step Present present simple buy flow
                    return self.presentSimpleBuyScreen(from: presenter)
                }
                // NOTE: right now the user locale is used to determine the fiat currency to use here but eventually we'll ask the user to provide that like we do for simple buy (IOS-4819)
                let fiatCurrency: FiatCurrency = .locale
                // Step 2a. present currency selection screen
                return self.presentCryptoCurrencySelectionScreen(from: presenter, fiatCurrency: fiatCurrency)
                    .flatMap { [weak self] result -> AnyPublisher<TransactionFlowResult, Never> in
                        guard let self = self else {
                            unexpectedDeallocation()
                        }
                        // Step 2b. present buy flow screen for selected crypto and locale's fiat currency
                        guard case let .select(cryptoCurrency) = result else {
                            return .just(.abandoned)
                        }
                        return self.presentBuyScreen(
                            from: presenter,
                            targetCurrency: cryptoCurrency,
                            sourceCurrency: fiatCurrency
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func checkSDDElibility() -> AnyPublisher<Bool, Never> {
        kycService.checkSimplifiedDueDiligenceEligibility()
            .asPublisher()
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    private func presentCryptoCurrencySelectionScreen(
        from presenter: UIViewController,
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<CrytoSelectionResult, Never> {
        let publisher = PassthroughSubject<CrytoSelectionResult, Never>()
        presenter.present(
            NavigationView {
                CryptoCurrencySelectionView(
                    store: Store(
                        initialState: CryptoCurrencySelectionState(),
                        reducer: cryptoCurrencySelectionReducer,
                        environment: CryptoCurrencySelectionEnvironment(
                            mainQueue: .main,
                            close: {
                                publisher.send(.abandoned)
                                publisher.send(completion: .finished)
                            },
                            select: { selectedCryptoCurrency in
                                publisher.send(.select(selectedCryptoCurrency))
                            },
                            loadCryptoCurrencies: { [cryptoCurrenciesService] in
                                cryptoCurrenciesService.fetchPurchasableCryptoCurrencies(using: fiatCurrency)
                            }
                        )
                    )
                )
                .updateNavigationBarStyle()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        )
        return publisher.eraseToAnyPublisher()
    }

    private func presentSimpleBuyScreen(from presenter: UIViewController) -> AnyPublisher<TransactionFlowResult, Never> {
        // This is just levereging the existing buy flow, which isn't great but is getting replaced buy the new `Transactions` implementation
        return self.presentBuyScreen(
            from: presenter,
            targetCurrency: .bitcoin, // not important for simple buy
            sourceCurrency: .locale, // not imporant for simple buy
            isSDDEligible: false
        )
    }

    private func presentBuyScreen(
        from presenter: UIViewController,
        targetCurrency: CryptoCurrency,
        sourceCurrency: FiatCurrency,
        isSDDEligible: Bool = true
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        // This is just levereging the existing buy flow, which isn't great but is getting replaced buy the new `Transactions` implementation
        let presentBuy = {
            let builder = PlatformUIKit.Builder(
                stateService: PlatformUIKit.StateService()
            )
            self.buyRouter = PlatformUIKit.Router(builder: builder, currency: targetCurrency)
            if isSDDEligible {
                // setup and manually start otherwise the StateService gets in an odd state and the navigation gets messed-up
                self.buyRouter.setup(startImmediately: false)
                self.buyRouter.next(to: .buy)
            } else {
                self.buyRouter.start()
            }
        }

        // The current buy flow implementation is too complex to modify to get a callback
        // so, for now, dimiss any previously presented and present the buy flow. Then return an empty publisher.
        if presenter.presentedViewController != nil {
            presenter.dismiss(animated: true, completion: presentBuy)
        } else {
            presentBuy()
        }
        return Empty(completeImmediately: true)
            .eraseToAnyPublisher()
    }
}

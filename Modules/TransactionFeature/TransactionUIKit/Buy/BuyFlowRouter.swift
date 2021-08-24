// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit
import TransactionKit

protocol BuyFlowRouting: Routing {

    func start(from presenter: UIViewController, with currency: CryptoCurrency?)
}

final class BuyFlowRouter: RIBs.Router<BuyFlowInteractor>, BuyFlowRouting {

    private let alertPresenter: AlertViewPresenterAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private var cancellables = Set<AnyCancellable>()

    init(
        interactor: BuyFlowInteractor,
        alertPresenter: AlertViewPresenterAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.alertPresenter = alertPresenter
        self.loadingViewPresenter = loadingViewPresenter
        super.init(interactor: interactor)
    }

    func start(from presenter: UIViewController, with currency: CryptoCurrency?) {
        presentLoadingView()
        let currencyPublisher: AnyPublisher<CryptoCurrency, BuyFlowInteractor.Error> = .just(currency ?? .coin(.bitcoin))
        currencyPublisher
            .flatMap { [interactor] cryptoCurrency in
                Publishers.Zip(
                    // Attempt to convert the passed-in cryptoCurrency into a destination account
                    interactor.fetchDefaultAccount(for: cryptoCurrency),
                    // Plus get payment methods so we can display the enter amount screen directly
                    interactor.fetchPaymentAccounts(for: cryptoCurrency, amount: .zero(currency: cryptoCurrency))
                )
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    // Show an alert if we encounter a problem
                    guard case .failure(let error) = completion else {
                        return
                    }
                    self?.dismissLoadingView()
                    self?.presentError(error: error, from: presenter)
                },
                receiveValue: { [weak self] cryptoAccount, paymentMethods in
                    // Payment methods should never come back as empty, but if they did, the flow would show an account selector.
                    self?.dismissLoadingView()
                    self?.presentTransactionFlow(
                        from: presenter,
                        source: paymentMethods.first,
                        destination: cryptoAccount
                    )
                }
            )
            .store(in: &cancellables)
    }

    private func dismissLoadingView() {
        loadingViewPresenter.hide()
    }

    private func presentLoadingView() {
        loadingViewPresenter.showCircular()
    }

    private func presentError(error: Error, from presenter: UIViewController) {
        alertPresenter.notify(
            content: .init(
                title: LocalizationConstants.Errors.genericError,
                message: String(describing: error)
            ),
            in: presenter
        )
    }

    private func presentTransactionFlow(from presenter: UIViewController, source: BlockchainAccount?, destination: TransactionTarget?) {
        let builder = TransactionFlowBuilder()
        let router = builder.build(
            withListener: interactor,
            action: .buy,
            sourceAccount: source,
            target: destination
        )
        attachChild(router)
        let viewController = router.viewControllable.uiviewController
        presenter.present(viewController, animated: true)
    }
}

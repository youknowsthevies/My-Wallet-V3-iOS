// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import PlatformKit
import PlatformUIKit
import RIBs
import SwiftUI
import ToolKit

/// Represents all types of transactions the user can perform
public enum TransactionFlowAction: Equatable {

    // Restores an existing order.
    case order(OrderDetails)
    /// Performs a buy. If `CryptoAccount` is `nil`, the users will be presented with a crypto currency selector.
    case buy(CryptoAccount?)
    /// Performs a sell. If `CryptoCurrency` is `nil`, the users will be presented with a crypto currency selector.
    case sell(CryptoAccount?)
    /// Performs a swap. If `CryptoCurrency` is `nil`, the users will be presented with a crypto currency selector.
    case swap(CryptoAccount?)
    /// Performs an interest transfer.
    case interestTransfer(CryptoInterestAccount)
    /// Performs an interest withdraw.
    case interestWithdraw(CryptoInterestAccount)

    case sign(sourceAccount: CryptoAccount, destination: TransactionTarget)

    public static func == (lhs: TransactionFlowAction, rhs: TransactionFlowAction) -> Bool {
        switch (lhs, rhs) {
        case (.buy(let lhsAccount), .buy(let rhsAccount)),
             (.sell(let lhsAccount), .sell(let rhsAccount)),
             (.swap(let lhsAccount), .swap(let rhsAccount)):
            return lhsAccount?.identifier == rhsAccount?.identifier
        case (.interestTransfer(let lhsAccount), .interestTransfer(let rhsAccount)):
            return lhsAccount.identifier == rhsAccount.identifier
        case (.interestWithdraw(let lhsAccount), .interestWithdraw(let rhsAccount)):
            return lhsAccount.identifier == rhsAccount.identifier
        case (.order(let lhsOrder), .order(let rhsOrder)):
            return lhsOrder.identifier == rhsOrder.identifier
        case (.sign(let lhsAccount, let lhsDestination), .sign(let rhsAccount, let rhsDestination)):
            return lhsAccount.identifier == rhsAccount.identifier
                && lhsDestination.label == rhsDestination.label
        default:
            return false
        }
    }
}

/// Represents the possible outcomes of going through the transaction flow
public enum TransactionFlowResult: Equatable {
    case abandoned
    case completed
}

/// A protocol defining the API for the app's entry point to any `Transaction Flow`.
/// NOTE: Presenting a Transaction Flow can never fail because it's expected for any error to be handled within the flow. Non-recoverable errors should force the user to abandon the flow.
public protocol TransactionsRouterAPI {

    /// Some APIs may not have UIKit available. In this instance we use
    /// `TopMostViewControllerProviding`.
    func presentTransactionFlow(
        to action: TransactionFlowAction
    ) -> AnyPublisher<TransactionFlowResult, Never>

    func presentTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never>
}

internal final class TransactionsRouter: TransactionsRouterAPI {

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let pendingOrdersService: PendingOrderDetailsServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let kycRouter: PlatformUIKit.KYCRouting
    private let alertViewPresenter: AlertViewPresenterAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let loadingViewPresenter: LoadingViewPresenting
    private let legacyBuyRouter: LegacyBuyFlowRouting
    private var legacySellRouter: LegacySellRouter?
    private let buyFlowBuilder: BuyFlowBuildable
    private let sellFlowBuilder: SellFlowBuildable
    private let signFlowBuilder: SignFlowBuildable

    private lazy var tabSwapping: TabSwapping = resolve()
    private let interestFlowBuilder: InterestTransactionBuilder

    // Since RIBs need to be attached to something but we're not, the router in use needs to be retained.
    private var currentRIBRouter: RIBs.Routing?

    init(
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        pendingOrdersService: PendingOrderDetailsServiceAPI = resolve(),
        kycRouter: PlatformUIKit.KYCRouting = resolve(),
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        loadingViewPresenter: LoadingViewPresenting = LoadingViewPresenter(),
        legacyBuyRouter: LegacyBuyFlowRouting = LegacyBuyFlowRouter(),
        buyFlowBuilder: BuyFlowBuildable = BuyFlowBuilder(analyticsRecorder: resolve()),
        sellFlowBuilder: SellFlowBuildable = SellFlowBuilder(),
        signFlowBuilder: SignFlowBuildable = SignFlowBuilder(),
        interestFlowBuilder: InterestTransactionBuilder = InterestTransactionBuilder(),
        eligibilityService: EligibilityServiceAPI = resolve()
    ) {
        self.featureFlagsService = featureFlagsService
        self.kycRouter = kycRouter
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.alertViewPresenter = alertViewPresenter
        self.loadingViewPresenter = loadingViewPresenter
        self.pendingOrdersService = pendingOrdersService
        self.legacyBuyRouter = legacyBuyRouter
        self.buyFlowBuilder = buyFlowBuilder
        self.sellFlowBuilder = sellFlowBuilder
        self.signFlowBuilder = signFlowBuilder
        self.interestFlowBuilder = interestFlowBuilder
        self.eligibilityService = eligibilityService
    }

    func presentTransactionFlow(
        to action: TransactionFlowAction
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        guard let viewController = topMostViewControllerProvider.topMostViewController else {
            fatalError("Expected a UIViewController")
        }
        return presentTransactionFlow(to: action, from: viewController)
    }

    func presentTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        switch action {
        case .buy:
            return presentBuyTransactionFlow(to: action, from: presenter)
        case .sell, .order:
            return featureFlagsService.isEnabled(.remote(.sellUsingTransactionFlowEnabled))
                .receive(on: DispatchQueue.main)
                .handleLoaderForLifecycle(loader: loadingViewPresenter)
                .flatMap { [weak self] isEnabled -> AnyPublisher<TransactionFlowResult, Never> in
                    guard let self = self else { return .empty() }
                    if isEnabled {
                        return self.presentNewTransactionFlow(action, from: presenter)
                    } else {
                        return self.presentLegacyTransactionFlow(action, from: presenter)
                    }
                }
                .eraseToAnyPublisher()

        case .swap,
             .interestTransfer,
             .interestWithdraw,
             .sign:
            return presentNewTransactionFlow(action, from: presenter)
        }
    }

    private func presentBuyTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        eligibilityService.eligibility()
            .receive(on: DispatchQueue.main)
            .handleLoaderForLifecycle(loader: loadingViewPresenter)
            .flatMap { [weak self, loadingViewPresenter] eligibility -> AnyPublisher<TransactionFlowResult, Error> in
                guard let self = self else { return .empty() }
                if eligibility.simpleBuyPendingTradesEligible {
                    let checkPendingOrders = self.pendingOrdersService.pendingOrderDetails
                        .asPublisher()
                    return self.featureFlagsService.isEnabled(.remote(.useTransactionsFlowToBuyCrypto))
                        .setFailureType(to: Error.self)
                        .zip(checkPendingOrders)
                        .receive(on: DispatchQueue.main)
                        .flatMap { [weak self] isEnabled, orders -> AnyPublisher<TransactionFlowResult, Never> in
                            guard let self = self else { return .empty() }
                            guard isEnabled else {
                                return self.presentLegacyTransactionFlow(action, from: presenter)
                            }
                            let isAwaitingAction = orders.filter(\.isAwaitingAction)
                            if let order = isAwaitingAction.first {
                                return self.pendingOrdersService.cancel(order)
                                    .receive(on: DispatchQueue.main)
                                    .handleLoaderForLifecycle(loader: loadingViewPresenter)
                                    .flatMap {
                                        self.presentNewTransactionFlow(action, from: presenter)
                                    }
                                    .catch { _ in
                                        self.presentTooManyPendingOrders(
                                            count: eligibility.maxPendingDepositSimpleBuyTrades,
                                            from: presenter
                                        )
                                    }
                                    .eraseToAnyPublisher()
                            } else {
                                return self.presentNewTransactionFlow(action, from: presenter)
                            }
                        }
                        .eraseToAnyPublisher()
                } else {
                    return self.presentTooManyPendingOrders(
                        count: eligibility.maxPendingDepositSimpleBuyTrades,
                        from: presenter
                    )
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                }
            }
            .catch { [weak self] _ -> AnyPublisher<TransactionFlowResult, Never> in
                guard let self = self else { return .empty() }
                return self.presentTooManyPendingOrdersError(from: presenter)
            }
            .eraseToAnyPublisher()
    }
}

extension TransactionsRouter {

    // since we're not attaching a RIB to a RootRouter we have to retain the router and manually activate it
    private func mimicRIBAttachment(router: RIBs.Routing) {
        currentRIBRouter?.interactable.deactivate()
        currentRIBRouter = router
        router.load()
        router.interactable.activate()
    }
}

extension TransactionsRouter {

    private func presentNewTransactionFlow(
        _ action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        switch action {
        case .interestWithdraw(let cryptoAccount):
            let listener = InterestTransactionInteractor(transactionType: .withdraw(cryptoAccount))
            let router = interestFlowBuilder.buildWithInteractor(listener)
            router.start()
            mimicRIBAttachment(router: router)
            return listener.publisher
        case .interestTransfer(let cryptoAccount):
            let listener = InterestTransactionInteractor(transactionType: .transfer(cryptoAccount))
            let router = interestFlowBuilder.buildWithInteractor(listener)
            router.start()
            mimicRIBAttachment(router: router)
            return listener.publisher
        case .buy(let cryptoAccount):
            let listener = BuyFlowListener(
                kycRouter: kycRouter,
                alertViewPresenter: alertViewPresenter
            )
            let interactor = BuyFlowInteractor()
            let router = buyFlowBuilder.build(with: listener, interactor: interactor)
            router.start(with: cryptoAccount, order: nil, from: presenter)
            mimicRIBAttachment(router: router)
            return listener.publisher
        case .order(let order):
            let listener = BuyFlowListener(
                kycRouter: kycRouter,
                alertViewPresenter: alertViewPresenter
            )
            let interactor = BuyFlowInteractor()
            let router = buyFlowBuilder.build(with: listener, interactor: interactor)
            router.start(with: nil, order: order, from: presenter)
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .sell(let cryptoAccount):
            let listener = SellFlowListener()
            let interactor = SellFlowInteractor()
            let router = sellFlowBuilder.build(with: listener, interactor: interactor)
            router.start(with: cryptoAccount, from: presenter)
            mimicRIBAttachment(router: router)
            return listener.publisher

        case .swap(let cryptoAccount):
            let listener = SwapRootInteractor()
            let builder = TransactionFlowBuilder()
            let router = builder.build(
                withListener: listener,
                action: .swap,
                sourceAccount: cryptoAccount,
                target: nil
            )
            presenter.present(router.viewControllable.uiviewController, animated: true)
            mimicRIBAttachment(router: router)
            return .empty()

        case .sign(let sourceAccount, let destination):
            let listener = SignFlowListener()
            let interactor = SignFlowInteractor()
            let router = signFlowBuilder.build(with: listener, interactor: interactor)
            router.start(sourceAccount: sourceAccount, destination: destination, presenter: presenter)
            mimicRIBAttachment(router: router)
            return listener.publisher
        }
    }

    private func presentTooManyPendingOrders(
        count: Int,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        let subject = PassthroughSubject<TransactionFlowResult, Never>()

        func dismiss() {
            presenter.dismiss(animated: true) {
                subject.send(.abandoned)
            }
        }

        presenter.present(
            NavigationView {
                TooManyPendingOrdersView(
                    count: count,
                    viewActivityAction: { [tabSwapping] in
                        tabSwapping.switchToActivity()
                        dismiss()
                    },
                    okAction: dismiss
                )
                .whiteNavigationBarStyle()
                .trailingNavigationButton(.close, action: dismiss)
            }
        )
        return subject.eraseToAnyPublisher()
    }

    private func presentTooManyPendingOrdersError(
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        let subject = PassthroughSubject<TransactionFlowResult, Never>()

        func dismiss() {
            presenter.dismiss(animated: true) {
                subject.send(.abandoned)
            }
        }

        presenter.present(
            NavigationView {
                TooManyPendingOrdersErrorView(
                    okAction: dismiss
                )
                .whiteNavigationBarStyle()
                .trailingNavigationButton(.close, action: dismiss)
            }
        )
        return subject.eraseToAnyPublisher()
    }

    private func presentLegacyTransactionFlow(
        _ action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        switch action {
        case .buy(let cryptoAccount):
            guard let cryptoAccount = cryptoAccount else {
                return legacyBuyRouter.presentBuyFlowWithTargetCurrencySelectionIfNecessary(
                    from: presenter
                )
            }
            return legacyBuyRouter.presentBuyScreen(
                from: presenter,
                targetCurrency: cryptoAccount.asset,
                isSDDEligible: true
            )

        case .order:
            return legacyBuyRouter.presentBuyFlowWithTargetCurrencySelectionIfNecessary(
                from: presenter
            )

        case .sell:
            let accountSelectionService = AccountSelectionService()
            let interactor = SellRouterInteractor(
                accountSelectionService: accountSelectionService
            )
            let builder = PlatformUIKit.SellBuilder(
                accountSelectionService: accountSelectionService,
                routerInteractor: interactor
            )
            legacySellRouter = PlatformUIKit.LegacySellRouter(builder: builder)
            legacySellRouter?.load()
            return .just(.abandoned)

        case .swap,
             .interestTransfer,
             .interestWithdraw,
             .sign:
            unimplemented("There is no legacy swap flow.")
        }
    }
}

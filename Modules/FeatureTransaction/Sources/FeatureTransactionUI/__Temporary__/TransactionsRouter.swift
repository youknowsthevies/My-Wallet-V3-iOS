// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import PlatformKit
import PlatformUIKit
import RIBs
import ToolKit

/// Represents all types of transactions the user can perform
public enum TransactionFlowAction: Equatable {

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
    private let kycRouter: PlatformUIKit.KYCRouting
    private let alertViewPresenter: AlertViewPresenterAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let loadingViewPresenter: LoadingViewPresenting
    private let legacyBuyRouter: LegacyBuyFlowRouting
    private var legacySellRouter: LegacySellRouter?
    private let buyFlowBuilder: BuyFlowBuildable
    private let sellFlowBuilder: SellFlowBuilder
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
        sellFlowBuilder: SellFlowBuilder = SellFlowBuilder(),
        interestFlowBuilder: InterestTransactionBuilder = InterestTransactionBuilder()
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
        self.interestFlowBuilder = interestFlowBuilder
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
            loadingViewPresenter.showCircular()
            // NOTE: This check for pending orders is a hack. Handling pending orders in Transaction Flow requires more planning.
            // The work required will be scoped in IOS-5575. In the meantime pending orders can be handled by the legacy flow.
            // Handling orders in the legacy flow unblocks IOS-5368 and the release of this feature.
            let checkPendingOrders = pendingOrdersService.pendingOrderDetails
                .asPublisher()
                .replaceError(with: nil)
            return featureFlagsService.isEnabled(.local(.useTransactionsFlowToBuyCrypto))
                .zip(checkPendingOrders)
                .receive(on: DispatchQueue.main)
                .flatMap { [weak self, loadingViewPresenter] tuple -> AnyPublisher<TransactionFlowResult, Never> in
                    loadingViewPresenter.hide()
                    let (isEnabled, pendingOrder) = tuple
                    if isEnabled, pendingOrder == nil {
                        return self?.presentNewTransactionFlow(action, from: presenter) ?? .empty()
                    } else {
                        return self?.presentLegacyTransactionFlow(action, from: presenter) ?? .empty()
                    }
                }
                .eraseToAnyPublisher()

        case .sell:
            loadingViewPresenter.showCircular()
            return featureFlagsService.isEnabled(.remote(.sellUsingTransactionFlowEnabled))
                .receive(on: DispatchQueue.main)
                .flatMap { [weak self, loadingViewPresenter] isEnabled -> AnyPublisher<TransactionFlowResult, Never> in
                    loadingViewPresenter.hide()
                    if isEnabled {
                        return self?.presentNewTransactionFlow(action, from: presenter) ?? .empty()
                    } else {
                        return self?.presentLegacyTransactionFlow(action, from: presenter) ?? .empty()
                    }
                }
                .eraseToAnyPublisher()

        case .swap,
             .interestTransfer,
             .interestWithdraw:
            return presentNewTransactionFlow(action, from: presenter)
        }
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
                alertViewPresenter: alertViewPresenter,
                loadingViewPresenter: loadingViewPresenter
            )
            let interactor = BuyFlowInteractor()
            let router = buyFlowBuilder.build(with: listener, interactor: interactor)
            router.start(with: cryptoAccount, from: presenter)
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
        }
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
             .interestWithdraw:
            unimplemented("There is no legacy swap flow.")
        }
    }
}

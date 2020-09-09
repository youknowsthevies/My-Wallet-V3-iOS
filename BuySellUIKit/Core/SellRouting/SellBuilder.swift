//
//  SellBuilder.swift
//  BuySellUIKit
//
//  Created by Daniel on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import DIKit

/// Provides an API for building sell components
public protocol SellBuilderAPI: AnyObject {
    
    var routerInteractor: SellRouterInteractor { get }
    
    /// Start of `Sell` if the user has not completed KYC.
    func sellIdentityIntroductionViewController() -> UIViewController
    
    /// Start of `Sell`. Builds the account selection screen.
    func accountSelectionViewController() -> UIViewController
    
    /// Builds the fiat account selection screen.
    func fiatAccountSelectionViewController() -> UIViewController
    
    /// Builds and provides a sell crypto VIP stack, based on `EnterAmountScreenViewController`.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func sellCryptoViewController(data: SellCryptoInteractionData) -> UIViewController
    
    /// Builds and provides a checkout VIP stack.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func checkoutScreenViewController(data: CheckoutData) -> UIViewController
    
    /// Builds and provides a pending VIP stack.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func pendingScreenViewController(for orderDetails: OrderDetails) -> UIViewController
    
    /// Builds and provides a transfer cancellation VIP stack.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func transferCancellationViewController(data: CheckoutData) -> UIViewController
}

/// Builds sell components
public final class SellBuilder: SellBuilderAPI {
    
    // MARK: - Properties
    
    private let kycServiceProvider: KYCServiceProviderAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let recorderProvider: RecordingProviderAPI
    private let userInformationProvider: UserInformationServiceProviding
    private let exchangeProvider: ExchangeProviding
    private let balanceProvider: BalanceProviding
    private let buySellServiceProvider: BuySellKit.ServiceProviderAPI
    public let routerInteractor: SellRouterInteractor
    
    // MARK: - Setup
    
    public init(routerInteractor: SellRouterInteractor,
                kycServiceProvider: KYCServiceProviderAPI,
                analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
                recorderProvider: RecordingProviderAPI = resolve(),
                userInformationProvider: UserInformationServiceProviding = resolve(),
                buySellServiceProvider: BuySellKit.ServiceProviderAPI,
                exchangeProvider: ExchangeProviding = resolve(),
                balanceProvider: BalanceProviding) {
        self.kycServiceProvider = kycServiceProvider
        self.analyticsRecorder = analyticsRecorder
        self.recorderProvider = recorderProvider
        self.userInformationProvider = userInformationProvider
        self.buySellServiceProvider = buySellServiceProvider
        self.exchangeProvider = exchangeProvider
        self.balanceProvider = balanceProvider
        self.routerInteractor = routerInteractor
    }
    
    // MARK: - SellBuilderAPI
    
    public func accountSelectionViewController() -> UIViewController {
        let interactor = AccountPickerScreenInteractor(
            singleAccountsOnly: false,
            action: .sell,
            selectionService: buySellServiceProvider.accountSelectionService
        )
        let presenter = AccountPickerScreenPresenter(
            interactor: interactor,
            headerModel: nil,
            navigationModel: ScreenNavigationModel.AccountPicker.modal,
            shouldDismissOnSelection: false
        )
        return AccountPickerScreenModalViewController(presenter: presenter)
    }
    
    public func fiatAccountSelectionViewController() -> UIViewController {
        let interactor = AccountPickerScreenInteractor(
            singleAccountsOnly: false,
            action: .deposit,
            selectionService: buySellServiceProvider.accountSelectionService
        )
        let presenter = AccountPickerScreenPresenter(
            interactor: interactor,
            headerModel: nil,
            navigationModel: ScreenNavigationModel.AccountPicker.modal,
            shouldDismissOnSelection: false
        )
        return AccountPickerScreenModalViewController(presenter: presenter)
    }
    
    public func sellCryptoViewController(data: SellCryptoInteractionData) -> UIViewController {
        let cryptoSelectionService = CryptoCurrencySelectionService(
            service: buySellServiceProvider.supportedPairsInteractor,
            defaultSelectedData: data.source.currencyType.cryptoCurrency!
        )
        let interactor = SellCryptoScreenInteractor(
            kycTiersService: kycServiceProvider.tiers,
            eligibilityService: buySellServiceProvider.eligibility,
            data: data,
            exchangeProvider: exchangeProvider,
            balanceProvider: balanceProvider,
            fiatCurrencyService: userInformationProvider.settings,
            cryptoCurrencySelectionService: cryptoSelectionService,
            initialActiveInput: .fiat,
            orderCreationService: buySellServiceProvider.orderCreation
        )
        let presenter = SellCryptoScreenPresenter(
            analyticsRecorder: analyticsRecorder,
            interactor: interactor,
            routerInteractor: routerInteractor,
            backwardsNavigation: { [weak routerInteractor] () -> Void in
                routerInteractor?.previousRelay.accept(())
            }
        )
        let viewController = EnterAmountScreenViewController(presenter: presenter)
        return viewController
    }
    
    public func sellIdentityIntroductionViewController() -> UIViewController {
        let presenter = SellIdentityIntroductionPresenter(interactor: routerInteractor)
        let controller = SellIdentityIntroductionViewController(presenter: presenter)
        return controller
    }
    
    public func pendingScreenViewController(for orderDetails: OrderDetails) -> UIViewController {
        let interactor = PendingOrderStateScreenInteractor(
            orderDetails: orderDetails,
            service: buySellServiceProvider.orderCompletion
        )
        let presenter = PendingOrderStateScreenPresenter(
            routingInteractor: SellPendingOrderRoutingInteractor(interactor: routerInteractor),
            analyticsRecorder: recorderProvider.analytics,
            interactor: interactor
        )
        let viewController = PendingStateViewController(
            presenter: presenter
        )
        return viewController
    }
    
    public func transferCancellationViewController(data: CheckoutData) -> UIViewController {
        let interactor = TransferCancellationInteractor(
            checkoutData: data,
            cancellationService: buySellServiceProvider.orderCancellation
        )
        
        let presenter = TransferCancellationScreenPresenter(
            routingInteractor: SellTransferCancellationRoutingInteractor(
                routingInteractor: routerInteractor,
                analyticsRecording: recorderProvider.analytics
            ),
            currency: data.outputCurrency,
            analyticsRecorder: recorderProvider.analytics,
            interactor: interactor
        )
        let viewController = TransferCancellationViewController(presenter: presenter)
        return viewController
    }
    
    public func checkoutScreenViewController(data: CheckoutData) -> UIViewController {
        let orderInteractor = SellOrderCheckoutInteractor(
            fundsAndBankInteractor: .init(
                paymentAccountService: buySellServiceProvider.paymentAccount,
                orderQuoteService: buySellServiceProvider.orderQuote,
                orderCreationService: buySellServiceProvider.orderCreation
            )
        )
        let interactor = CheckoutScreenInteractor(
            confirmationService: buySellServiceProvider.orderConfirmation,
            cancellationService: buySellServiceProvider.orderCancellation,
            orderCheckoutInterator: orderInteractor,
            checkoutData: data
        )
        let presenter = CheckoutScreenPresenter(
            checkoutRouting: SellCheckoutRoutingInteractor(
                analyticsRecorder: recorderProvider.analytics,
                interactor: routerInteractor
            ),
            contentReducer: SellCheckoutContentReducer(data: data),
            analyticsRecorder: recorderProvider.analytics,
            interactor: interactor
        )
        let viewController = DetailsScreenViewController(presenter: presenter)
        return viewController
    }
}


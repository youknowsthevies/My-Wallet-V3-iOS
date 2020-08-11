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
    
    /// Builds and provides a sell crypto VIP stack, based on `EnterAmountScreenViewController`.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func sellCryptoViewController(data: SellCryptoInteractionData) -> UIViewController
}

/// Builds sell components
public final class SellBuilder: SellBuilderAPI {
    
    // MARK: - Properties
    
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let recorderProvider: RecordingProviderAPI
    private let userInformationProvider: UserInformationServiceProviding
    private let exchangeProvider: ExchangeProviding
    private let balanceProvider: BalanceProviding
    private let buySellServiceProvider: BuySellKit.ServiceProviderAPI
    public let routerInteractor: SellRouterInteractor
    
    // MARK: - Setup
    
    public init(routerInteractor: SellRouterInteractor,
                analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
                recorderProvider: RecordingProviderAPI = resolve(),
                userInformationProvider: UserInformationServiceProviding = resolve(),
                buySellServiceProvider: BuySellKit.ServiceProviderAPI,
                exchangeProvider: ExchangeProviding = resolve(),
                balanceProvider: BalanceProviding) {
        self.analyticsRecorder = analyticsRecorder
        self.recorderProvider = recorderProvider
        self.userInformationProvider = userInformationProvider
        self.buySellServiceProvider = buySellServiceProvider
        self.exchangeProvider = exchangeProvider
        self.balanceProvider = balanceProvider
        self.routerInteractor = routerInteractor
    }
    
    // MARK: - SellBuilderAPI
    
    public func sellCryptoViewController(data: SellCryptoInteractionData) -> UIViewController {
        let cryptoSelectionService = CryptoCurrencySelectionService(
            service: buySellServiceProvider.supportedPairsInteractor,
            defaultSelectedData: data.source.currencyType.cryptoCurrency!
        )
        let interactor = SellCryptoScreenInteractor(
            data: data,
            exchangeProvider: exchangeProvider,
            balanceProvider: balanceProvider,
            fiatCurrencyService: userInformationProvider.settings,
            cryptoCurrencySelectionService: cryptoSelectionService,
            initialActiveInput: .fiat
        )
        let presenter = SellCryptoScreenPresenter(
            analyticsRecorder: analyticsRecorder,
            interactor: interactor,
            backwardsNavigation: { [weak routerInteractor] () -> Void in
                routerInteractor?.previousRelay.accept(())
            }
        )
        let viewController = EnterAmountScreenViewController(presenter: presenter)
        return viewController
    }
}


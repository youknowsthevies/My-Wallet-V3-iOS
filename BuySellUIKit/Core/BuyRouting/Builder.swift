//
//  Builder.swift
//  BuySellUIKit
//
//  Created by Daniel on 22/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit
import RxSwift
import BuySellKit
import PlatformKit
import PlatformUIKit
import ToolKit

public protocol Buildable: AnyObject {
    
    var stateService: StateServiceAPI { get }
    
    func fundsTransferDetailsViewController() -> Single<UIViewController>
    func fundsTransferDetailsViewController(for fiatCurrency: FiatCurrency, isOriginDeposit: Bool) -> UIViewController
}

public final class Builder: Buildable {
    
    public let stateService: StateServiceAPI
    
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let serviceProvider: ServiceProviderAPI
    private let recordingProvider: RecordingProviderAPI
    
    public init(fiatCurrencyService: FiatCurrencyServiceAPI,
                serviceProvider: ServiceProviderAPI,
                stateService: StateServiceAPI,
                recordingProvider: RecordingProviderAPI) {
        self.fiatCurrencyService = fiatCurrencyService
        self.serviceProvider = serviceProvider
        self.stateService = stateService
        self.recordingProvider = recordingProvider
    }
    
    /// Generates and returns the `DetailsScreenViewController` for funds transfer
    /// The screen matches the wallet's currency
    /// - Returns: `Single<UIViewController>`
    public func fundsTransferDetailsViewController() -> Single<UIViewController> {
        fiatCurrencyService.fiatCurrency
            .map(weak: self) { (self, fiatCurrency) in
                self.fundsTransferDetailsViewController(for: fiatCurrency, isOriginDeposit: false)
            }
    }
    
    /// Generates and returns the `DetailsScreenViewController` for funds transfer
    /// - Parameter fiatCurrency: The fiat currency for which the transfer details will be retrieved
    /// - Returns: A `DetailsScreenViewController` that shows the funds transfer details
    public func fundsTransferDetailsViewController(for fiatCurrency: FiatCurrency, isOriginDeposit: Bool) -> UIViewController {
        let interactor = InteractiveFundsTransferDetailsInteractor(
            paymentAccountService: self.serviceProvider.paymentAccount,
            fiatCurrency: fiatCurrency
        )
        
        let navigationController = UINavigationController()
        
        let webViewRouter = WebViewRouter(
            topMostViewControllerProvider: navigationController
        )
        
        let presenter = FundsTransferDetailScreenPresenter(
            webViewRouter: webViewRouter,
            analyticsRecorder: self.recordingProvider.analytics,
            interactor: interactor,
            stateService: self.stateService,
            isOriginDeposit: isOriginDeposit
        )
        let viewController = DetailsScreenViewController(presenter: presenter)
        navigationController.viewControllers = [viewController]
        return navigationController
    }
}

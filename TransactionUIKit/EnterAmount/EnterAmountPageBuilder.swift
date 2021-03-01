//
//  EnterAmountPageBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit
import UIKit

protocol EnterAmountPageBuildable {
    func build(listener: EnterAmountPageListener, sourceAccount: SingleAccount, action: AssetAction) -> EnterAmountPageRouter
}

final class EnterAmountPageBuilder: EnterAmountPageBuildable {

    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let transactionModel: TransactionModel
    private let priceService: PriceServiceAPI
    private let analyticsEventRecorder: AnalyticsEventRecorderAPI

    public init(transactionModel: TransactionModel,
                priceService: PriceServiceAPI = resolve(),
                fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
                exchangeProvider: ExchangeProviding = resolve(),
                analyticsEventRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.priceService = priceService
        self.analyticsEventRecorder = analyticsEventRecorder
        self.transactionModel = transactionModel
        self.fiatCurrencyService = fiatCurrencyService
    }

    func build(listener: EnterAmountPageListener, sourceAccount: SingleAccount, action: AssetAction) -> EnterAmountPageRouter {
        let displayBundle = DisplayBundle.bundle(for: action, sourceAccount: sourceAccount)
        let defaultCryptoCurrency: CryptoCurrency = sourceAccount.currencyType.cryptoCurrency!

        let initialActiveInput: ActiveAmountInput
        switch action {
        case .swap,
             .send:
            initialActiveInput = .fiat
        default:
            unimplemented()
        }
        let amountTranslationInteractor = AmountTranslationInteractor(
            fiatCurrencyService: fiatCurrencyService,
            cryptoCurrencyService: DefaultCryptoCurrencyService(currencyType: sourceAccount.currencyType),
            priceProvider: AmountTranslationPriceProvider(transactionModel: transactionModel),
            defaultCryptoCurrency: defaultCryptoCurrency,
            initialActiveInput: initialActiveInput
        )

        let amountTranslationPresenter = AmountTranslationPresenter(
            interactor: amountTranslationInteractor,
            analyticsRecorder: analyticsEventRecorder,
            displayBundle: displayBundle.amountDisplayBundle,
            inputTypeToggleVisiblity: .visible
        )
        
        let amountViewProvider = {
            AmountTranslationView(presenter: amountTranslationPresenter)
        }

        let digitPadViewModel = provideDigitPadViewModel()
        let continueButtonViewModel = ButtonViewModel.primary(with: LocalizationConstants.Transaction.next)
        let topSelectionButtonViewModel = SelectionButtonViewModel(showSeparator: true)

        let viewController = EnterAmountViewController(
            displayBundle: displayBundle,
            devicePresenterType: DevicePresenter.type,
            digitPadViewModel: digitPadViewModel,
            continueButtonViewModel: continueButtonViewModel,
            topSelectionButtonViewModel: topSelectionButtonViewModel,
            amountViewProvider: amountViewProvider
        )
        
        let interactor = EnterAmountPageInteractor(
            transactionModel: transactionModel,
            presenter: viewController,
            amountInteractor: amountTranslationInteractor,
            action: action
        )
        interactor.listener = listener
        let router = EnterAmountPageRouter(interactor: interactor,
                                           viewController: viewController)
        return router
    }

    // MARK: - Private methods

    private func provideDigitPadViewModel() -> DigitPadViewModel {
        let highlightColor = Color.black.withAlphaComponent(0.08)
        let model = DigitPadButtonViewModel(
            content: .label(text: MoneyValueInputScanner.Constant.decimalSeparator, tint: .titleText),
            background: .init(highlightColor: highlightColor)
        )
        return DigitPadViewModel(
            padType: .number,
            customButtonViewModel: model,
            contentTint: .titleText,
            buttonHighlightColor: highlightColor
        )
    }
}

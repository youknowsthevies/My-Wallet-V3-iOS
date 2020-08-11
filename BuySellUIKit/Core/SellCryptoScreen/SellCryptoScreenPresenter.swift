//
//  SellCryptoScreenPresenter.swift
//  BuySellUIKit
//
//  Created by Daniel on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import ToolKit
import RxSwift
import RxRelay
import RxCocoa

final class SellCryptoScreenPresenter: EnterAmountScreenPresenter {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.SellCryptoScreen
    
    // MARK: - Properties
    
    private let auxiliaryViewPresenter: SendAuxililaryViewPresenter
    private let interactor: SellCryptoScreenInteractor
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(uiUtilityProvider: UIUtilityProviderAPI = UIUtilityProvider.default,
         analyticsRecorder: AnalyticsEventRecorderAPI,
         interactor: SellCryptoScreenInteractor,
         backwardsNavigation: @escaping () -> Void) {
        self.interactor = interactor
        auxiliaryViewPresenter = SendAuxililaryViewPresenter(
            interactor: interactor.auxiliaryViewInteractor,
            availableBalanceTitle: LocalizedString.available,
            maxButtonTitle: LocalizedString.useMax
        )
        super.init(
            uiUtilityProvider: uiUtilityProvider,
            analyticsRecorder: analyticsRecorder,
            backwardsNavigation: backwardsNavigation,
            displayBundle: .sell(cryptoCurrency: interactor.data.source.currencyType.cryptoCurrency!),
            interactor: interactor
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topSelectionButtonViewModel.isButtonEnabledRelay.accept(false)
        topSelectionButtonViewModel.trailingImageViewContentRelay.accept(.empty)
        bottomAuxiliaryViewModelStateRelay.accept(.maxAvailable(auxiliaryViewPresenter))
        topSelectionButtonViewModel.titleRelay.accept(
            String(format: LocalizedString.from, interactor.data.source.currencyType.code)
        )
        topSelectionButtonViewModel.subtitleRelay.accept(
            String(format: LocalizedString.to, interactor.data.destination.currencyType.code)
        )
    }
}

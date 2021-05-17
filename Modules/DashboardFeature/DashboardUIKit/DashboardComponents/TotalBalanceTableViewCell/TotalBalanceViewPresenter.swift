// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit

final class TotalBalanceViewPresenter {

    // MARK: - Properties

    let titleContent = LabelContent(
        text: LocalizationConstants.Dashboard.Balance.totalBalance,
        font: .main(.medium, 16),
        color: .mutedText,
        accessibility: .init(
            id: .value(Accessibility.Identifier.Dashboard.TotalBalanceCell.titleLabel)
        )
    )

    // MARK: - Services

    let balancePresenter: AssetPriceViewPresenter
    let pieChartPresenter: AssetPieChartPresenter

    private let interactor: TotalBalanceViewInteractor

    // MARK: - Setup

    init(balanceProvider: BalanceProviding,
         balanceChangeProvider: BalanceChangeProviding,
         enabledCurrenciesService: EnabledCurrenciesServiceAPI) {
        let balanceInteractor = BalanceChangeViewInteractor(
            balanceProvider: balanceProvider,
            balanceChangeProvider: balanceChangeProvider
        )
        let chartInteractor = AssetPieChartInteractor(
            balanceProvider: balanceProvider,
            currencyTypes: enabledCurrenciesService.allEnabledCurrencyTypes
        )
        pieChartPresenter = AssetPieChartPresenter(
            edge: 88,
            interactor: chartInteractor
        )
        balancePresenter = AssetPriceViewPresenter(
            interactor: balanceInteractor,
            descriptors: .balance
        )
        interactor = TotalBalanceViewInteractor(
            chartInteractor: chartInteractor,
            balanceInteractor: balanceInteractor
        )
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import ToolKit
import DIKit
import Combine

final class PreferencesSectionPresenter: SettingsSectionPresenting {
    
    // MARK: - SettingsSectionPresenting
    
    let sectionType: SettingsSectionType = .preferences
    
    var state: Observable<SettingsSectionLoadingState>
    
    private let emailNotificationsCellPresenter: EmailNotificationsSwitchCellPresenter
    private let preferredCurrencyCellPresenter: PreferredCurrencyCellPresenter
    
    init(
        emailNotificationService: EmailNotificationSettingsServiceAPI,
        preferredCurrencyBadgeInteractor: PreferredCurrencyBadgeInteractor,
        featureFlagService: FeatureFlagsServiceAPI = resolve()
    ) {
        emailNotificationsCellPresenter = .init(service: emailNotificationService)
        preferredCurrencyCellPresenter = .init(interactor: preferredCurrencyBadgeInteractor)
        
        var viewModel = SettingsSectionViewModel(
            sectionType: sectionType,
            items: [
                .init(cellType: .switch(.emailNotifications, emailNotificationsCellPresenter)),
                .init(cellType: .badge(.currencyPreference, preferredCurrencyCellPresenter)),
            ]
        )
        
        state = featureFlagService.isEnabled(.remote(.applePay))
            .last()
            .map { notificationSettingsEnabled -> SettingsSectionLoadingState in
                
                let notificationSettingsCell: SettingsCellViewModel = .init(cellType: .common(.notifications))
                if notificationSettingsEnabled && viewModel.items.contains(notificationSettingsCell) == false {
                    viewModel.items.append(notificationSettingsCell)
                }
                return .loaded(next: .some(viewModel))
            }
            .asObservable()
    }
}

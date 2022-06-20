// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import RxSwift
import ToolKit

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
                .init(cellType: .badge(.currencyPreference, preferredCurrencyCellPresenter))
            ]
        )

        state = featureFlagService
            .isEnabled(AppFeature.notificationPreferences)
            .last()
            .map { notificationPreferencesEnabled -> SettingsSectionLoadingState in
                let notificationPreferencesCell: SettingsCellViewModel = .init(cellType: .common(.notifications))
                if notificationPreferencesEnabled, viewModel.items.contains(notificationPreferencesCell) == false {
                    viewModel.items.append(notificationPreferencesCell)
                    viewModel.items.remove(at: 0)
                }
                return .loaded(next: .some(viewModel))
            }
            .asObservable()
    }
}

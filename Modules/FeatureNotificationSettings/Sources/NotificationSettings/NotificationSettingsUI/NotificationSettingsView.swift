//
//  FeatureNotificationSettingsView.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 08/04/2022.
//

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI
import FeatureNotificationSettingsDomain
import Mocks
import FeatureNotificationSettingsData

struct FeatureNotificationSettingsView: View {
    var store: Store<NotificationSettingsState, NotificationSettingsAction>
    @ObservedObject var viewStore: ViewStore<NotificationSettingsState, NotificationSettingsAction>
    
    init(store: Store<NotificationSettingsState,NotificationSettingsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                optionsSection
                Spacer()
            }
            .navigationRoute(in: store)
            .onAppear(perform: {
                viewStore.send(.onAppear)
            })
        }
    }
}

extension FeatureNotificationSettingsView {
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Wallet Activity")
                .typography(.title3)
            Text("Get notified about important activity like buys, sells, transfers and rewards")
                .typography(.paragraph1)
                .foregroundColor(Color.WalletSemantic.body)
            
        }
        .padding(.horizontal, Spacing.padding3)
    }
    
    
    var optionsSection: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment:.leading, spacing: 10) {
                if let notificationPreferences = viewStore.notificationPrefrences {
                    ForEach(notificationPreferences) { notificationPreference in
                        PrimaryRow(
                            title: notificationPreference.title,
                            subtitle: notificationPreference.preferenceDescription,
                            trailing: { Icon.chevronRight
                                    .frame(width: 24, height: 24)
                                    .accentColor(.semantic.muted)
                            },
                            action: {
                                viewStore.send(.route(.navigate(to: .showDetails(notificationPreference: notificationPreference))))
                            })
                    }
                }
            }
            .padding(.top, 0)
        }
    }
}

struct FeatureNotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let notificationPrefences: [NotificationPreference] = [
            MockGenerator.transactionalNotificationPreference,
            MockGenerator.marketingNotificationPreference,
            MockGenerator.priceAlertNotificationPreference,
            MockGenerator.securityNotificationPreference
        ]
        PrimaryNavigationView {
            FeatureNotificationSettingsView(
                store: .init(
                    initialState: .init(notificationPreferences: notificationPrefences),
                    reducer: featureNotificationReducer,
                    environment: FeatureNotificationSettingsEnvironment(mainQueue: .main, notificationSettingsRepository: NotificationSettingsRepositoryMock()))
            )
        }
    }
}

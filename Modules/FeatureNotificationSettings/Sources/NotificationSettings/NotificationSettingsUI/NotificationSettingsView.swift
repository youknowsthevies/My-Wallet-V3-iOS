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
import UIComponentsKit

public struct FeatureNotificationSettingsView: View {
    var store: Store<NotificationSettingsState, NotificationSettingsAction>
    @ObservedObject var viewStore: ViewStore<NotificationSettingsState, NotificationSettingsAction>
    
    public init(store: Store<NotificationSettingsState,NotificationSettingsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryNavigationView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    
                    switch viewStore.state.viewState {
                    case .idle :
                        EmptyView()
                    case .loading:
                        LoadingStateView(title: "")
                    case .data:
                        optionsSection
                        Spacer()
                    case .error:
                        errorSection
                    }
                }
                .navigationRoute(in: store)
            }
        }
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
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
                if case .data(let preferences) = viewStore.state.viewState {
                    ForEach(preferences) { notificationPreference in
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
    
    var errorSection: some View {
        WithViewStore(store) { viewStore in
            VStack {
                AlertCard(title: "Notification settings failed to load",
                          message: "There was a problem fetching your notifications settings. Please reload or try again later.",
                          variant: .warning,
                          isBordered: true,
                          onCloseTapped: nil)
                .padding(Spacing.padding3)
                Spacer()
                HStack {
                    Text("Failed to load notification settings")
                        .foregroundColor(Color.WalletSemantic.warning)
                        .padding(.leading, Spacing.padding2)
                    Spacer()
                    Button("Reload") {
                        viewStore.send(.onAppear)
                    }
                    .foregroundColor(Color.WalletSemantic.primary)
                    .padding(.trailing, Spacing.padding2)
                }
                .frame(maxWidth: .infinity, maxHeight: 48)
                .background(Color.WalletSemantic.background)
                .padding(.bottom, 50)
            }
        }
    }
}


//struct FeatureNotificationSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let notificationPrefences: [NotificationPreference] = [
//            MockGenerator.transactionalNotificationPreference,
//            MockGenerator.marketingNotificationPreference,
//            MockGenerator.priceAlertNotificationPreference,
//            MockGenerator.securityNotificationPreference
//        ]
//
//        PrimaryNavigationView {
//            FeatureNotificationSettingsView(
//                store: .init(
//                    initialState: .init(notificationPreferences: notificationPrefences),
//                    reducer: featureNotificationReducer,
//                    environment: FeatureNotificationSettingsEnvironment(mainQueue: .main, notificationSettingsRepository: NotificationSettingsRepositoryMock()))
//            )
//        }
//    }
//}

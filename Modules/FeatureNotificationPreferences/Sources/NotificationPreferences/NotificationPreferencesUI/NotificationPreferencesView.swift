//
//  FeatureNotificationPreferencesView.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 08/04/2022.
//

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI
import FeatureNotificationPreferencesDomain
import Mocks
import UIComponentsKit

public struct FeatureNotificationPreferencesView: View {
    var store: Store<NotificationPreferencesState, NotificationPreferencesAction>
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewStore: ViewStore<NotificationPreferencesState, NotificationPreferencesAction>
    
    public init(store: Store<NotificationPreferencesState,NotificationPreferencesAction>) {
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
                .navigationBarTitleDisplayMode(.inline)
                .navigationRoute(in: store)
                .trailingNavigationButton(.close) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
    }
}

extension FeatureNotificationPreferencesView {
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
                                viewStore.send(.onPreferenceSelected(notificationPreference))
                                viewStore.send(.route(.navigate(to: .showDetails)))
                            })
                    }
                }
            }
            .padding(.top, 66)
        }
    }
    
    var errorSection: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 8, content: {
                Spacer()
                Text("Notification settings failed to load")
                    .multilineTextAlignment(.center)
                    .typography(.title3)
                    .padding(.horizontal, Spacing.padding3)
                    .foregroundColor(Color.WalletSemantic.title)

                Text("There was a problem fetching your notifications settings. Please reload or try again later.")
                    .multilineTextAlignment(.center)
                    .typography(.caption1)
                    .padding(.horizontal, Spacing.padding3)
                    .foregroundColor(Color.WalletSemantic.muted)
                Spacer()
                PrimaryButton(title: "Try Again") {
                    viewStore.send(.onReloadTap)
                }
                .padding(.horizontal, Spacing.padding3)
                .padding(.bottom, Spacing.padding2)
                
                MinimalButton(title: "Go Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal, Spacing.padding3)
            })
        }
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SceneKit
import SwiftUI
import ToolKit

struct CardManagementDetailsView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Manage.Details.self

    private let store: Store<CardManagementState, CardManagementAction>

    init(store: Store<CardManagementState, CardManagementAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store.scope(state: \.error)) { viewStore in
            switch viewStore.state {
            case .some(let error):
                ErrorView(
                    error: error,
                    cancelAction: {
                        viewStore.send(.close)
                    }
                )
            default:
                content
            }
        }
    }

    @ViewBuilder var content: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack(spacing: 0) {
                    header
                    appleWalletButton
                    PrimaryDivider()
                    PrimaryRow(
                        title: localizedStrings.Lock.title,
                        subtitle: localizedStrings.Lock.subtitle,
                        trailing: {
                            PrimarySwitch(
                                accessibilityLabel: localizedStrings
                                    .Lock
                                    .title,
                                isOn: viewStore.binding(\.$isLocked)
                            )
                        },
                        action: {}
                    )
                    PrimaryDivider()
                    PrimaryRow(
                        title: localizedStrings.Personal.title,
                        subtitle: localizedStrings.Personal.subtitle,
                        trailing: { chevronRight },
                        action: {
                            viewStore.send(.showSupportFlow)
                        }
                    )
                    PrimaryDivider()
                    PrimaryRow(
                        title: localizedStrings.Support.title,
                        subtitle: localizedStrings.Support.subtitle,
                        trailing: { chevronRight },
                        action: {
                            viewStore.send(.showSupportFlow)
                        }
                    )
                    DestructiveMinimalButton(title: localizedStrings.delete) {
                        viewStore.send(.binding(.set(\.$isDeleteCardPresented, true)))
                    }
                    .padding(Spacing.padding3)
                }
                .listStyle(PlainListStyle())
                .background(Color.semantic.background.ignoresSafeArea())
            }
            .bottomSheet(
                isPresented: viewStore.binding(\.$isDeleteCardPresented),
                content: {
                    CloseCardView(store: store)
                }
            )
        }
    }

    @ViewBuilder var header: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding2) {
                HStack {
                    Text(LocalizationConstants.CardIssuing.Navigation.title)
                        .typography(.title3)
                        .padding([.top], Spacing.padding1)
                    Spacer()
                    Icon.closeCirclev2
                        .frame(width: 24, height: 24)
                        .onTapGesture(perform: {
                            viewStore.send(.closeDetails)
                        })
                }
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.padding1) {
                        HStack {
                            Text(localizedStrings.virtualCard)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                            Spacer()
                            Text("***\(viewStore.state.card?.last4 ?? "")")
                                .typography(.paragraph1)
                                .foregroundColor(.semantic.muted)
                        }
                        Text(viewStore.state.card?.status.localizedString ?? "-")
                            .typography(.caption2)
                            .foregroundColor(.semantic.primaryMuted)
                    }
                    .padding(.leading, 16)
                    .padding(.vertical, 18)
                    .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity)
                .background(Color.semantic.light)
                .cornerRadius(Spacing.padding1)
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.padding1)
                        .stroke(Color.semantic.muted, lineWidth: 1)
                )
            }
            .padding([.top, .trailing, .leading], Spacing.padding3)
        }
    }

    @ViewBuilder var appleWalletButton: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                HStack {
                    Image("apple-wallet", bundle: .cardIssuing)
                    Text(localizedStrings.addToAppleWallet)
                        .foregroundColor(Color.white)
                }
                .padding(12)
            }
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(8)
            .padding(.horizontal, Spacing.padding3)
            .padding(.bottom, Spacing.padding2)
            .padding(.top, Spacing.padding1)
            .onTapGesture {
                viewStore.send(.addToAppleWallet)
            }
        }
    }

    @ViewBuilder var chevronRight: some View {
        Icon.chevronRight
            .frame(width: 18, height: 18)
            .accentColor(
                .semantic.muted
            )
            .flipsForRightToLeftLayoutDirection(true)
    }
}

#if DEBUG
struct CardManagementDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardManagementDetailsView(
                store: Store(
                    initialState: .init(),
                    reducer: cardManagementReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif

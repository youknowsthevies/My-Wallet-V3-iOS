// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI

struct DomainCheckoutView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.DomainCheckout
    private typealias Accessibility = AccessibilityIdentifiers.DomainCheckout

    private let store: Store<DomainCheckoutState, DomainCheckoutAction>

    init(store: Store<DomainCheckoutState, DomainCheckoutAction>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: Spacing.padding2) {
            selectedDomains
                .padding(.top, Spacing.padding3)
            Spacer()
            termsRow
            PrimaryButton(title: LocalizedString.button) {
                // TODO: claim action
            }
            .accessibility(identifier: Accessibility.ctaButton)
        }
        .padding([.leading, .trailing], Spacing.padding3)
        .primaryNavigation(title: LocalizedString.navigationTitle)
    }

    private var selectedDomains: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack {
                    ForEach(viewStore.selectedDomains, id: \.domainName) { domain in
                        PrimaryRow(
                            title: domain.domainName,
                            subtitle: domain.domainType.statusLabel,
                            trailing: {
                                Button(
                                    action: {
                                        withAnimation {
                                            viewStore.send(.removeDomain(domain))
                                        }
                                    },
                                    label: {
                                        Icon.delete
                                            .frame(width: 24, height: 24)
                                            .accentColor(.semantic.muted)
                                    }
                                )
                            }
                        ).overlay(
                            RoundedRectangle(cornerRadius: 8.0)
                                .strokeBorder(Color.semantic.medium)
                        )
                    }
                }
            }
        }
    }

    private var termsRow: some View {
        WithViewStore(store) { viewStore in
            HStack(alignment: .top, spacing: Spacing.padding1) {
                PrimarySwitch(
                    accessibilityLabel: Accessibility.termsSwitch,
                    isOn: viewStore.binding(\.$termsSwitchIsOn)
                )
                Text(LocalizedString.terms)
                    .typography(.micro)
                    .accessibilityIdentifier(Accessibility.termsText)
            }
        }
    }
}

struct DomainCheckView_Previews: PreviewProvider {
    static var previews: some View {
        DomainCheckoutView(
            store: .init(
                initialState: .init(),
                reducer: domainCheckoutReducer,
                environment: ()
            )
        )
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import FeatureCryptoDomainDomain
import Localization
import SwiftUI

struct SearchCryptoDomainView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.SearchDomain
    private typealias Accessibility = AccessibilityIdentifiers.SearchDomain

    private let store: Store<SearchCryptoDomainState, SearchCryptoDomainAction>

    init(store: Store<SearchCryptoDomainState, SearchCryptoDomainAction>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: Spacing.padding2) {
            searchBar
                .padding([.top, .leading, .trailing], Spacing.padding3)
            alertCardDescription
                .padding([.leading, .trailing], Spacing.padding3)
            domainList
        }
        .primaryNavigation(
            title: LocalizedString.title,
            trailing: { cartBarButton }
        )
        .navigationRoute(in: store)
    }

    private var cartBarButton: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                viewStore.send(.navigate(to: .checkout))
            }) {
                Icon.cart
                    .frame(width: 24, height: 24)
                    .accentColor(.semantic.muted)
            }
            .accessibilityIdentifier(Accessibility.cartButton)
        }
    }

    private var searchBar: some View {
        WithViewStore(store) { viewStore in
            SearchBar(
                text: viewStore.binding(\.$searchText),
                isFirstResponder: viewStore.binding(\.$isSearchFieldSelected),
                cancelButtonText: LocalizationConstants.cancel,
                placeholder: LocalizedString.title,
                onReturnTapped: {
                    viewStore.send(.set(\.$isSearchFieldSelected, false))
                }
            )
            .accessibilityIdentifier(Accessibility.searchBar)
        }
    }

    private var alertCardDescription: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isAlertCardShown {
                AlertCard(
                    title: LocalizedString.Description.title,
                    message: LocalizedString.Description.body,
                    onCloseTapped: {
                        withAnimation {
                            viewStore.send(.set(\.$isAlertCardShown, false))
                        }
                    }
                )
                .accessibilityIdentifier(Accessibility.alertCard)
            }
        }
    }

    private var domainList: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewStore.filteredSearchResults, id: \.domainName) { result in
                        Divider()
                        createDomainRow(result: result)
                    }
                    Divider()
                }
            }
            .accessibilityIdentifier(Accessibility.domainList)
        }
    }

    private func createDomainRow(result: SearchDomainResult) -> some View {
        PrimaryRow(
            title: result.domainName,
            subtitle: result.domainType.statusLabel,
            tags: [
                Tag(
                    text: result.domainAvailability.availabilityLabel,
                    variant: result.domainAvailability == .availableForFree ?
                        .success : result.domainAvailability == .unavailable ? .default : .infoAlt
                )
            ],
            action: {}
        )
        .accessibilityIdentifier(Accessibility.domainListRow)
    }
}

struct SearchCryptoDomainView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCryptoDomainView(
            store: .init(
                initialState: .init(
                    searchResults: [
                       SearchDomainResult(
                           domainName: "cocacola.blockchain",
                           domainType: .premium,
                           domainAvailability: .unavailable
                       ),
                       SearchDomainResult(
                           domainName: "cocacola001.blockchain",
                           domainType: .free,
                           domainAvailability: .availableForFree
                       ),
                       SearchDomainResult(
                           domainName: "cocola.blockchain",
                           domainType: .premium,
                           domainAvailability: .availableForPremiumSale(price: "50")
                       )
                   ]
                ),
                reducer: searchCryptoDomainReducer,
                environment: .init(mainQueue: .main)
            )
        )
    }
}

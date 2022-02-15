// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import FeatureCryptoDomainDomain

struct SearchCryptoDomainView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureCryptoDomain.SearchDomain

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
        .navigationRoute(in: store)
        .navigationTitle(LocalizedString.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton, trailing: cartBarButton)
    }

    private var backButton: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                viewStore.send(.dismiss())
            }) {
                Icon.chevronLeft
                    .frame(width: 24, height: 24)
                    .accentColor(.semantic.primary)
            }
        }
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
        }
    }

    private var alertCardDescription: some View {
        WithViewStore(store) { viewStore in
            if viewStore.isAlertCardShown {
                AlertCard(
                    title: LocalizedString.Description.title,
                    message: LocalizedString.Description.body,
                    onCloseTapped: {
                        withAnimation(.linear){
                            viewStore.send(.set(\.$isAlertCardShown, false))
                        }
                    }
                )
            }
        }
    }

    private var domainList: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewStore.binding(\.$searchResults), id: \.domainName) { result in
                        Divider()
                        createDomainRow(result: result.wrappedValue)
                    }
                    Divider()
                }
            }
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
    }
}

struct SearchCryptoDomainView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCryptoDomainView(
            store: .init(
                initialState: .init(),
                reducer: searchCryptoDomainReducer,
                environment: .init(mainQueue: .main)
            )
        )
    }
}

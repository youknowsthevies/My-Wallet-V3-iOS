// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct ProductSelectionView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.self

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                if !viewStore.state.products.isEmpty {
                    TabView(selection: viewStore.binding(
                        get: \.selectedProductIndex,
                        send: CardOrderingAction.selectProduct(_:)
                    )) {
                        ForEach(viewStore.state.products) { product in
                            ProductView(
                                product: product,
                                action: {
                                    viewStore.send(.binding(.set(\.$isProductDetailsVisible, true)))
                                }
                            )
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                }
                HStack {
                    Checkbox(isOn: viewStore.binding(\.$termsAccepted))
                    Text(localizedStrings.Selection.acceptTerms)
                        .foregroundColor(.WalletSemantic.body)
                        .typography(.caption1)
                        .onTapGesture {}
                }
                PrimaryButton(title: localizedStrings.Selection.Button.Title.create) {
                    viewStore.send(.createCard)
                }
                .disabled(!viewStore.state.termsAccepted || viewStore.state.products.isEmpty)
            }
            .padding(Spacing.padding3)
            .bottomSheet(isPresented: viewStore.binding(\.$isProductDetailsVisible)) {
                IfLetStore(
                    store.scope(state: \.selectedProduct),
                    then: { store in
                        ProductDetailsView(
                            store: store,
                            close: {
                                viewStore.send(.binding(.set(\.$isProductDetailsVisible, false)))
                            }
                        )
                    },
                    else: EmptyView.init
                )
            }

            PrimaryNavigationLink(
                destination: LegalView(),
                isActive: viewStore.binding(\.$isLegalViewVisible),
                label: EmptyView.init
            )
            PrimaryNavigationLink(
                destination: OrderProcessingView(store: store),
                isActive: viewStore.binding(\.$isOrderProcessingVisible),
                label: EmptyView.init
            )
            .onAppear {
                viewStore.send(.fetchProducts)
            }
        }
        .primaryNavigation(title: localizedStrings.Selection.Navigation.title)
    }
}

struct ProductView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.self

    private let product: Product
    private let action: () -> Void

    init(
        product: Product,
        action: @escaping () -> Void
    ) {
        self.product = product
        self.action = action
    }

    var body: some View {
        VStack {
            Image("card-selection", bundle: .cardIssuing)
                .resizable()
                .scaledToFit()
            VStack(spacing: Spacing.padding1) {
                Text(product.type.localizedTitle)
                    .typography(.title2)
                    .multilineTextAlignment(.center)
                Text(product.type.localizedDescription)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
            }
            SmallMinimalButton(
                title: localizedStrings.Selection.Button.Title.details,
                action: action
            )
            .padding(.bottom, Spacing.padding4)
        }
    }
}

#if DEBUG
struct ProductSelection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductSelectionView(
                store: Store(
                    initialState: .init(),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif

extension Card.CardType {

    var localizedTitle: String {
        let localized = LocalizationConstants.CardIssuing.CardType.self
        switch self {
        case .physical:
            return localized.Physical.title
        case .virtual:
            return localized.Virtual.title
        }
    }

    var localizedLongTitle: String {
        let localized = LocalizationConstants.CardIssuing.CardType.self
        switch self {
        case .physical:
            return localized.Physical.longTitle
        case .virtual:
            return localized.Virtual.longTitle
        }
    }

    var localizedDescription: String {
        let localized = LocalizationConstants.CardIssuing.CardType.self
        switch self {
        case .physical:
            return localized.Physical.description
        case .virtual:
            return localized.Virtual.description
        }
    }
}

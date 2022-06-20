// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct ProductSelectionView: View {

    @State var detailsPresented: Bool = false

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.self

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                Image("card-selection", bundle: .cardIssuing)
                    .resizable()
                    .scaledToFit()
                VStack(spacing: Spacing.padding1) {
                    Text(LocalizationConstants.CardIssuing.CardType.Virtual.title)
                        .typography(.title2)
                        .multilineTextAlignment(.center)
                    Text(LocalizationConstants.CardIssuing.CardType.Virtual.description)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.body)
                        .multilineTextAlignment(.center)
                }
                InfoButton(title: localizedStrings.Selection.Button.Title.details) {
                    detailsPresented = true
                }
                Spacer()
                PrimaryButton(title: localizedStrings.Selection.Button.Title.create) {
                    viewStore.send(.setStep(.creating))
                }
            }
            .padding(Spacing.padding3)
            .primaryNavigation(title: localizedStrings.Selection.Navigation.title)
            .sheet(isPresented: $detailsPresented) {
                ProductDetailsView {
                    detailsPresented = false
                }
            }

            PrimaryNavigationLink(
                destination: OrderProcessingView(store: store),
                isActive: .constant(viewStore.state.isOrderProcessingVisible),
                label: EmptyView.init
            )
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

struct InfoButton: View {

    private let title: String
    private let action: () -> Void

    init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.baseline) {
                Icon
                    .alert
                    .accentColor(.WalletSemantic.primary)
                    .frame(width: 16)
                    .background(
                        Circle()
                            .foregroundColor(Color.white)
                            .frame(width: 10)
                    )
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                Text(title)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.title)
                Icon
                    .arrowRight
                    .frame(width: 16)
                    .accentColor(.WalletSemantic.primary)
            }
        }
        .padding([.leading, .trailing], Spacing.padding1)
        .padding(.init(top: 6, leading: 8, bottom: 6, trailing: 8))
        .background(
            RoundedRectangle(cornerRadius: Spacing.roundedBorderRadius(for: 32))
                .fill(Color.WalletSemantic.light)
        )
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct CardIssuingIntroView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.self

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                Image("graphic-cards", bundle: .cardIssuing)
                    .resizable()
                    .scaledToFit()
                Text(localizedStrings.Intro.title)
                    .typography(.title2)
                    .multilineTextAlignment(.center)
                Text(localizedStrings.Intro.caption)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
                PrimaryButton(title: localizedStrings.Intro.Button.Title.order) {
                    viewStore.send(.setStep(.selection))
                }
                .padding(.top, Spacing.padding2)
                Spacer()
            }
            .padding(Spacing.padding3)
            .primaryNavigation(title: LocalizationConstants.CardIssuing.Navigation.title)
            .onAppear {
                viewStore.send(.setStep(.intro))
            }
            PrimaryNavigationLink(
                destination: ProductSelectionView(store: store),
                isActive: viewStore.binding(\.$isProductSelectionVisible),
                label: EmptyView.init
            )
        }
    }
}

#if DEBUG
struct CardIssuingIntro_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardIssuingIntroView(
                store: Store(
                    initialState: .init(),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
            CardIssuingIntroView(
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

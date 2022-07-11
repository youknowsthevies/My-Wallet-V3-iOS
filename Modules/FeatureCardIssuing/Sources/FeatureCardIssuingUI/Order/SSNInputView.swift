// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct SSNInputView: View {

    @State var isFirstResponder: Bool = false

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.KYC.self

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                VStack(alignment: .leading, spacing: Spacing.padding1) {
                    Text(localizedStrings.SSN.title)
                        .typography(.title3)
                        .multilineTextAlignment(.center)
                    Text(localizedStrings.SSN.description)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.body)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, Spacing.padding2)
                VStack(alignment: .leading) {
                    Text(localizedStrings.SSN.Input.title)
                        .typography(.paragraph2)
                    Input(
                        text: viewStore.binding(\.$ssn),
                        isFirstResponder: $isFirstResponder,
                        placeholder: localizedStrings.SSN.Input.placeholder,
                        trailing: {
                            Icon.lockClosed
                        }
                    )
                    Text(localizedStrings.SSN.Input.caption)
                        .typography(.caption1)
                        .foregroundColor(.semantic.muted)
                }
                .padding(.horizontal, Spacing.padding2)
                Spacer()
                PrimaryButton(title: localizedStrings.Buttons.next) {
                    viewStore.send(.binding(.set(\.$isProductSelectionVisible, true)))
                }
                .disabled(viewStore.state.ssn.isEmpty)
                .padding(Spacing.padding2)
            }
            .padding(.vertical, Spacing.padding3)
            .primaryNavigation(title: localizedStrings.SSN.Navigation.title)

            PrimaryNavigationLink(
                destination: ProductSelectionView(store: store),
                isActive: viewStore.binding(\.$isProductSelectionVisible),
                label: EmptyView.init
            )
        }
    }
}

#if DEBUG
struct SSNInput_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SSNInputView(
                store: Store(
                    initialState: CardOrderingState(
                        address: MockServices.address,
                        ssn: ""
                    ),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif

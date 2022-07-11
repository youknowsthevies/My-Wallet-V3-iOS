// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SwiftUI
import ToolKit

struct ResidentialAddressModificationView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.KYC.self

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: Spacing.padding3) {
                VStack(spacing: Spacing.padding1) {
                    Input(
                        text: viewStore.binding(\.$addressLine1),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.line1),
                        label: localizedStrings.Address.Form.addressLine1,
                        placeholder: localizedStrings.Address.Form.placeholder,
                        configuration: {
                            $0.textContentType = .streetAddressLine1
                        }
                    )
                    Input(
                        text: viewStore.binding(\.$addressLine2),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.line2),
                        label: localizedStrings.Address.Form.addressLine2,
                        placeholder: localizedStrings.Address.Form.placeholder,
                        configuration: {
                            $0.textContentType = .streetAddressLine2
                        }
                    )
                    Input(
                        text: viewStore.binding(\.$addressCity),
                        isFirstResponder: viewStore
                            .binding(\.$selectedInputField)
                            .equals(.city),
                        label: localizedStrings.Address.Form.city,
                        configuration: {
                            $0.textContentType = .addressCity
                        }
                    )
                    HStack(spacing: Spacing.padding2) {
                        Input(
                            text: viewStore.binding(\.$addressState),
                            isFirstResponder: viewStore
                                .binding(\.$selectedInputField)
                                .equals(.state),
                            label: localizedStrings.Address.Form.state,
                            configuration: {
                                $0.textContentType = .addressState
                            }
                        )
                        Input(
                            text: viewStore.binding(\.$addressPostcode),
                            isFirstResponder: viewStore
                                .binding(\.$selectedInputField)
                                .equals(.zip),
                            label: localizedStrings.Address.Form.zip,
                            configuration: {
                                $0.textContentType = .postalCode
                            }
                        )
                    }
                }
                .padding(.horizontal, Spacing.padding3)
                Spacer()
                PrimaryButton(title: localizedStrings.Buttons.save) {
                    viewStore.send(.updateAddress)
                }
                .padding(Spacing.padding3)
                .padding(.bottom, Spacing.padding4)
            }
            .padding(.vertical, Spacing.padding3)
            .primaryNavigation(title: localizedStrings.Address.Navigation.title)
        }
    }
}

#if DEBUG
struct ResidentialAddressModification_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResidentialAddressModificationView(
                store: Store(
                    initialState: CardOrderingState(address: MockServices.address),
                    reducer: cardOrderingReducer,
                    environment: .preview
                )
            )
        }
    }
}
#endif

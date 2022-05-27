// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import NabuNetworkError
import SwiftUI

struct CloseCardView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Manage.Details.Close.self

    private let store: Store<CardManagementState, CardManagementAction>

    init(store: Store<CardManagementState, CardManagementAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.management.isDeleting {
                ProgressView(value: 0.25)
                    .progressViewStyle(.indeterminate)
                    .frame(width: 52, height: 52)
                    .padding(Spacing.padding6)
            } else {
                VStack(spacing: Spacing.padding2) {
                    ZStack(alignment: .topTrailing) {
                        Icon
                            .creditcard
                            .accentColor(.WalletSemantic.primary)
                            .frame(width: 60, height: 60)
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                            Circle()
                                .foregroundColor(.WalletSemantic.error)
                                .frame(width: 22, height: 22)
                            Icon
                                .close
                                .frame(width: 12, height: 12)
                                .accentColor(.white)
                        }
                        .padding(.top, -4)
                        .padding(.trailing, -8)
                    }
                    VStack(spacing: Spacing.padding1) {
                        Text(String(format: localizedStrings.title, viewStore.state.card?.last4 ?? ""))
                            .typography(.title3)
                            .multilineTextAlignment(.center)
                        Text(localizedStrings.message)
                            .typography(.paragraph1)
                            .foregroundColor(.WalletSemantic.body)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, Spacing.padding3)
                    DestructivePrimaryButton(
                        title: localizedStrings.confirmation,
                        action: {
                            viewStore.send(.delete)
                        }
                    )
                    MinimalButton(
                        title: LocalizationConstants.cancel,
                        action: {
                            viewStore.send(.hideDeleteConfirmation)
                        }
                    )
                }
                .padding(Spacing.padding3)
            }
        }
    }
}

#if DEBUG
struct CloseCard_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .bottomSheet(isPresented: .constant(true)) {
                CloseCardView(
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

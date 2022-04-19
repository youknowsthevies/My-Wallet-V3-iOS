// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import NabuNetworkError
import SwiftUI
import ToolKit

struct OrderProcessingView: View {

    private let localizedStrings = LocalizationConstants.CardIssuing.Order.self

    private let store: Store<CardOrderingState, CardOrderingAction>

    init(store: Store<CardOrderingState, CardOrderingAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                switch viewStore.state.orderProcessingState {
                case .success:
                    success
                case .error:
                    error
                default:
                    processing
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder var processing: some View {
        VStack(spacing: Spacing.padding3) {
            ProgressView(value: 0.25)
                .progressViewStyle(.indeterminate)
                .frame(width: 52, height: 52)
            Text(localizedStrings.Processing.Processing.title)
                .typography(.title3)
                .foregroundColor(.WalletSemantic.body)
                .multilineTextAlignment(.center)
                .padding(.bottom, Spacing.padding6)
        }
        .padding(Spacing.padding3)
        .padding(.bottom, Spacing.padding6)
    }

    @ViewBuilder var success: some View {
        VStack(spacing: Spacing.padding3) {
            ZStack(alignment: .topTrailing) {
                Icon
                    .creditcard
                    .accentColor(.WalletSemantic.primary)
                    .frame(width: 60, height: 60)
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                    Icon
                        .checkCircle
                        .frame(width: 20, height: 20)
                        .accentColor(.WalletSemantic.success)
                }
                .padding(.top, -4)
                .padding(.trailing, -8)
            }
            .padding(.top, Spacing.padding6)
            VStack(spacing: Spacing.padding1) {
                Text(localizedStrings.Processing.Success.title)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                Text(localizedStrings.Processing.Success.caption)
                    .typography(.paragraph1)
                    .foregroundColor(.WalletSemantic.body)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.padding3)
            Spacer()
            WithViewStore(store) { viewStore in
                PrimaryButton(title: LocalizationConstants.continueString) {
                    viewStore.send(.close(.created))
                }
            }
        }
        .padding(Spacing.padding3)
    }

    @ViewBuilder var error: some View {
        WithViewStore(store) { viewStore in
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
                            .error
                            .frame(width: 12, height: 12)
                            .accentColor(.white)
                    }
                    .padding(.top, -4)
                    .padding(.trailing, -8)
                }
                .padding(.top, Spacing.padding6)
                VStack(spacing: Spacing.padding1) {
                    Text(localizedStrings.Processing.Error.title)
                        .typography(.title3)
                        .multilineTextAlignment(.center)
                    Text(localizedStrings.Processing.Error.caption)
                        .typography(.paragraph1)
                        .foregroundColor(.WalletSemantic.body)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.padding3)
                Spacer()
                PrimaryButton(title: localizedStrings.Processing.Error.retry) {
                    viewStore.send(.setStep(.creating))
                }
                MinimalButton(title: localizedStrings.Processing.Error.cancelGoBack) {
                    viewStore.send(.close(.cancelled))
                }
            }
        }
        .padding(Spacing.padding3)
    }
}

#if DEBUG
struct OrderProcessing_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView<OrderProcessingView> {
            OrderProcessingView(
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

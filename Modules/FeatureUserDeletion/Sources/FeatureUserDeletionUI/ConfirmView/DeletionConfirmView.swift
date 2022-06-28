import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI
import UIComponentsKit

private typealias LocalizedString = LocalizationConstants.UserDeletion.ConfirmationScreen

public struct DeletionConfirmView: View {
    let store: Store<DeletionConfirmState, DeletionConfirmAction>
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewStore: ViewStore<DeletionConfirmState, DeletionConfirmAction>

    public init(store: Store<DeletionConfirmState, DeletionConfirmAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            if viewStore.isLoading {
                Group {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 104, height: 104)
                    Text(LocalizedString.processing)
                        .typography(.title3)
                        .foregroundColor(.textBody)
                        .padding(.top, 16)
                }
            } else {
                contentView
                    .padding()
            }
        }
        .whiteNavigationBarStyle()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(LocalizedString.navBarTitle)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationRoute(in: store)
        .trailingNavigationButton(.close, action: {
            viewStore.send(.dismissFlow)
        })
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            Text(LocalizedString.explanaition)
                .typography(.paragraph1)
                .foregroundColor(.textBody)

            let shouldShowError = viewStore.shouldShowInvalidInputUI
            Input(
                text: viewStore.binding(\.$textFieldText),
                isFirstResponder: viewStore
                    .binding(\.$firstResponder)
                    .equals(.confirmation),
                label: LocalizedString.textField.label,
                subText: shouldShowError ? LocalizedString.textField.errorSubText : nil,
                subTextStyle: shouldShowError ? .error : .default,
                placeholder: LocalizedString.textField.placeholder,
                state: shouldShowError ? .error : .default,
                configuration: {
                    $0.autocorrectionType = .no
                    $0.autocapitalizationType = .allCharacters
                    $0.keyboardType = .default
                },
                onReturnTapped: {
                    viewStore.send(.set(\.$firstResponder, nil))
                }
            )

            Spacer()

            DestructivePrimaryButton(
                title: LocalizedString.mainCTA,
                action: {
                    viewStore.send(.deleteUserAccount)
                }
            )
        }
    }
}

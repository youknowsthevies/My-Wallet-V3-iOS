// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import KYCKit
import SharedPackagesKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct EditEmailState: Equatable {
    var emailAddress: String
    fileprivate var isEmailValid: Bool = false
    fileprivate var savingEmailAddress: Bool = false
    fileprivate var saveEmailFailureAlert: AlertState<EditEmailAction>?

    init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}

enum EditEmailAction: Equatable {
    case didAppear
    case didChangeEmailAddress(String)
    case didReceiveSaveResponse(Result<Int, UpdateEmailAddressError>)
    case dismissSaveEmailFailureAlert
    case save
}

struct EditEmailEnvironment {
    let emailVerificationService: EmailVerificationServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validateEmail: (String) -> Bool = { $0.isEmail }
}

let editEmailReducer = Reducer<EditEmailState, EditEmailAction, EditEmailEnvironment> { state, action, environment in
    switch action {
    case .didAppear:
        state.isEmailValid = environment.validateEmail(state.emailAddress)
        return .none

    case .didChangeEmailAddress(let emailAddress):
        state.emailAddress = emailAddress
        state.isEmailValid = environment.validateEmail(emailAddress)
        return .none

    case .save:
        state.savingEmailAddress = true
        return environment.emailVerificationService.updateEmailAddress(to: state.emailAddress)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                switch result {
                case .success:
                    return .didReceiveSaveResponse(.success(0))
                case .failure(let error):
                    return .didReceiveSaveResponse(.failure(error))
                }
            }

    case .didReceiveSaveResponse(let response):
        state.savingEmailAddress = false
        switch response {
        case .success:
            return .none

        case .failure:
            state.saveEmailFailureAlert = AlertState(
                title: TextState(L10n.GenericError.title),
                message: TextState(L10n.EditEmail.couldNotUpdateEmailAlertMessage),
                primaryButton: .default(
                    TextState(L10n.GenericError.retryButtonTitle),
                    send: .save
                ),
                secondaryButton: .cancel()
            )
            return .none
        }

    case .dismissSaveEmailFailureAlert:
        state.saveEmailFailureAlert = nil
        return .none
    }
}

struct EditEmailView: View {

    let store: Store<EditEmailState, EditEmailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(
                content: {
                    VStack {
                        VStack(alignment: .leading) {
                            Text(L10n.EditEmail.title)
                                .textStyle(.title)
                            Text(L10n.EditEmail.message)
                                .textStyle(.body)
                        }
                        .frame(maxWidth: .infinity)

                        Spacer()

                        VStack(spacing: LayoutConstants.VerticalSpacing.betweenContentGroups) {
                            FormTextFieldGroup(
                                title: L10n.EditEmail.editEmailFieldLabel,
                                text: viewStore.binding(
                                    get: { $0.emailAddress },
                                    send: { .didChangeEmailAddress($0) }
                                )
                            )
                            if !viewStore.isEmailValid {
                                BadgeView(
                                    title: L10n.EditEmail.invalidEmailInputMessage,
                                    style: .error
                                )
                            }
                        }

                        Spacer()
                    }
                    .multilineTextAlignment(.leading)
                },
                buttons: [
                    .init(
                        title: L10n.EditEmail.saveButtonTitle,
                        action: {
                            viewStore.send(.save)
                        },
                        loading: viewStore.savingEmailAddress,
                        enabled: viewStore.isEmailValid
                    )
                ]
            )
            .alert(store.scope(state: \.saveEmailFailureAlert), dismiss: .dismissSaveEmailFailureAlert)
            .onAppear {
                viewStore.send(.didAppear)
            }
        }
        .background(Color.viewPrimaryBackground)
    }
}

#if DEBUG
@available(iOS 14.0, *)
struct EditEmailView_Previews: PreviewProvider {
    static var previews: some View {
        // Invalid state: empty email
        EditEmailView(
            store: .init(
                initialState: .init(emailAddress: ""),
                reducer: editEmailReducer,
                environment: EditEmailEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )

        // Invalid state: invalid email typed by user
        EditEmailView(
            store: .init(
                initialState: .init(emailAddress: "invalid.com"),
                reducer: editEmailReducer,
                environment: EditEmailEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )

        // Valid state
        EditEmailView(
            store: .init(
                initialState: .init(emailAddress: "test@example.com"),
                reducer: editEmailReducer,
                environment: EditEmailEnvironment(
                    emailVerificationService: NoOpEmailVerificationService(),
                    mainQueue: .main
                )
            )
        )
    }
}
#endif

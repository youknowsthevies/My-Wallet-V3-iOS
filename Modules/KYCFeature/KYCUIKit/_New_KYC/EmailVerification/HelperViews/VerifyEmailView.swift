// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import SharedPackagesKit
import SwiftUI
import UIComponentsKit

struct VerifyEmailState: Equatable {
    
    var emailAddress: String
    fileprivate var cannotOpenMailAppAlert: AlertState<VerifyEmailAction>?
    
    init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}

enum VerifyEmailAction: Equatable {
    case tapCheckInbox
    case tapGetEmailNotReceivedHelp
    case presentCannotOpenMailAppAlert
    case dismissCannotOpenMailAppAlert
}

struct VerifyEmailEnvironment {
    var externalAppOpener: ExternalAppOpener
}

let verifyEmailReducer = Reducer<VerifyEmailState, VerifyEmailAction, VerifyEmailEnvironment> { state, action, environment in
    switch action {
    case .tapCheckInbox:
        return .future { (callback) in
            environment.externalAppOpener.openMailApp { (success) in
                guard success else {
                    callback(.success(.presentCannotOpenMailAppAlert))
                    return
                }
            }
        }
        
    case .tapGetEmailNotReceivedHelp:
        return .none
        
    case .presentCannotOpenMailAppAlert:
        // NOTE: this should happen only on Simulators
        state.cannotOpenMailAppAlert = AlertState(title: .init("Cannot Open Mail App"))
        return .none
        
    case .dismissCannotOpenMailAppAlert:
        state.cannotOpenMailAppAlert = nil
        return .none
    }
}

struct VerifyEmailView: View {
    
    let store: Store<VerifyEmailState, VerifyEmailAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(
                image: {
                    Image("email_verification", bundle: .kycUIKit)
                },
                title: L10n.VerifyEmail.title,
                message: L10n.VerifyEmail.message(with: "**\(viewStore.emailAddress)**"),
                buttons: [
                    .init(
                        title: L10n.VerifyEmail.checkInboxButtonTitle,
                        action: {
                            viewStore.send(.tapCheckInbox)
                        }
                    ),
                    .init(
                        title: L10n.VerifyEmail.getHelpButtonTitle,
                        action: {
                            viewStore.send(.tapGetEmailNotReceivedHelp)
                        },
                        style: .secondary
                    )
                ],
                imageSpacing: 0
            )
            .alert(store.scope(state: \.cannotOpenMailAppAlert), dismiss: .dismissCannotOpenMailAppAlert)
        }
        .background(Color.viewPrimaryBackground)
    }
}

#if DEBUG
struct VerifyEmailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerifyEmailView(
                store: .init(
                    initialState: .init(
                        emailAddress: "test@example.com"
                    ),
                    reducer: verifyEmailReducer,
                    environment: VerifyEmailEnvironment(
                        externalAppOpener: UIApplication.shared
                    )
                )
            )
            .preferredColorScheme(.light)
            
            VerifyEmailView(
                store: .init(
                    initialState: .init(
                        emailAddress: "test@example.com"
                    ),
                    reducer: verifyEmailReducer,
                    environment: VerifyEmailEnvironment(
                        externalAppOpener: UIApplication.shared
                    )
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
#endif

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import Combine
import ComposableArchitecture

enum AllowAccessAction: Equatable {
    case allowCameraAccess
    case dismiss
    case showCameraDeniedAlert
    case onAppear
    case showsWalletConnectRow(Bool)
}

struct AllowAccessState: Equatable {
    /// Hides the action button
    let informationalOnly: Bool
    var showWalletConnectRow: Bool
}

struct AllowAccessEnvironment {
    let allowCameraAccess: () -> Void
    let cameraAccessDenied: () -> Bool
    let dismiss: () -> Void
    let showCameraDeniedAlert: () -> Void
    let showsWalletConnectRow: () -> AnyPublisher<Bool, Never>
}

let qrScannerAllowAccessReducer = Reducer<
    AllowAccessState,
    AllowAccessAction,
    AllowAccessEnvironment
> { state, action, environment in
    switch action {
    case .onAppear:
        return environment.showsWalletConnectRow()
            .eraseToEffect()
            .map(AllowAccessAction.showsWalletConnectRow)
    case .showsWalletConnectRow(let display):
        state.showWalletConnectRow = display
        return .none
    case .allowCameraAccess:
        guard !environment.cameraAccessDenied() else {
            return .concatenate(
                Effect(value: .dismiss),
                Effect(value: .showCameraDeniedAlert)
            )
        }
        return .merge(
            .fireAndForget {
                environment.allowCameraAccess()
            },
            Effect(value: .dismiss)
        )
    case .showCameraDeniedAlert:
        environment.showCameraDeniedAlert()
        return .none
    case .dismiss:
        environment.dismiss()
        return .none
    }
}

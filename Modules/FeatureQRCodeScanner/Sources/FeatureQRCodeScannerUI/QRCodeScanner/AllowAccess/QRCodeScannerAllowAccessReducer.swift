// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import Combine
import ComposableArchitecture

enum AllowAccessAction: Equatable {
    case allowCameraAccess
    case dismiss
    case showCameraDeniedAlert
}

struct AllowAccessState: Equatable {
    /// Hides the action button
    let informationalOnly: Bool
}

struct AllowAccessEnvironment {
    let allowCameraAccess: () -> Void
    let cameraAccessDenied: () -> Bool
    let dismiss: () -> Void
    let showCameraDeniedAlert: () -> Void
}

let qrScannerAllowAccessReducer = Reducer<
    AllowAccessState,
    AllowAccessAction,
    AllowAccessEnvironment
> { _, action, environment in
    switch action {
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

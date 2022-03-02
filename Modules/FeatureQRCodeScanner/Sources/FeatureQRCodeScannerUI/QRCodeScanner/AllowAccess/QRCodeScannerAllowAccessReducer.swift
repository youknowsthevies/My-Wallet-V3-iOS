// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import Combine
import ComposableArchitecture

enum AllowAccessAction: Equatable {
    case allowCameraAccess
    case dismiss
}

struct AllowAccessState: Equatable {
    /// Hides the action button
    let informationalOnly: Bool
}

struct AllowAccessEnvironment {
    let allowCameraAccess: () -> Void
    let dismiss: () -> Void
}

let qrScannerAllowAccessReducer = Reducer<
    AllowAccessState,
    AllowAccessAction,
    AllowAccessEnvironment
> { _, action, environment in
    switch action {
    case .allowCameraAccess:
        environment.allowCameraAccess()
        return .none
    case .dismiss:
        environment.dismiss()
        return .none
    }
}

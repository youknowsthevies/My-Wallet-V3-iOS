// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit
import BlockchainComponentLibrary

enum NavigationCTA {
    case dismiss
    case help
    case none
}

extension NavigationCTA {
    var image: UIImage? {
        switch self {
        case .dismiss:
            return UIImage(
                named: "Close Circle v2",
                in: .componentLibrary,
                compatibleWith: nil
            )?.withRenderingMode(.alwaysOriginal)
        case .help:
            return UIImage(named: "ios_icon_more", in: .featureKYCUI, compatibleWith: nil)
        case .none:
            return nil
        }
    }

    var visibility: PlatformUIKit.Visibility {
        switch self {
        case .dismiss:
            return .visible
        case .help:
            return .visible
        case .none:
            return .hidden
        }
    }
}

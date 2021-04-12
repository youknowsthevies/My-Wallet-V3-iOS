//
//  NavigationCTA.swift
//  KYCUIKit
//
//  Created by Paulo on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import UIKit

enum NavigationCTA {
    case dismiss
    case help
    case none
}

extension NavigationCTA {
    var image: UIImage? {
        switch self {
        case .dismiss:
            return UIImage(named: "close", in: .kycUIKit, compatibleWith: nil)
        case .help:
            return UIImage(named: "ios_icon_more", in: .kycUIKit, compatibleWith: nil)
        case .none:
            return nil
        }
    }

    var visibility: Visibility {
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

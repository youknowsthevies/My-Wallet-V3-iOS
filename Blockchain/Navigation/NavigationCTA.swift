//
//  NavigationCTA.swift
//  Blockchain
//
//  Created by Chris Arriola on 1/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

enum NavigationCTA {
    case dismiss
    case help
    case none
}

extension NavigationCTA {
    var image: UIImage? {
        switch self {
        case .dismiss:
            return #imageLiteral(resourceName: "close")
        case .help:
            return UIImage(named: "ios_icon_more")
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

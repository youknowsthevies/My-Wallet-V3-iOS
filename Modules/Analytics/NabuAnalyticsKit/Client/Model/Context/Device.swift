// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

struct Device: Encodable {
    let id: String? = UIDevice.current.identifierForVendor?.uuidString
    let manufacturer: String = "Apple"
    let model: String = UIDevice.current.model
    let name: String = UIDevice.current.name
    let type: String = {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .tv:
            return "AppleTV"
        case .carPlay:
            return "CarPlay"
        case .mac:
            return "Mac"
        default:
            return "Unspecified"
        }
    }()
    let version: String = UIDevice.current.systemVersion
}

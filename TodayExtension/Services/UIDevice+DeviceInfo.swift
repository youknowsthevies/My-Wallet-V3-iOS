// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit
import UIKit

extension UIDevice: DeviceInfo {
    public var uuidString: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

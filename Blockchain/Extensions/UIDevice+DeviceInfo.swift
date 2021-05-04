// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

extension UIDevice: DeviceInfo {
    public var uuidString: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

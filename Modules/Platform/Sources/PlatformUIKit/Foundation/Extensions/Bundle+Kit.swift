// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let platformUIKit = Bundle.find("Platform_PlatformUIKit.bundle", in: BundleFinder.self)
}

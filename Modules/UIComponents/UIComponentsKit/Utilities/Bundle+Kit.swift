// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

private class BundleFinder {}
extension Bundle {
    public static let UIComponents = Bundle.find(
        "UIComponents_UIComponentsKit.bundle",
        "Blockchain_UIComponentsKit.bundle",
        in: BundleFinder.self
    )
}

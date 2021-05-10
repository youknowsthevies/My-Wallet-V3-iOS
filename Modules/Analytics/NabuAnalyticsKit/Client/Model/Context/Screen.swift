// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

struct Screen: Encodable {
    let width: Double = Double(UIScreen.main.bounds.width)
    let height: Double = Double(UIScreen.main.bounds.height)
    let density: Double = Double(UIScreen.main.scale)
}

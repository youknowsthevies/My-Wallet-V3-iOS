// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

#if canImport(UIKit)
import UIKit

struct Screen: Encodable {
    let width = Double(UIScreen.main.bounds.width)
    let height = Double(UIScreen.main.bounds.height)
    let density = Double(UIScreen.main.scale)
}
#endif

#if canImport(AppKit)
import AppKit

struct Screen: Encodable {
    let width = Double(NSScreen.main!.frame.width)
    let height = Double(NSScreen.main!.frame.height)
    let density = Double(1)
}
#endif

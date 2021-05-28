// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
@testable import UIComponentsKit
import XCTest

class PaletteColorTests: XCTestCase {

    func testAllColorsExistWithExpectedName() {
        PaletteColor.allCases.forEach { paletteColor in
            XCTAssertNoThrow(UIColor.init(paletteColor: paletteColor))
            XCTAssertNoThrow(Color.init(paletteColor: paletteColor))
        }
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

struct Price: Equatable, Identifiable {
    var title: String
    var abbreviation: String
    var price: String
    var percentage: String
    var icon: Image?
    var hasIncreased: Bool
    var id: AnyHashable = UUID()
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

struct AccountPickerRow: Equatable, Identifiable {
    var name: String
    var kind: String
    var price: String
    var value: String
    var id = UUID()
}

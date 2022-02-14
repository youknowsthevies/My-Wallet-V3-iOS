// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A simple structure to represent a generic button.
/// Use this to separate logic with implementation in composed components.
public struct Control: Identifiable {

    public let id: AnyHashable
    public let title: String
    public let action: () -> Void

    public init(
        title: String,
        id: AnyHashable = UUID(),
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.action = action
    }
}

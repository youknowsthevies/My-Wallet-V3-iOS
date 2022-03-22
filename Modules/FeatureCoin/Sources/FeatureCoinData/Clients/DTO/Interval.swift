// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Interval: Hashable {
    public let value: Int
    public let component: Calendar.Component
}

public struct Scale: Hashable {
    public let value: Int
}

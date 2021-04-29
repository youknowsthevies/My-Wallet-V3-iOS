// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PageResult<M: Tokenized> {
    public let hasNextPage: Bool
    public let items: [M]
    
    public init(hasNextPage: Bool, items: [M]) {
        self.hasNextPage = hasNextPage
        self.items = items
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct NabuSessionTokenError: Decodable {

    public let type: String
    public let description: String

    public init(
        type: String,
        description: String
    ) {
        self.type = type
        self.description = description
    }
}

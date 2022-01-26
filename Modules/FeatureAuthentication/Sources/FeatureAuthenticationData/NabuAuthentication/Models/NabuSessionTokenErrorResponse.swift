// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Model encapsulating the network response error from the `/auth` endpoint.
public struct NabuSessionTokenErrorResponse: Decodable {
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

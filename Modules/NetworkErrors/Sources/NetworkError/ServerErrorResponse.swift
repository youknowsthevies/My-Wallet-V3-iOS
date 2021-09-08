// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ServerErrorResponse: Error {
    public let response: HTTPURLResponse
    public let payload: Data?

    public init(response: HTTPURLResponse, payload: Data?) {
        self.response = response
        self.payload = payload
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import NetworkError

extension NetworkError {

    static let notFoundError: NetworkError = .rawServerError(
        .init(
            response: HTTPURLResponse.notFoundResponse()!,
            payload: nil
        )
    )
}

extension HTTPURLResponse {

    fileprivate static func notFoundResponse(
        url: URL = URL(string: "https://www.blockchain.com/")!,
        httpVersion HTTPVersion: String? = "HTTP/1.1",
        headerFields: [String: String]? = [:]
    ) -> Self? {
        Self(
            url: url,
            statusCode: 404,
            httpVersion: HTTPVersion,
            headerFields: headerFields
        )
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Array where Element == NetworkRequest {
    public subscript(method: NetworkRequest.NetworkMethod, url: URL) -> NetworkRequest? {
        first(where: { $0.method == method && $0.urlRequest.url == url })
    }
}

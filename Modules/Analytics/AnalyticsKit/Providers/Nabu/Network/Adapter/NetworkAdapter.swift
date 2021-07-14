// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

protocol NetworkAdapterAPI {
    func performRequest(request: Request) -> AnyPublisher<Never, URLError>
}

class NetworkAdapter: NetworkAdapterAPI {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func performRequest(request: Request) -> AnyPublisher<Never, URLError> {
        session.dataTaskPublisher(for: request.asURLRequest())
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
}

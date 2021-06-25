// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

protocol NetworkAdapterAPI {
    func performRequest(request: Request) -> AnyPublisher<Void, URLError>
}

class NetworkAdapter: NetworkAdapterAPI {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func performRequest(request: Request) -> AnyPublisher<Void, URLError> {
        session.dataTaskPublisher(for: request.asURLRequest())
            .map { output in
                print(String(data: output.data, encoding: .utf8) ?? "")
                return ()
            }
            .eraseToAnyPublisher()
    }
}

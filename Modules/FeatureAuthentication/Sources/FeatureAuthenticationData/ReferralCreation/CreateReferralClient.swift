// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureAuthenticationDomain
import Foundation
import NetworkKit

public struct CheckReferralClient: CheckReferralClientAPI {
    // MARK: - Private Properties

    private enum Path {
        static let referral = ["referral"]
    }

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func checkReferral(with code: String) -> AnyPublisher<Void, NetworkError> {
        let request = requestBuilder.get(
            path: ["referral", code]
        )!

        return networkAdapter
            .perform(request: request)
            .eraseToAnyPublisher()
    }
}

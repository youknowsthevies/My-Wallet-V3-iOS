// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError
import NetworkKit

public protocol ClaimEligibilityClientAPI {

    func getEligibility() -> AnyPublisher<ClaimEligibilityResponse, NabuNetworkError>
}

public final class ClaimEligibilityClient: ClaimEligibilityClientAPI {

    // MARK: - Type

    private enum Path {
        static let eligibility = [
            "users",
            "domain-campaigns",
            "eligibility"
        ]
    }

    // MARK: - Properties

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

    // MARK: - API

    public func getEligibility() -> AnyPublisher<ClaimEligibilityResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: "domainCampaign",
                value: "UNSTOPPABLE_DOMAINS"
            )
        ]
        let request = requestBuilder.get(
            path: Path.eligibility,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}

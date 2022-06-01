// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import Foundation
import NetworkKit

protocol WithdrawalLocksClientAPI {
    func fetchWithdrawalLocks(
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocksResponse, NabuNetworkError>
}

final class APIClient: WithdrawalLocksClientAPI {

    private enum Path {
        static let withdrawalLocks = ["payments", "withdrawals", "locks"]
    }

    fileprivate enum Parameter {
        static let currency = "currency"
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func fetchWithdrawalLocks(
        currencyCode: String
    ) -> AnyPublisher<WithdrawalLocksResponse, NabuNetworkError> {
        let queryParameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: currencyCode
            )
        ]
        let request = requestBuilder.get(
            path: Path.withdrawalLocks,
            parameters: queryParameters,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}

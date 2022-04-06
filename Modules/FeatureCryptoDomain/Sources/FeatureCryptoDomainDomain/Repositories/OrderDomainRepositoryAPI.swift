// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NabuNetworkError

public enum OrderDomainRepositoryError: Equatable, Error {
    case networkError(NabuNetworkError)
}

public protocol OrderDomainRepositoryAPI {

    /// Create a claim order such that a free domain (domainName) is minted to the walletAddress
    /// - Parameters
    ///   - isFree: whether the domain is free or not (if not free, will have redirection to a purchase site instead)
    ///   - domainName: the domain name to be claimed
    ///   - resolutionRecords: the resolution records for keeping the relationship of wallet address and domain
    /// - Returns
    ///   - if the domain is free, it will return an order number
    ///   - if the domain is premium, it will return a redirection url
    func createDomainOrder(
        isFree: Bool,
        domainName: String,
        resolutionRecords: [ResolutionRecord]?
    ) -> AnyPublisher<OrderDomainResult, OrderDomainRepositoryError>
}

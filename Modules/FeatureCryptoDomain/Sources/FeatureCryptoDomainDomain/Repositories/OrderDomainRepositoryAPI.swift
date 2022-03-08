// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public enum OrderDomainRepositoryError: Equatable, Error {
    case networkError(NetworkError)
}

public protocol OrderDomainRepositoryAPI {

    /// Create a claim order such that a free domain (domainName) is minted to the walletAddress
    /// - Parameters
    ///   - isFree: whether the domain is free or not (if not free, will have redirection to a purchase site instead)
    ///   - domainName: the domain name to be claimed
    ///   - walletAddress: the wallet address where the domain is to be minted to
    ///   - nabuUserId: to update eligibiltiy status for the user after the claim
    /// - Returns
    ///   - if the domain is free, it will return an order number
    ///   - if the domain is premium, it will return a redirection url
    func createDomainOrder(
        isFree: Bool,
        domainName: String,
        walletAddress: String,
        nabuUserId: String
    ) -> AnyPublisher<OrderDomainResult, OrderDomainRepositoryError>
}

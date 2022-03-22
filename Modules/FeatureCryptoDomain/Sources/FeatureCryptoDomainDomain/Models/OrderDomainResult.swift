// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct OrderDomainResult: Equatable, Hashable {
    public let domainType: DomainType
    public let orderNumber: Int?
    public let redirectUrl: String?

    public init(
        domainType: DomainType,
        orderNumber: Int?,
        redirectUrl: String?
    ) {
        self.domainType = domainType
        self.orderNumber = orderNumber
        self.redirectUrl = redirectUrl
    }
}

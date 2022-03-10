// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct OrderDomainUserInfo: Equatable {
    public let nabuUserId: String
    public let nabuUserName: String?
    public let ethereumAddress: String

    public init(
        nabuUserId: String,
        nabuUserName: String?,
        ethereumAddress: String
    ) {
        self.nabuUserId = nabuUserId
        self.nabuUserName = nabuUserName
        self.ethereumAddress = ethereumAddress
    }
}

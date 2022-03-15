// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct OrderDomainUserInfo: Equatable {
    public let nabuUserId: String
    public let nabuUserName: String?
    public let resolutionRecords: [ResolutionRecord]

    public init(
        nabuUserId: String,
        nabuUserName: String?,
        resolutionRecords: [ResolutionRecord]
    ) {
        self.nabuUserId = nabuUserId
        self.nabuUserName = nabuUserName
        self.resolutionRecords = resolutionRecords
    }
}

public struct ResolutionRecord: Equatable {
    public let symbol: String
    public let walletAddress: String

    public init(
        symbol: String,
        walletAddress: String
    ) {
        self.symbol = symbol
        self.walletAddress = walletAddress
    }
}

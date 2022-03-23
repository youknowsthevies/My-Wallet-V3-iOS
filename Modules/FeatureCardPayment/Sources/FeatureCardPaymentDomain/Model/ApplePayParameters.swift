// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct ApplePayParameters: Codable, Equatable {
    public let token: ApplePayToken
    public let beneficiaryId: String
}

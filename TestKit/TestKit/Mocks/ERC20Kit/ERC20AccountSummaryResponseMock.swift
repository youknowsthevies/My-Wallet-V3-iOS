// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20Kit
import PlatformKit

extension ERC20AccountSummaryResponse where Token == PaxToken {
    static var accountResponseMock: ERC20AccountSummaryResponse {
        ERC20AccountSummaryResponse(
            balance: CryptoValue.pax(major: "2.0")!.amount.string(unitDecimals: 0)
        )
    }
}

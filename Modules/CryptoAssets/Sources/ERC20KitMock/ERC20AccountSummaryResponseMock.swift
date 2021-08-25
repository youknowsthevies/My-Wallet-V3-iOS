// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20Kit
import PlatformKit

extension ERC20AccountSummaryResponse {
    static func accountResponseMock(cryptoCurrency: CryptoCurrency) -> ERC20AccountSummaryResponse {
        ERC20AccountSummaryResponse(
            balance: CryptoValue.create(major: "2.0", currency: cryptoCurrency)!.amount.string(unitDecimals: 0)
        )
    }
}

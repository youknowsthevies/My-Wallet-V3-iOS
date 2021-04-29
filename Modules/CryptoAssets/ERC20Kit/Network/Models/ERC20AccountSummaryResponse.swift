// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct ERC20AccountSummaryResponse<Token: ERC20Token>: Decodable {
    let balance: String
}

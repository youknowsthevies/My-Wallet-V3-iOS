// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct ERC20IsContractResponse<Token: ERC20Token>: Decodable {
    let contract: Bool
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct AccountResponse: Equatable, Codable {
    let label: String
    let archived: Bool
    let defaultDerivation: DerivationResponse.Format
    let derivations: [DerivationResponse]
}

extension WalletPayloadKit.Account {
    convenience init(index: Int, model: AccountResponse) {
        self.init(
            index: index,
            label: model.label,
            archived: model.archived,
            defaultDerivation: DerivationResponse.Format.create(from: model.defaultDerivation),
            derivations: model.derivations.map(WalletPayloadKit.Derivation.init(from:))
        )
    }
}

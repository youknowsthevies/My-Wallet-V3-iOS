// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension WalletResponseModels {
    struct Account: Equatable, Codable {
        let label: String
        let archived: Bool
        let defaultDerivation: WalletResponseModels.Derivation.Format
        let derivations: [WalletResponseModels.Derivation]
    }
}

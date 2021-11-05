// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Account: Equatable, Codable {
    let label: String
    let archived: Bool
    let defaultDerivation: Derivation.Format
    let derivations: [Derivation]

    func derivation(for format: Derivation.Format) -> Derivation? {
        derivations.first { $0.type == format }
    }
}

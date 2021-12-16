// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Account: Equatable {
    var index: Int
    var label: String
    var archived: Bool
    var defaultDerivation: DerivationType
    var derivations: [Derivation]

    var defaultDerivationAccount: Derivation? {
        derivations.first(where: { $0.type == defaultDerivation })
    }

    init(
        index: Int,
        label: String,
        archived: Bool,
        defaultDerivation: DerivationType,
        derivations: [Derivation]
    ) {
        self.index = index
        self.label = label
        self.archived = archived
        self.defaultDerivation = defaultDerivation
        self.derivations = derivations
    }

    func derivation(for format: DerivationType) -> Derivation? {
        derivations.first { $0.type == format }
    }
}

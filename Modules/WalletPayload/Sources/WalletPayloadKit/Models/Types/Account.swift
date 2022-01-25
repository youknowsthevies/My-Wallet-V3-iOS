// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class Account: Equatable {
    var index: Int
    var label: String
    var archived: Bool
    var defaultDerivation: DerivationType
    var derivations: [Derivation]

    var defaultDerivationAccount: Derivation? {
        derivations.first(where: { $0.type == defaultDerivation })
    }

    public init(
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

func createAccount(
    label: String,
    derivations: [Derivation]
) -> Account {
    Account(
        index: 0,
        label: label,
        archived: false,
        defaultDerivation: .segwit,
        derivations: derivations
    )
}

extension Account {
    public static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.index == rhs.index
            && lhs.label == rhs.label
            && lhs.archived == rhs.archived
            && lhs.defaultDerivation == rhs.defaultDerivation
            && lhs.derivations == rhs.derivations
    }
}

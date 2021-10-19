// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum AccountStrategyDecodingError: Error {
    case unknownDerivationType
    case noDerivationsFound
}

enum AccountDecodingError: Error {
    case strategy(AccountStrategyDecodingError)
    case error(Error)
}

/// A decoding method for creating an array of `Account` models
/// - Parameters:
///   - strategy: A closure that transforms an `AccountWrapper` to an `Account`
///   - value: A `AccountWrapper` value
/// - Throws: `AccountDecodingError`
/// - Returns: A newly created `Account`
func decodeAccounts<Version>(
    using strategy: (Version) -> Result<Account, AccountStrategyDecodingError>,
    value: [Version]
) -> Result<[Account], AccountDecodingError> {
    Result {
        try value.compactMap { try strategy($0).get() }
    }
    .flatMapError { error in
        guard let strategyError = error as? AccountStrategyDecodingError else {
            return .failure(.error(error))
        }
        return .failure(.strategy(strategyError))
    }
}

/// A "strategy" for transforming an `AccountWrapper.Version3` to an `Account`
/// - Parameter wrapper: A value of `AccountWrapper.Version3`
/// - Throws: `AccountDecodingError`
/// - Returns: `Account`
func accountWrapperDecodingStrategy(
    version3: AccountWrapper.Version3
) -> Result<Account, AccountStrategyDecodingError> {
    let derivation = Derivation(
        type: .legacy,
        purpose: Derivation.Format.legacy.purpose,
        xpriv: version3.xpriv,
        xpub: version3.xpub,
        addressLabels: version3.addressLabels,
        cache: version3.cache
    )
    return .success(
        Account(
            label: version3.label,
            archived: version3.archived,
            defaultDerivation: .legacy,
            derivations: [derivation]
        )
    )
}

/// A "strategy" for transforming an `AccountWrapper.Version4` to an `Account`
/// - Parameter version4: A value of `AccountWrapper.Version4`
/// - Throws: `AccountDecodingError`
/// - Returns: `Account`
func accountWrapperDecodingStrategy(
    version4: AccountWrapper.Version4
) -> Result<Account, AccountStrategyDecodingError> {
    Result {
        try Derivation.Format(
            rawValue: version4.defaultDerivation
        )
        .or(throw: AccountStrategyDecodingError.unknownDerivationType)
    }
    .replaceError(with: AccountStrategyDecodingError.unknownDerivationType)
    .map { defaultDerivationType -> Account in
        Account(
            label: version4.label,
            archived: version4.archived,
            defaultDerivation: defaultDerivationType,
            derivations: version4.derivations
        )
    }
}

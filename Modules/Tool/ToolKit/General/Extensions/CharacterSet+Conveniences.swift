// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension CharacterSet {
    public func contains(_ character: Character) -> Bool {
        !character.unicodeScalars.contains(where: { !contains($0) })
    }
}

extension CharacterSet {

    /// Returns the character set for character symbols allowed in a URLQueryItem
    public static var urlQueryItemSymbolsAllowed = CharacterSet(
        charactersIn: "!*'();:@&=+$,/?%#[] "
    ).inverted
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum TextValidation {
    public static func walletIdentifierValidator(_ value: String) -> Bool {
        value.range(of: TextRegex.walletIdentifier.rawValue, options: .regularExpression) != nil
    }
}

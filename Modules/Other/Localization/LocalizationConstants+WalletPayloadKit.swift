//
//  LocalizationConstants+WalletPayloadKit.swift
//  Localization
//
//  Created by Jack Pooley on 02/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension LocalizationConstants {
    public enum WalletPayloadKit {}
}

extension LocalizationConstants.WalletPayloadKit {
    public enum Error {
        public static let unknown = NSLocalizedString(
            "Something went wrong.",
            comment: "Something went wrong."
        )
        public static let decryptionFailed = NSLocalizedString(
            "Error decrypting wallet, please check that your password is correct",
            comment: "Error decrypting wallet, please check that your password is correct"
        )
    }
}

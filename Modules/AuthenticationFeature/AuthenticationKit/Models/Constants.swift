// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum Constants {

    public enum Url {
        public static var resetTwoFA: String {
            "https://\(loginHost)/#/reset-2fa"
        }

        /// A url string that points to Blockchain login page
        public static var loginOnWeb: String {
            "https://\(loginHost)/#/login"
        }

        public static var terms: String {
            "https://\(blockchainHost)/terms"
        }

        public static var privacyPolicy: String {
            "https://\(blockchainHost)/privacy"
        }
    }

    public enum SecondPassword {
        /// A url string that points to Blockchain support page for enabling 2FA
        public static let twoFASupportLink = "https://support.blockchain.com/hc/en-us/articles/211164103"
    }

    private static let loginHost: String = InfoDictionaryHelper.value(for: .loginUrl)
    private static let blockchainHost: String = InfoDictionaryHelper.value(for: .blockchainUrl)
}

class AuthenticationKitBundle {}

private enum InfoDictionaryHelper {
    enum Key: String {
        case loginUrl = "LOGIN_URL"
        case blockchainUrl = "BLOCKCHAIN_URL"
    }

    private static let infoDictionary = Bundle(for: AuthenticationKitBundle.self).infoDictionary

    static func value(for key: Key) -> String! {
        infoDictionary?[key.rawValue] as? String
    }

    static func value(for key: Key, prefix: String) -> String! {
        guard let value = value(for: key) else {
            return nil
        }
        return prefix + value
    }
}

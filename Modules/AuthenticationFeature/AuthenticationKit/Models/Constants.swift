// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum Constants {

    public enum Url {
        public static var resetTwoFA: String {
            "https://\(loginHost)/#/reset-2fa"
        }

        public static var terms: String {
            "https://\(blockchainHost)/terms"
        }

        public static var privacyPolicy: String {
            "https://\(blockchainHost)/privacy"
        }
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

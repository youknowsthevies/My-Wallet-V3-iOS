// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum Constants {

    public enum Url {
        public static var resetTwoFA: String {
            "https://\(loginHost)/#/reset-2fa"
        }
    }

    private static let loginHost: String = InfoDictionaryHelper.value(for: .loginUrl)
}

class AuthenticationKitBundle {}

private enum InfoDictionaryHelper {
    enum Key: String {
        case loginUrl = "LOGIN_URL"
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

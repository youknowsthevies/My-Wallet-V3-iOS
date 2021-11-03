// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import struct Foundation.URL

extension OpenBanking {

    public struct Key: Hashable {
        let name: String
        init(_ name: String, _ type: Any.Type) { self.name = name }
    }
}

extension OpenBanking.Key {
    private static let my = "blockchain.api.OpenBanking"
}

extension OpenBanking.Key {
    public static let id = Self(my + ".id", String.self)
    public static let account = Self(my + ".account", OpenBanking.BankAccount.self)
    public static let currency = Self(my + ".currency", String.self)
    public static let error = (
        code: Self(my + ".error.code", String.self), ()
    )
    public static let authorisation = (
        url: Self(my + ".authorisation.url", URL.self), ()
    )
    public static let consent = (
        token: Self(my + ".consent.token", String.self),
        error: Self(my + ".consent.error", OpenBanking.Error.self)
    )
    public static let callback = (
        path: Self(my + ".callback.path", String.self),
        base: (
            url: Self(my + ".callback.base.url", URL.self), ()
        )
    )
    public static let `is` = (
        authorised: Self(my + ".is.authorised", Bool.self), ()
    )
}

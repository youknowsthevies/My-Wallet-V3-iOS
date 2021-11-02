// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension OpenBanking {

    public struct Key: Hashable {
        let name: String
    }
}

extension OpenBanking.Key {
    private static let my = "blockchain.api.OpenBanking"
    public static let id = Self(name: my + ".id")
    public static let currency = Self(name: my + ".currency")
    public static let error = (
        code: Self(name: my + ".error.code"), ()
    )
    public static let authorisation = (
        url: Self(name: my + ".authorisation.url"), ()
    )
    public static let consent = (
        token: Self(name: my + ".consent.token"),
        error: Self(name: my + ".consent.error")
    )
    public static let callback = (
        path: Self(name: my + ".callback.path"),
        base: (
            url: Self(name: my + ".callback.base.url"), ()
        )
    )
    public static let `is` = (
        authorised: Self(name: my + ".is.authorised"), ()
    )
}

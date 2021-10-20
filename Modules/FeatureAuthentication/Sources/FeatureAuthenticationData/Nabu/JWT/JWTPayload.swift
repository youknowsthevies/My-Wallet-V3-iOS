// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct JWTPayload: Encodable {
    let jwt: String

    public init(jwt: String) {
        self.jwt = jwt
    }
}

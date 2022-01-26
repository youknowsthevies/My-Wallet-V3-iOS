// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct NabuUserRecoveryPayload: Encodable {
    let jwt: String
    let recoveryToken: String

    public init(jwt: String, recoveryToken: String) {
        self.jwt = jwt
        self.recoveryToken = recoveryToken
    }
}

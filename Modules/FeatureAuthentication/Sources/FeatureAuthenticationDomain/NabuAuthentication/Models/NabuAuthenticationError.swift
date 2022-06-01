// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors

public enum NabuAuthenticationError: Error, Equatable {

    /// 401
    case tokenExpired(statusCode: Int)

    /// 409
    case alreadyRegistered(statusCode: Int, walletIdHint: String)

    public init?(error: NetworkError) {
        guard case .rawServerError(let serverError) = error.type else {
            return nil
        }
        switch serverError.response.statusCode {
        case 401:
            self = .tokenExpired(statusCode: 401)
        case 409:
            guard let payload = serverError.payload,
                  let decodedPayload = try? payload.decode(to: NabuSessionTokenError.self)
            else {
                return nil
            }
            self = .alreadyRegistered(
                statusCode: 409,
                // getting only the last 11 letters as the wallet ID
                walletIdHint: String(decodedPayload.description.suffix(11))
            )
        default:
            return nil
        }
    }
}

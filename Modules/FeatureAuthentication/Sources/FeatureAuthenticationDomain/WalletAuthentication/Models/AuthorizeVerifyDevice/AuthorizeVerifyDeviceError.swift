// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation

public enum AuthorizeVerifyDeviceError: Error, Equatable {

    /// 400
    case linkExpired

    /// 401
    case confirmationRequired(requestTime: Date, details: DeviceVerificationDetails)

    /// 409
    case requestDenied

    /// Other status code
    case network(NetworkError)

    public init?(error: NetworkError) {
        guard case .rawServerError(let serverError) = error.type else {
            return nil
        }
        switch serverError.response.statusCode {
        case 400:
            self = .linkExpired
        case 401:
            guard let payload = serverError.payload,
                  let decodedPayload = try? payload.decode(to: ConfirmationRequiredError.self)
            else {
                return nil
            }
            self = .confirmationRequired(
                requestTime: decodedPayload.requestTime,
                details: decodedPayload.requester
            )
        case 409:
            self = .requestDenied
        default:
            self = .network(error)
        }
    }
}

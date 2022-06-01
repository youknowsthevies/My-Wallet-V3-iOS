// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors
import Foundation

extension NetworkError {

    var is404: Bool {
        guard case .rawServerError(let serverError) = type else {
            return false
        }
        guard serverError.response.statusCode == 404 else {
            return false
        }
        return true
    }
}

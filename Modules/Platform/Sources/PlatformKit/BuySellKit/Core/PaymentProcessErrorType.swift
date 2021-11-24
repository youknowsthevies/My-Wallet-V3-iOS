// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An error returned by 3DS payment processor (e.g. EveryPay).
/// We want to filter out payment errors in activity that
/// are of type `issuer`
public enum PaymentProcessorErrorType {
    case issuer
    case unknown
}

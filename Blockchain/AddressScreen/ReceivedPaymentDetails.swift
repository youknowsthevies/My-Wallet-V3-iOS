// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// Details about a received payment
struct ReceivedPaymentDetails {
    
    /// The amount
    let amount: String
    
    /// The type of the asset
    let asset: CryptoCurrency
    
    /// The address
    let address: String
}

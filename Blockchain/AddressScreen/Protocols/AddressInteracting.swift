// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift

protocol AddressInteracting {
    
    /// The associated asset
    var asset: CryptoCurrency { get }
    
    /// The current address
    var address: Single<WalletAddressContent> { get }
    
    /// Streams payments received to that address
    var receivedPayment: Observable<ReceivedPaymentDetails> { get }
}

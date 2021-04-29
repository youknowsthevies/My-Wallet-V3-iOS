// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

/// The interaction protocol for the destination accounto on the send screen
protocol SendDestinationAccountInteracting {
    
    /// The interacted asset
    var asset: CryptoCurrency { get }
    
    /// Streams boolean value on whether the source account is connected to the Exchange and has a valid Exchange address
    var hasExchangeAccount: Observable<Bool> { get }
    
    /// Select exchange address
    var exchangeSelectedRelay: PublishRelay<Bool> { get }
    
    /// Whether 2FA configuration is required to send crypto to the Exchange
    var isTwoFAConfigurationRequired: Observable<Bool> { get }
    
    /// The selected / inserted destination account state
    var accountState: Observable<SendDestinationAccountState> { get }
    
    /// Sets the destination address
    func set(address: String)
}

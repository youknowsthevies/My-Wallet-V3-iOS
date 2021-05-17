// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

@testable import Blockchain
import PlatformKit

class AddressInteractorMock: AddressInteracting {

    let asset: CryptoCurrency
    let address: Single<WalletAddressContent>
    let receivedPayment: Observable<ReceivedPaymentDetails>

    init(asset: CryptoCurrency,
         address: WalletAddressContent,
         receivedPayment: ReceivedPaymentDetails) {
        self.asset = asset
        self.address = .just(address)
        self.receivedPayment = .just(receivedPayment)
    }
}

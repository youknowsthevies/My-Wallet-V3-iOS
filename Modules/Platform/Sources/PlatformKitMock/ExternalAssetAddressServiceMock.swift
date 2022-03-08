// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxSwift

final class ExternalAssetAddressServiceMock: ExternalAssetAddressServiceAPI {

    var underlyingResult: Result<
        CryptoReceiveAddress, CryptoReceiveAddressFactoryError
    > = .failure(.invalidAddress)

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        underlyingResult
    }
}

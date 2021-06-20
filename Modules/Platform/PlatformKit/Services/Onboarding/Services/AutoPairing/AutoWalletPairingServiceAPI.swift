// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// A service API for auto pairing
public protocol AutoWalletPairingServiceAPI: AnyObject {
    /// Maps a QR pairing code of a wallet into its password.
    func pair(using pairingData: PairingData) -> Single<String>
}

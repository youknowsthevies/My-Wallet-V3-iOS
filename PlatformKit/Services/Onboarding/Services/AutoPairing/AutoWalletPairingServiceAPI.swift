//
//  AutoWalletPairingServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 20/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// A service API for auto pairing
public protocol AutoWalletPairingServiceAPI: class {
    /// Maps a QR pairing code of a wallet into its password.
    func pair(using pairingData: PairingData) -> Single<String>
}

//
//  AutoWalletPairingClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 20/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol AutoWalletPairingClientAPI: class {
    func request(guid: String) -> Single<String>
}

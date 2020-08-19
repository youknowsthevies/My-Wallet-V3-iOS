//
//  SingleAccount.swift
//  PlatformKit
//
//  Created by Paulo on 03/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol SingleAccount : BlockchainAccount {
    var receiveAddress: Single<ReceiveAddress> { get }
    var isDefault: Bool { get }

    var sendState: Single<SendState> { get }
    func createSendProcessor(address: ReceiveAddress) -> Single<SendProcessor>
}

public extension SingleAccount {
    var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    var sendState: Single<SendState> {
        .just(.notSupported)
    }

    func createSendProcessor(address: ReceiveAddress) -> Single<SendProcessor> {
        unimplemented()
    }
}

//
//  ReceiveScreenInteractor.swift
//  TransactionUIKit
//
//  Created by Paulo on 21/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import TransactionKit

final class ReceiveScreenInteractor {

    let account: SingleAccount
    let receiveRouter: ReceiveRouterAPI

    var qrCodeMetadata: Single<CryptoAssetQRMetadata> {
        account
            .receiveAddress
            .map { address -> CryptoAssetQRMetadata in
                guard let address = address as? CryptoAssetQRMetadataProviding else {
                    throw ReceiveAddressError.notSupported
                }
                return address.metadata
            }
    }

    init(account: SingleAccount, receiveRouter: ReceiveRouterAPI = resolve()) {
        self.account = account
        self.receiveRouter = receiveRouter
    }
}

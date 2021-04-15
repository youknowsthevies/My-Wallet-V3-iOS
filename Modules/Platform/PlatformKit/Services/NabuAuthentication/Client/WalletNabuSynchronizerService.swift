//
//  WalletNabuSynchronizerService.swift
//  PlatformKit
//
//  Created by Daniel on 29/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift

/// Protocol definition for a component that can synchronize state between the wallet
/// and Nabu.
public protocol WalletNabuSynchronizerServiceAPI {
    func sync() -> Completable
}

final class WalletNabuSynchronizerService: WalletNabuSynchronizerServiceAPI {

    private let jwtService: JWTServiceAPI
    private let updateUserInformationClient: UpdateWalletInformationClientAPI
    
    init(jwtService: JWTServiceAPI = resolve(),
         updateUserInformationClient: UpdateWalletInformationClientAPI = resolve()) {
        self.jwtService = jwtService
        self.updateUserInformationClient = updateUserInformationClient
    }

    func sync() -> Completable {
        jwtService.token
            .flatMapCompletable(weak: self) { (self, jwtToken) in
                self.updateUserInformationClient.updateWalletInfo(jwtToken: jwtToken)
            }
    }
}

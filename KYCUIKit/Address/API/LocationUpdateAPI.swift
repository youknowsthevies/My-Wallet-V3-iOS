//
//  LocationUpdateAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit
import PlatformKit
import RxSwift

final class LocationUpdateService {
    private let client: KYCClientAPI

    init(client: KYCClientAPI = resolve()) {
        self.client = client
    }

    func update(address: UserAddress) -> Completable {
        client.updateAddress(userAddress: address)
    }
}

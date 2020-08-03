//
//  PersonalDetailsService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import RxSwift
import DIKit

final class PersonalDetailsService {

    private let client: KYCClientAPI
    
    init(client: KYCClientAPI = resolve()) {
        self.client = client
    }

    func update(firstName: String?, lastName: String?, birthday: Date?) -> Completable {
        client.updatePersonalDetails(firstName: firstName, lastName: lastName, birthday: birthday)
    }
}

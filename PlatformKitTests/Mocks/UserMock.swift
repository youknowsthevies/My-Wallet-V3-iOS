//
//  UserMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 07/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

class UserMock: User {
    var email = Email(address: "", verified: false)
    var personalDetails = PersonalDetails(id: nil, first: nil, last: nil, birthday: nil)
    var address: UserAddress?
}

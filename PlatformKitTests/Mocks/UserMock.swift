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
    var personalDetails: PersonalDetails = PersonalDetails(id: nil, first: nil, last: nil, birthday: nil)
}

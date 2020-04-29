//
//  User.swift
//  PlatformKit
//
//  Created by Paulo on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol User {
    var email: Email { get }
    var personalDetails: PersonalDetails { get }
    var address: UserAddress? { get }
}

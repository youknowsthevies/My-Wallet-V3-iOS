//
//  Regex.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 10/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum TextRegex: String {
    case cardholderName = "^.{1,22}$"
    case cvv = "^[0-9]{3,4}$"
    case cardExpirationDate = "^((0[1-9])|(1[0-2]))/[2-9][0-9]$"
    case walletIdentifier = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
    case email = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    case notEmpty = "^.+$"
}

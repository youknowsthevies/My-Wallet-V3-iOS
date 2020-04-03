//
//  SimpleBuyCreditCardProviderType.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum SimpleBuyCreditCardProviderType: String, Decodable {
    case visa
    case mastercard
    case unknown
}

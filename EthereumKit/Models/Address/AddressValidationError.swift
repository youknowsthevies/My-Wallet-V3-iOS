//
//  EthereumAddress.swift
//  EthereumKit
//
//  Created by Jack on 20/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public enum AddressValidationError: Error {
    case unknown
    case containsInvalidCharacters
    case invalidLength
}

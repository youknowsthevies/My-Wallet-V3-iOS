//
//  WalletSendEtherDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 5/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a delegate for Ether related wallet callbacks
@objc protocol WalletSendEtherDelegate: class {

    /// Method invoked when creating an ether account
    func didGetEtherAddressWithSecondPassword()
}

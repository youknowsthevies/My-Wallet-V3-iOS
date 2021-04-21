//
//  BankAccountReceiveAddress.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/20/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public final class BankAccountReceiveAddress: ReceiveAddress {
    public let address: String
    public let label: String
    
    public init(address: String, label: String) {
        self.address = address
        self.label = label
    }
}

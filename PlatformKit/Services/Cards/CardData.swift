//
//  CardData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 03/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct CardData {
    public let ownerName: String
    public let number: String
    public let expirationDate: String
    public let cvv: String
    
    private var billingAddress: BillingAddress!
    
    public init?(ownerName: String?,
                 number: String?,
                 expirationDate: String?,
                 cvv: String?) {
        guard let ownerName = ownerName,
              let number = number,
              let expirationDate = expirationDate,
              let cvv = cvv else {
            return nil
        }
        self.ownerName = ownerName
        self.number = number
        self.expirationDate = expirationDate
        self.cvv = cvv
    }
    
    public func data(byAppending billingAddress: BillingAddress) -> CardData {
        var data = self
        data.billingAddress = billingAddress
        return data
    }
}



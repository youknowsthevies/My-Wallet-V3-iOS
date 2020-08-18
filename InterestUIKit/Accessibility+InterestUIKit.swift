//
//  Accessibility+InterestUIKit.swift
//  InterestUIKit
//
//  Created by Alex McGregor on 8/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

public extension Accessibility.Identifier {
    
    enum Interest {
        enum Dashboard {
            enum Announcement {
                private static let prefix = "InterestAccountAnnouncementScreen."
                static let rateLineItem = "\(prefix)rateLineItem"
                static let paymentIntervalLineItem = "\(prefix)paymentIntervalLineItem"
                static let footerCell = "\(prefix)footerCell"
            }
            enum InterestDetails {
                private static let prefix = "InterestAccoundDetailsScreen."
                static let balanceCellTitle = "\(prefix)balanceCellTitle"
                static let balanceCellDescription = "\(prefix)balanceCellDescription"
                static let balanceCellFiatAmount = "\(prefix)balanceCellFiatAmount"
                static let balanceCellCryptoAmount = "\(prefix)balanceCellCryptoAmount"
                static let lineItem = "\(prefix)lineItem"
                static let footerCellTitle = "\(prefix)footerCellTitle"
            }
        }
    }
}

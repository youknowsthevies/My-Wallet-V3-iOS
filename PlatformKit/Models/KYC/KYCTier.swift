//
//  KYCTier.swift
//  PlatformKit
//
//  Created by Paulo on 07/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension KYC {
    /// Enumerates the different tiers for KYC. A higher tier requires
    /// users to provide us with more information about them which
    /// qualifies them for higher limits of trading.
    ///
    /// - tier1: the 1st tier requiring the user to only provide basic
    ///          user information such as name and address.
    /// - tier2: the 2nd tier requiring the user to provide additional
    ///          identity information such as a drivers licence, passport,
    //           etc.
    public enum Tier: Int, CaseIterable, Codable, Comparable {
        case tier0 = 0
        case tier1 = 1
        case tier2 = 2

        // It's best to use comparison to compare tiers instead of using `==` directly
        // since additional values are likely to be added in future
        public static func < (lhs: Tier, rhs: Tier) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}

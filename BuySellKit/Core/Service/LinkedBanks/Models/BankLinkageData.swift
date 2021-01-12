//
//  BankLinkageData.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 10/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct BankLinkageData {
    public enum Partner {
        case yodlee
        case yapily
    }
    public let token: String?
    public let fastlinkUrl: String?
    public let partner: Partner

    init?(from response: CreateBankLinkageResponse) {
        guard let attributes = response.attributes else {
            return nil
        }
        token = attributes.token
        fastlinkUrl = attributes.fastlinkUrl
        partner = Partner(from: response.partner)
    }
}

extension BankLinkageData.Partner {
    init(from response: BankLinkagePartner) {
        switch response {
        case .yodlee:
            self = .yodlee
        case .yapily:
            self = .yapily
        }
    }

    public var title: String {
        switch self {
        case .yodlee:
            return "Yodlee"
        case .yapily:
            return "Yapily"
        }
    }
}

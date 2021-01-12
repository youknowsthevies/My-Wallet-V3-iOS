//
//  LinkedBanksResponse.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct LinkedBankResponse: Decodable {
    struct Details: Decodable {
        enum AccountType: String, Decodable {
            case savings = "SAVINGS"
            case checking = "CHECKING"
        }
        let bankAccountType: AccountType
        let bankName: String
        let accountName: String
        let accountNumber: String
        let routingNumber: String
    }
    let id: String
    let currency: String
    let partner: String
    let state: State
    let details: Details?
    let error: Error?
}

extension LinkedBankResponse {
    public enum State: String, Codable {
        case pending = "PENDING"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    public enum Error: String, Codable {
        case alreadyLinked = "BANK_TRANSFER_ACCOUNT_ALREADY_LINKED"
        case unsuportedAccount = "BANK_TRANSFER_ACCOUNT_INFO_NOT_FOUND"
        case namesMissmatched = "BANK_TRANSFER_ACCOUNT_NAME_MISMATCH"
        case unknown = ""
    }
}

enum BankLinkagePartner: String, Decodable {
    case yodlee = "YODLEE"
    case yapily = "YAPILY"
}

struct CreateBankLinkageResponse: Decodable {
    struct LinkBankAttrsResponse: Decodable {
        let token: String?
        let fastlinkUrl: String?
        let fastlinkParams: FastlinkParameters?
    }
    let id: String
    let partner: BankLinkagePartner
    let attributes: LinkBankAttrsResponse?
}

/// The specific configuration for when requesting the webview of the partner (Yodlee/Yapily)
struct FastlinkParameters: Decodable {
    let configName: String
}

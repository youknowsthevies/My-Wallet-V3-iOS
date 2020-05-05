//
//  NabuUser.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

struct NabuUser: Decodable {

    // MARK: - Types

    enum UserState: String, Codable {
        case none = "NONE"
        case created = "CREATED"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    // MARK: - Properties

    let personalDetails: PersonalDetails
    let address: UserAddress?
    let email: Email
    let mobile: Mobile?
    let status: KYC.AccountStatus
    let state: UserState
    let tiers: KYC.UserState?
    let tags: Tags?
    let needsDocumentResubmission: DocumentResubmission?
    let userName: String?
    let depositAddresses: [DepositAddress]
    let settings: NabuUserSettings?

    /// ISO-8601 Timestamp w/millis, eg 2018-08-15T17:00:45.129Z
    let kycCreationDate: String?

    /// ISO-8601 Timestamp w/millis, eg 2018-08-15T17:00:45.129Z
    let kycUpdateDate: String?

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case address
        case status = "kycState"
        case state
        case tags
        case tiers
        case needsDocumentResubmission = "resubmission"
        case userName
        case settings
        case kycCreationDate = "insertedAt"
        case kycUpdateDate = "updatedAt"
        case depositAddresses = "walletAddresses"
    }

    // MARK: - Init

    init(
        hasLinkedExchangeAccount: Bool = false,
        personalDetails: PersonalDetails,
        address: UserAddress?,
        email: Email,
        mobile: Mobile?,
        status: KYC.AccountStatus,
        state: UserState,
        tags: Tags?,
        tiers: KYC.UserState?,
        needsDocumentResubmission: DocumentResubmission?,
        userName: String? = nil,
        depositAddresses: [DepositAddress] = [],
        settings: NabuUserSettings? = nil,
        kycCreationDate: String? = nil,
        kycUpdateDate: String? = nil
    ) {
        self.personalDetails = personalDetails
        self.address = address
        self.email = email
        self.mobile = mobile
        self.status = status
        self.state = state
        self.tags = tags
        self.tiers = tiers
        self.needsDocumentResubmission = needsDocumentResubmission
        self.userName = userName
        self.depositAddresses = depositAddresses
        self.settings = settings
        self.kycCreationDate = kycCreationDate
        self.kycUpdateDate = kycUpdateDate
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try values.decodeIfPresent(UserAddress.self, forKey: .address)
        tiers = try values.decodeIfPresent(KYC.UserState.self, forKey: .tiers)
        userName = try values.decodeIfPresent(String.self, forKey: .userName)
        settings = try values.decodeIfPresent(NabuUserSettings.self, forKey: .settings)
        personalDetails = try PersonalDetails(from: decoder)
        email = try Email(from: decoder)
        mobile = try? Mobile(from: decoder)
        status = (try? values.decode(KYC.AccountStatus.self, forKey: .status)) ?? . none
        state = (try? values.decode(UserState.self, forKey: .state)) ?? .none
        tags = try values.decodeIfPresent(Tags.self, forKey: .tags)
        needsDocumentResubmission = try values.decodeIfPresent(DocumentResubmission.self, forKey: .needsDocumentResubmission)
        kycCreationDate = try values.decodeIfPresent(String.self, forKey: .kycCreationDate)
        kycUpdateDate = try values.decodeIfPresent(String.self, forKey: .kycUpdateDate)

        depositAddresses = (try values.decodeIfPresent([String: String].self, forKey: .depositAddresses))
            .flatMap({ data -> [DepositAddress] in
                return data.compactMap { (key, value) -> DepositAddress? in
                    return DepositAddress(stringType: key, address: value)
                }
            }) ?? []
    }
}

extension NabuUser: User { }

extension NabuUser {
    var hasLinkedExchangeAccount: Bool {
        return settings != nil
    }
}

extension NabuUser {
    var isGoldTierVerified: Bool {
        guard let tiers = tiers else { return false }
        return tiers.current == .tier2
    }
}

extension NabuUser: NabuUserSunriverAirdropRegistering {
    var isSunriverAirdropRegistered: Bool {
        return tags?.sunriver != nil
    }
}

extension NabuUser: NabuUserBlockstackAirdropRegistering {
    var isBlockstackAirdropRegistered: Bool {
        return tags?.blockstack != nil
    }
}

extension NabuUser: NabuUserSimpleBuyEnabled {
    var isSimpleBuyEnabled: Bool {
        tags?.simpleBuy != nil
    }
}

struct Mobile: Decodable {
    let phone: String
    let verified: Bool

    enum CodingKeys: String, CodingKey {
        case phone = "mobile"
        case verified = "mobileVerified"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        phone = try values.decode(String.self, forKey: .phone)
        verified = try values.decodeIfPresent(Bool.self, forKey: .verified) ?? false
    }

    init(phone: String, verified: Bool) {
        self.phone = phone
        self.verified = verified
    }
}

struct Tags: Decodable {
    let sunriver: Sunriver?
    let blockstack: Blockstack?
    let powerPax: PowerPax?
    let simpleBuy: SimpleBuy?
    
    enum CodingKeys: String, CodingKey {
        case sunriver = "SUNRIVER"
        case blockstack = "BLOCKSTACK"
        case powerPax = "POWER_PAX"
        case simpleBuy = "SIMPLE_BUY"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sunriver = try values.decodeIfPresent(Sunriver.self, forKey: .sunriver)
        blockstack = try values.decodeIfPresent(Blockstack.self, forKey: .blockstack)
        powerPax = try values.decodeIfPresent(PowerPax.self, forKey: .powerPax)
        simpleBuy = try values.decodeIfPresent(SimpleBuy.self, forKey: .simpleBuy)
    }

    init(sunriver: Sunriver? = nil,
         blockstack: Blockstack? = nil,
         powerPax: PowerPax? = nil,
         simpleBuy: SimpleBuy? = nil) {
        self.sunriver = sunriver
        self.blockstack = blockstack
        self.powerPax = powerPax
        self.simpleBuy = simpleBuy
    }

    struct Sunriver: Decodable {
        let campaignAddress: String

        enum CodingKeys: String, CodingKey {
            case campaignAddress = "x-campaign-address"
        }
    }
    
    struct SimpleBuy: Decodable {}

    struct Blockstack: Decodable {
        let campaignAddress: String

        enum CodingKeys: String, CodingKey {
            case campaignAddress = "x-campaign-address"
        }
    }

    struct PowerPax: Decodable {
        let campaignAddress: String

        enum CodingKeys: String, CodingKey {
            case campaignAddress = "x-campaign-address"
        }
    }
    
    var containsSimpleBuy: Bool {
        simpleBuy != nil
    }
}

struct DocumentResubmission: Decodable {
    let reason: Int

    enum CodingKeys: String, CodingKey {
        case reason
    }
}

struct DepositAddress {
    let type: CryptoCurrency
    let address: String

    init?(stringType: String, address: String) {
        guard let type = CryptoCurrency(rawValue: stringType.uppercased()) else { return nil }
        self.init(type: type, address: address)
    }

    init(type: CryptoCurrency, address: String) {
        self.type = type
        self.address = address
    }
}

struct NabuUserSettings: Decodable {
    let mercuryEmailVerified: Bool

    enum CodingKeys: String, CodingKey {
        case mercuryEmailVerified = "MERCURY_EMAIL_VERIFIED"
    }
}

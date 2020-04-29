//
//  AnnouncementType.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 28/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// The announcement types as defined remotely
public enum AnnouncementType: String, Codable {
    case simpleBuyKYCIncomplete = "sb_finish_signup"
    case simpleBuyPendingTransaction = "sb_pending_buy"
    case walletIntro = "wallet_intro"
    case buyBitcoin = "buy_btc"
    case verifyEmail = "verify_email"
    case transferBitcoin = "transfer_btc"
    case exchangeLinking = "pit_linking"
    case twoFA = "two_fa"
    case backupFunds = "backup_funds"
    case verifyIdentity = "kyc_incomplete"
    case resubmitDocuments = "kyc_resubmit"
    case blockstackAirdropReceived = "stx_airdrop_complete"
    case blockstackAirdropRegisteredMini = "stx_registered_airdrop_mini"
    case swap = "swap"
    case pax = "pax"
    case bitpay = "bitpay"
    case kycAirdrop = "kyc_airdrop"

    /// The key indentifying the announcement in cache
    var key: AnnouncementRecord.Key {
        switch self {
        case .blockstackAirdropReceived:
            return .blockstackAirdropReceived
        case .blockstackAirdropRegisteredMini:
            return .blockstackAirdropRegisteredMini
        case .walletIntro:
            return .walletIntro
        case .verifyEmail:
            return .verifyEmail
        case .buyBitcoin:
            return .buyBitcoin
        case .transferBitcoin:
            return .transferBitcoin
        case .kycAirdrop:
            return .kycAirdrop
        case .exchangeLinking:
            return .exchange
        case .twoFA:
            return .twoFA
        case .backupFunds:
            return .backupFunds
        case .verifyIdentity:
            return .identityVerification
        case .swap:
            return .swap
        case .pax:
            return .pax
        case .bitpay:
            return .bitpay
        case .resubmitDocuments:
            return .resubmitDocuments
        case .simpleBuyPendingTransaction:
            return .simpleBuyPendingTransaction
        case .simpleBuyKYCIncomplete:
            return .simpleBuyKYCIncomplete
        }
    }
}

//
//  SettingsSectionType.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import PlatformUIKit
import RxDataSources

enum SettingsSectionType: Int, Equatable {
    case profile = 1
    case preferences = 2
    case connect = 3
    case security = 4
    case cards = 5
    case about = 6
    
    enum CellType: Equatable, IdentifiableType {
        
        var identity: AnyHashable {
            switch self {
            case .badge(let type, _):
                return type.rawValue
            case .cards(let type):
                return type.identity
            case .clipboard(let type):
                return type.rawValue
            case .plain(let type):
                return type.rawValue
            case .switch(let type, _):
                return type.rawValue
            }
        }
        
        static func == (lhs: SettingsSectionType.CellType, rhs: SettingsSectionType.CellType) -> Bool {
            switch (lhs, rhs) {
            case (.badge(let left, _), .badge(let right, _)):
                return left == right
            case (.switch(let left, _), .switch(let right, _)):
                return left == right
            case (.clipboard(let left), .clipboard(let right)):
                return left == right
            case (.cards(let left), .cards(let right)):
                return left == right
            case (.plain(let left), .plain(let right)):
                return left == right
            default:
                return false
            }
        }
        
        case badge(BadgeCellType, BadgeCellPresenting)
        case `switch`(SwitchCellType, SwitchCellPresenting)
        case clipboard(ClipboardCellType)
        case cards(CardsCellType)
        case plain(PlainCellType)
        
        enum BadgeCellType: String {
            case limits
            case emailVerification
            case mobileVerification
            case currencyPreference
            case pitConnection
            case recoveryPhrase
        }
        
        enum SwitchCellType: String {
            case sms2FA
            case emailNotifications
            case bioAuthentication
            case swipeToReceive
        }
        
        enum ClipboardCellType: String {
            case walletID
        }
        
        enum CardsCellType: Equatable, IdentifiableType {
            
            var identity: AnyHashable {
                switch self {
                case .skeleton(let index):
                    return "skeleton.\(index)"
                case .addCard:
                    return "addCard"
                case .linkedCard(let value):
                    return value.cardData.identifier
                }
            }
            
            case skeleton(Int)
            case linkedCard(LinkedCardCellPresenter)
            case addCard(AddCardCellPresenter)
            
            static func == (lhs: SettingsSectionType.CellType.CardsCellType,
                            rhs: SettingsSectionType.CellType.CardsCellType) -> Bool {
                switch (lhs, rhs) {
                case (.skeleton(let left), .skeleton(let right)):
                    return left == right
                case (.linkedCard(let left), .linkedCard(let right)):
                    return left.cardData.identifier == right.cardData.identifier
                case (.addCard, .addCard):
                    return true
                default:
                    return false
                }
            }
        }
        
        enum PlainCellType: String {
            case loginToWebWallet
            case changePassword
            case changePIN
            case rateUs
            case termsOfService
            case privacyPolicy
            case cookiesPolicy
        }
    }
}

extension SettingsSectionType {
    static let `default`: [SettingsSectionType] = [
        .profile,
        .preferences,
        .security,
        .about
    ]
}

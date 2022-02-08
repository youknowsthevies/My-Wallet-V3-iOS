// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public typealias JSONDictionary = [String: Any]

public struct WalletOptions: Decodable {

    /// App update type
    public enum UpdateType: Equatable {

        /// Possible update value representation
        public enum RawValue {
            static let recommended = "recommended"
            static let forced = "forced"
            static let none = "none"
        }

        /// Recommended update with latest version availabled in store associated
        case recommended(latestVersion: AppVersion)

        /// Forced update with latest version availabled in store associated
        case forced(latestVersion: AppVersion)

        /// Update feature deactivated
        case none

        /// Raw value representing the update type
        var rawValue: String {
            switch self {
            case .recommended:
                return RawValue.recommended
            case .forced:
                return RawValue.forced
            case .none:
                return RawValue.none
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case domains
        case ethereum
        case exchangeAddresses
        case hotWalletAddresses
        case ios
        case maintenance
        case mobile
        case mobileInfo
        case xlm
        case xlmExchange
    }

    public struct Domains: Decodable {

        enum CodingKeys: String, CodingKey {
            case stellarHorizon
        }

        enum Keys: String {
            case stellarHorizon
        }

        public let stellarHorizon: String?

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            stellarHorizon = try values.decodeIfPresent(String.self, forKey: .stellarHorizon)
        }
    }

    public struct Mobile: Decodable {

        public let walletRoot: String?

        enum CodingKeys: String, CodingKey {
            case walletRoot
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            walletRoot = try values.decodeIfPresent(String.self, forKey: .walletRoot)
        }
    }

    public struct MobileInfo {
        public let message: String?

        public init?(value: String?) {
            guard let input = value else { return nil }
            message = input
        }
    }

    public struct XLMMetadata: Decodable {
        public let operationFee: Int
        public let sendTimeOutSeconds: Int

        enum CodingKeys: String, CodingKey {
            case operationFee
            case sendTimeOutSeconds
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            operationFee = try values.decode(Int.self, forKey: .operationFee)
            sendTimeOutSeconds = try values.decode(Int.self, forKey: .sendTimeOutSeconds)
        }
    }

    public struct AppUpdateMetadata: Decodable {
        let updateType: UpdateType

        private enum CodingKeys: String, CodingKey {
            case update
        }

        private enum UpdateCodingKeys: String, CodingKey {
            case updateType
            case latestStoreVersion
        }

        public init(from decoder: Decoder) throws {
            guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
                updateType = .none
                return
            }
            guard let updateContainer = try? container.nestedContainer(
                keyedBy: UpdateCodingKeys.self,
                forKey: .update
            ) else {
                updateType = .none
                return
            }

            guard let type = try updateContainer.decodeIfPresent(String.self, forKey: .updateType) else {
                updateType = .none
                return
            }
            guard let version = try updateContainer.decodeIfPresent(String.self, forKey: .latestStoreVersion) else {
                updateType = .none
                return
            }
            guard let latestVersion = AppVersion(string: version) else {
                updateType = .none
                return
            }
            switch type {
            case UpdateType.RawValue.forced:
                updateType = .forced(latestVersion: latestVersion)
            case UpdateType.RawValue.recommended:
                updateType = .recommended(latestVersion: latestVersion)
            default:
                updateType = .none
            }
        }
    }

    // MARK: - Properties

    public let domains: Domains?

    public let downForMaintenance: Bool

    public let hotWalletAddresses: [String: [String: String]]?

    public let mobile: Mobile?

    public let mobileInfo: MobileInfo?

    public let updateType: UpdateType

    public let xlmExchangeAddresses: [String]?

    public let xlmMetadata: XLMMetadata?
}

extension WalletOptions {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        domains = try values.decodeIfPresent(Domains.self, forKey: .domains)
        downForMaintenance = try values.decodeIfPresent(Bool.self, forKey: .maintenance) ?? false
        mobile = try values.decodeIfPresent(Mobile.self, forKey: .mobile)
        xlmMetadata = try values.decodeIfPresent(XLMMetadata.self, forKey: .xlm)
        if let mobileInfoPayload = try values.decodeIfPresent([String: String].self, forKey: .mobileInfo) {
            if let code = Locale.current.languageCode {
                mobileInfo = MobileInfo(value: mobileInfoPayload[code] ?? mobileInfoPayload["en"])
            } else {
                mobileInfo = MobileInfo(value: mobileInfoPayload["en"])
            }
        } else {
            mobileInfo = nil
        }
        if let xlmExchangeAddressContainer = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .xlmExchange) {
            xlmExchangeAddresses = try xlmExchangeAddressContainer.decodeIfPresent([String].self, forKey: .exchangeAddresses)
        } else {
            xlmExchangeAddresses = nil
        }

        if let value = try values.decodeIfPresent(AppUpdateMetadata.self, forKey: .ios) {
            updateType = value.updateType
        } else {
            updateType = .none
        }

        hotWalletAddresses = try values.decodeIfPresent([String: [String: String]].self, forKey: .hotWalletAddresses)
    }
}

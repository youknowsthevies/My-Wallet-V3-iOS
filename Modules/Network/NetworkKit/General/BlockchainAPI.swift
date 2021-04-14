//
//  BlockchainAPI.swift
//  Blockchain
//
//  Created by Maurice A. on 4/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Manages URL endpoints and request payloads for the Blockchain API.
 # Usage
 TBD
 - Author: Maurice Achtenhagen
 - Copyright: Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
 */

@objc
@available(*, deprecated, message: "Don't use this")
public final class BlockchainAPI: NSObject {

    // MARK: - Properties

    /// The instance variable used to access functions of the `API` class.
    @objc public static let shared = BlockchainAPI()

    /**
     Public endpoints used for Blockchain API calls.
     - Important: Do not use `blockchainAPI` and `blockchainWallet` for API calls.
     Instead, retrieve the wallet and API hostname from the main Bundle in the URL
     extension of this class.
     */
    public enum Hosts: String {
        case blockchainAPI = "api.blockchain.info"
        case blockchainDotInfo = "blockchain.info"
        case blockchainDotCom = "blockchain.com"
    }
    
    /// Public hosts used for partner API calls.
    public enum PartnerHosts: String, CaseIterable {
        case bitpay = "bitpay.com"
        case stellarchain = "stellarchain.io"
        case googleAnalytics = "www.google-analytics.com"
        case shapeshift = "shapeshift.io"
        case firebaseAnalytics = "app-measurement.com"
    }

    public struct Parameters {
        /// The API code to be used when making network calls to the Blockchain API
        public static let apiCode = "35e77459-723f-48b0-8c9e-6e9e8f54fbd3"
    }

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        super.init()
    }

    // MARK: - Temporary Objective-C bridging functions

    // TODO: Remove these once migration is complete
    @objc public func blockchainDotInfo() -> String {
        Hosts.blockchainDotInfo.rawValue
    }
    @objc public func blockchainDotCom() -> String {
        Hosts.blockchainDotCom.rawValue
    }
    @objc public func etherExplorer() -> String {
        etherExplorerUrl
    }
    
    // MARK: - Logging
    
    public var swiftyBeaverAppID: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppId)
    }
    
    public var swiftyBeaverAppSecret: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppSecret)
    }
    
    public var swiftyBeaverAppKey: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppKey)
    }

    // MARK: URI
    
    @objc public var webSocketUri: String? {
        InfoDictionaryHelper.value(for: .websocketServerBTC, prefix: "wss://")
    }
    @objc public var ethereumWebSocketUri: String? {
        InfoDictionaryHelper.value(for: .websocketServerETH, prefix: "wss://")
    }
    @objc public var bitcoinCashWebSocketUri: String? {
        InfoDictionaryHelper.value(for: .websocketServerBCH, prefix: "wss://")
    }
    
    // MARK: URL
    
    public var apiHost: String {
        InfoDictionaryHelper.value(for: .apiURL)
    }
    
    public var walletHost: String {
        InfoDictionaryHelper.value(for: .walletServer)
    }
    
    public var everyPayHost: String {
        InfoDictionaryHelper.value(for: .everyPayURL)
    }
    
    public var retailCoreHost: String {
        InfoDictionaryHelper.value(for: .retailCoreURL)
    }
    
    public var explorerHost: String {
        InfoDictionaryHelper.value(for: .explorerServer)
    }
    
    @objc public var apiUrl: String {
        "https://\(apiHost)"
    }
    
    @objc public var walletUrl: String {
        "https://\(walletHost)"
    }
    
    @objc public var explorerUrl: String {
        InfoDictionaryHelper.value(for: .explorerServer, prefix: "https://")
    }
    
    @objc public var retailCoreUrl: String {
        "https://\(retailCoreHost)"
    }
    
    @objc public var retailCoreSocketUrl: String {
        InfoDictionaryHelper.value(for: .retailCoreSocketURL, prefix: "wss://")
    }
    
    @objc public var exchangeURL: String {
        InfoDictionaryHelper.value(for: .exchangeURL, prefix: "https://")
    }
    
    @objc public var walletOptionsUrl: String {
        "\(walletUrl)/Resources/wallet-options.json"
    }
    
    @objc public var bitcoinExplorerUrl: String {
        "\(explorerUrl)/btc"
    }
    
    @objc public var bitcoinCashExplorerUrl: String {
        "\(explorerUrl)/bch"
    }
    
    @objc public var etherExplorerUrl: String {
        "\(explorerUrl)/eth"
    }
    
    public var bitpayUrl: String {
        "https://\(PartnerHosts.bitpay.rawValue)"
    }
    
    public var stellarchainUrl: String {
        "https://\(PartnerHosts.stellarchain.rawValue)"
    }
    
    public var pushNotificationsUrl: String {
        "\(walletUrl)/wallet?method=update-firebase"
    }
    
    public var servicePriceUrl: String {
        "\(apiUrl)/price"
    }
    
    // MARK: - API Endpoints
    
    public var walletSettingsUrl: String {
        "\(walletUrl)/wallet"
    }
    
    public var signedRetailTokenUrl: String {
        "\(walletUrl)/wallet/signed-retail-token"
    }
    
    public var pinStore: String {
        "\(walletUrl)/pin-store"
    }
    
    public var sessionGuid: String {
        "\(walletUrl)/wallet/poll-for-session-guid"
    }
    
    public func wallet(with guid: String) -> String {
        "\(walletUrl)/wallet/\(guid)"
    }
    
    public var walletSession: String {
        "\(walletUrl)/wallet/sessions"
    }
    
    public enum KYC {
        static var countries: String {
            BlockchainAPI.shared.apiUrl + "/kyc/config/countries"
        }
    }
    
    public enum Nabu {
        static var quotes: String {
            BlockchainAPI.shared.retailCoreUrl + "/markets/quotes"
        }
    }

    @objc public var shouldPinCertificate: Bool {
        let value = InfoDictionaryHelper.value(for: .certificatePinning)
        switch value {
        case "1":
            return true
        case "0":
            return false
        default:
            return true
        }
    }
}

private struct InfoDictionaryHelper {
    enum Key: String {
        case apiURL = "API_URL"
        case exchangeURL = "EXCHANGE_URL"
        case explorerServer = "EXPLORER_SERVER"
        case retailCoreSocketURL = "RETAIL_CORE_SOCKET_URL"
        case retailCoreURL = "RETAIL_CORE_URL"
        case walletServer = "WALLET_SERVER"
        case websocketServerBTC = "WEBSOCKET_SERVER"
        case websocketServerBCH = "WEBSOCKET_SERVER_BCH"
        case websocketServerETH = "WEBSOCKET_SERVER_ETH"
        case certificatePinning = "PIN_CERTIFICATE"
        case everyPayURL = "EVERYPAY_API_URL"
        case swiftyBeaverAppId = "SWIFTY_BEAVER_APP_ID"
        case swiftyBeaverAppSecret = "SWIFTY_BEAVER_APP_SECRET"
        case swiftyBeaverAppKey = "SWIFTY_BEAVER_APP_KEY"
    }

    private static let infoDictionary = Bundle(for: BlockchainAPI.self).infoDictionary

    static func value(for key: Key) -> String! {
        infoDictionary?[key.rawValue] as? String
    }

    static func value(for key: Key, prefix: String) -> String! {
        guard let value = value(for: key) else {
            return nil
        }
        return prefix + value
    }
}

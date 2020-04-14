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
final public class BlockchainAPI: NSObject {

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
        case coinify = "app-api.coinify.com"
        case stellarchain = "stellarchain.io"
        case googleAnalytics = "www.google-analytics.com"
        case iSignThis = "coinify-verify.isignthis.com"
        case shapeshift = "shapeshift.io"
        case firebaseAnalytics = "app-measurement.com"
    }

    public struct Parameters {
        /// The API code to be used when making network calls to the Blockchain API
        public static let apiCode = "1770d5d9-bcea-4d28-ad21-6cbd5be018a8"
    }

    // MARK: - Initialization

    //: Prevent outside objects from creating their own instances of this class.
    private override init() {
        super.init()
    }

    // MARK: - Temporary Objective-C bridging functions

    // TODO: Remove these once migration is complete
    @objc public func blockchainDotInfo() -> String {
        return Hosts.blockchainDotInfo.rawValue
    }
    @objc public func blockchainDotCom() -> String {
        return Hosts.blockchainDotCom.rawValue
    }
    @objc public func etherExplorer() -> String {
        return etherExplorerUrl
    }

    // MARK: URI
    
    @objc public var webSocketUri: String? {
        return InfoDictionaryHelper.value(for: .websocketServerBTC, prefix: "wss://")
    }
    @objc public var ethereumWebSocketUri: String? {
        return InfoDictionaryHelper.value(for: .websocketServerETH, prefix: "wss://")
    }
    @objc public var bitcoinCashWebSocketUri: String? {
        return InfoDictionaryHelper.value(for: .websocketServerBCH, prefix: "wss://")
    }
    
    // MARK: URL
    
    public var apiHost: String {
        return InfoDictionaryHelper.value(for: .apiURL)
    }
    
    public var walletHost: String {
        return InfoDictionaryHelper.value(for: .walletServer)
    }
    
    public var retailCoreHost: String {
        return InfoDictionaryHelper.value(for: .retailCoreURL)
    }
    
    @objc public var apiUrl: String {
        return "https://\(apiHost)"
    }
    
    @objc public var walletUrl: String {
        return "https://\(walletHost)"
    }
    
    @objc public var explorerUrl: String {
        return InfoDictionaryHelper.value(for: .explorerServer, prefix: "https://")
    }
    
    @objc public var retailCoreUrl: String {
        return "https://\(retailCoreHost)"
    }
    
    @objc public var retailCoreSocketUrl: String {
        return InfoDictionaryHelper.value(for: .retailCoreSocketURL, prefix: "wss://")
    }
    
    @objc public var exchangeURL: String {
        return InfoDictionaryHelper.value(for: .exchangeURL, prefix: "https://")
    }
    
    @objc public var walletOptionsUrl: String {
        return "\(walletUrl)/Resources/wallet-options.json"
    }
    
    @objc public var buyWebViewUrl: String? {
        return InfoDictionaryHelper.value(for: .buyWebviewURL, prefix: "https://")
    }
    
    @objc public var bitcoinExplorerUrl: String {
        return "\(explorerUrl)/btc"
    }
    
    @objc public var bitcoinCashExplorerUrl: String {
        return "\(explorerUrl)/bch"
    }
    
    @objc public var etherExplorerUrl: String {
        return "\(explorerUrl)/eth"
    }
    
    public var bitpayUrl: String {
        return "https://\(PartnerHosts.bitpay.rawValue)"
    }
    
    public var coinifyEndpoint: String {
        return InfoDictionaryHelper.value(for: .coinifyURL, prefix: "https://")
    }
    
    public var stellarchainUrl: String {
        return "https://\(PartnerHosts.stellarchain.rawValue)"
    }
    
    public var pushNotificationsUrl: String {
        return "\(walletUrl)/wallet?method=update-firebase"
    }
    
    public var servicePriceUrl: String {
        return "\(apiUrl)/price"
    }
    
    // MARK: - API Endpoints
    
    public var walletSettingsUrl: String {
        return "\(walletUrl)/wallet"
    }
    
    public var signedRetailTokenUrl: String {
        return "\(walletUrl)/wallet/signed-retail-token"
    }
    
    public var pinStore: String {
        return "\(walletUrl)/pin-store"
    }
    
    public var sessionGuid: String {
        return "\(walletUrl)/wallet/poll-for-session-guid"
    }
    
    public func wallet(with guid: String) -> String {
        return "\(walletUrl)/wallet/\(guid)"
    }
    
    public var walletSession: String {
        return "\(walletUrl)/wallet/sessions"
    }
    
    public enum KYC {
        static var countries: String {
            return BlockchainAPI.shared.apiUrl + "/kyc/config/countries"
        }
    }
    
    public enum Nabu {
        static var quotes: String {
            return BlockchainAPI.shared.retailCoreUrl + "/markets/quotes"
        }
    }
}

fileprivate struct InfoDictionaryHelper {
    enum Key: String {
        case apiURL = "API_URL"
        case buyWebviewURL = "BUY_WEBVIEW_URL"
        case coinifyURL = "COINIFY_URL"
        case exchangeURL = "EXCHANGE_URL"
        case explorerServer = "EXPLORER_SERVER"
        case retailCoreSocketURL = "RETAIL_CORE_SOCKET_URL"
        case retailCoreURL = "RETAIL_CORE_URL"
        case walletServer = "WALLET_SERVER"
        case websocketServerBTC = "WEBSOCKET_SERVER"
        case websocketServerBCH = "WEBSOCKET_SERVER_BCH"
        case websocketServerETH = "WEBSOCKET_SERVER_ETH"
    }

    private static let infoDictionary = Bundle(for: BlockchainAPI.self).infoDictionary

    static func value(for key: Key) -> String! {
        return infoDictionary?[key.rawValue] as? String
    }

    static func value(for key: Key, prefix: String) -> String! {
        guard let value = value(for: key) else {
            return nil
        }
        return prefix + value
    }
}

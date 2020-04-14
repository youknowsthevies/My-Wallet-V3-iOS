//
//  ConfigTests.swift
//  NetworkKitTests
//
//  Created by Paulo on 14/04/2020.
//

import XCTest
import NetworkKit

class ConfigTests: XCTestCase {

    private var configInfoDictionary: [String : Any]?

    override func setUp() {
        super.setUp()
        configInfoDictionary = Bundle(for: BlockchainAPI.self).infoDictionary
    }

    func testAllKeysPresentAndNotEmpty() {
        let keys: [String] = [
            "API_URL",
            "BUY_WEBVIEW_URL",
            "COINIFY_URL",
            "EXCHANGE_URL",
            "EXPLORER_SERVER",
            "RETAIL_CORE_SOCKET_URL",
            "RETAIL_CORE_URL",
            "WALLET_SERVER",
            "WEBSOCKET_SERVER",
            "WEBSOCKET_SERVER_BCH",
            "WEBSOCKET_SERVER_ETH"
        ]
        for key in keys {
            let value = getValue(for: key)
            XCTAssertNotNil(value)
            XCTAssertEqual(value!.isEmpty, false)
        }
    }

    func testBlockchainAPIBundleIsCorrect() {
        let value = BlockchainAPI.shared.apiHost
        XCTAssertFalse(value.isEmpty)
    }

    private func getValue(for key: String) -> String? {
        return configInfoDictionary?["RETAIL_CORE_URL"] as? String
    }
}

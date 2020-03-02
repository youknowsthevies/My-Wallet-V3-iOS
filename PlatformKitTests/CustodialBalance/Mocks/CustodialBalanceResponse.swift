//
//  CustodialBalanceResponse.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformKit

extension CustodialBalanceResponse {

    static let mockJson = """
    {
      "BTC": {
        "available": "0",
        "pending": "0"
      },
      "ETH": {
        "available": "100",
        "pending": "100"
      }
    }
    """

    static func mock(json: String) -> CustodialBalanceResponse! {
        do {
            return try JSONDecoder().decode(CustodialBalanceResponse.self, from: Data(json.utf8))
        } catch {
            return nil
        }
    }
}

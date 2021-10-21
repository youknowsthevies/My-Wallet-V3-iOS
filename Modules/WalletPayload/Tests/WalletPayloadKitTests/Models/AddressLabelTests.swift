// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import TestKit
@testable import WalletPayloadKit
import XCTest

class AddressLabelTests: XCTestCase {

    let json = Fixtures.loadJSONData(filename: "address-label", in: .module)!

    func test_it_should_be_able_to_be_decoded_from_json() throws {
        let addressLabel = try JSONDecoder().decode(AddressLabel.self, from: json)

        XCTAssertEqual(addressLabel.index, 25)
        XCTAssertEqual(addressLabel.label, "My Beer Address")
    }

    func test_it_can_be_encoded_to_json() throws {
        let addressLabel = AddressLabel(index: 1, label: "My Rum Address")

        let encoded = try JSONEncoder().encode(addressLabel)
        let decoded = try JSONDecoder().decode(AddressLabel.self, from: encoded)

        XCTAssertEqual(decoded, addressLabel)
    }
}

//
//  AddressPreseterTests.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import PlatformKit
import PlatformUIKit
import RxSwift
import XCTest

class AddressPresenterTests: XCTestCase {
    
    func testAddressPresenterStatus() {
        let asset = CryptoCurrency.ethereum
        let addressString = "eth-address"
        let address = WalletAddressContent(string: addressString, qrCode: QRCode(string: "")!)
        let payment = ReceivedPaymentDetails(amount: "1 ETH", asset: asset, address: addressString)
        let interactor = AddressInteractorMock(asset: asset,
                                               address: address,
                                               receivedPayment: payment)
        let pasteboard = MockPasteboard()
        let presenter = AddressPresenter(interactor: interactor,
                                         pasteboard: pasteboard)
        
        let statusBlocking = presenter.status.toBlocking()
        
        XCTAssertEqual(try statusBlocking.first(), .awaitingFetch)
        
        presenter.fetchAddress()
        XCTAssertEqual(try statusBlocking.first(), .readyForDisplay(content: address))        
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift
import XCTest

@testable import Blockchain

class AddressInteractorTests: XCTestCase {
    
    func testBitcoinAddressSuccessfulPaymentInteraction() {
        let addresses = ["bitcoin1", "bitcoin2"]
        let receivingAddress = addresses[0]
        let paymentDetails = ReceivedPaymentDetails(amount: "0.35 BTC",
                                                    asset: .bitcoin,
                                                    address: receivingAddress)
        let transactionObserver = TransactionObserverMock(paymentDetails: paymentDetails)
        let addressFetcher = AssetAddressRepositoryMock(isReusable: false,
                                                        addresses: addresses)
        let interactor = AddressInteractor(asset: .bitcoin,
                                           addressType: .swipeToReceive,
                                           addressFetcherProvider: { addressFetcher },
                                           transactionObserver: transactionObserver,
                                           addressSubscriber: AddressSubscriberMock())
        do {
            // Fetch the next address
            _ = try interactor.address.toBlocking().first()
            
            // The address must not be there
            XCTAssert(!addressFetcher.addresses.contains(receivingAddress))
        } catch {
            XCTFail("expected success. got \(error.localizedDescription) instead")
        }
    }
    
    func testBitcoinCashPaymentToAnotherAddressInteraction() {
        let addresses = ["bitcoin-cash-1", "bitcoin-cash-2"]
        let receivingAddress = "another-address"
        let paymentDetails = ReceivedPaymentDetails(amount: "0.35 BHC",
                                                    asset: .bitcoinCash,
                                                    address: receivingAddress)
        let transactionObserver = TransactionObserverMock(paymentDetails: paymentDetails)
        let addressFetcher = AssetAddressRepositoryMock(isReusable: false,
                                                        addresses: addresses)
        let interactor = AddressInteractor(asset: .bitcoinCash,
                                           addressType: .swipeToReceive,
                                           addressFetcherProvider: { addressFetcher },
                                           transactionObserver: transactionObserver,
                                           addressSubscriber: AddressSubscriberMock())
        do {
            // Fetch the next address
            _ = try interactor.address.toBlocking().first()
            XCTAssertEqual(addressFetcher.addresses.count, 2)
        } catch {
            XCTFail("expected success. got \(error) instead")
        }
    }
    
    func testReusableAddress() {
        let addresses = ["stellar-address"]
        let receivingAddress = addresses[0]
        let paymentDetails = ReceivedPaymentDetails(amount: "1 XLM",
                                                    asset: .stellar,
                                                    address: receivingAddress)
        let transactionObserver = TransactionObserverMock(paymentDetails: paymentDetails)
        let addressFetcher = AssetAddressRepositoryMock(isReusable: true,
                                                        addresses: addresses)
        let interactor = AddressInteractor(asset: .stellar,
                                           addressType: .swipeToReceive,
                                           addressFetcherProvider: { addressFetcher },
                                           transactionObserver: transactionObserver,
                                           addressSubscriber: AddressSubscriberMock())
        do {
            // Fetch the next address
            _ = try interactor.address.toBlocking().first()
            XCTAssert(!addressFetcher.addresses.isEmpty)
        } catch {
            XCTFail("expected success. got \(error) instead")
        }
    }
}

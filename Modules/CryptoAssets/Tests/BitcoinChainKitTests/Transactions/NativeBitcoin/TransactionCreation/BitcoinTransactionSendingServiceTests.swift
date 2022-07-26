// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import Combine
import NetworkKit
import XCTest

class BitcoinTransactionSendingServiceTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = []

        try super.tearDownWithError()
    }

    func test_send_btc_success() throws {
        XCTSkip()

        // TODO: Coming in subsequent PR

//        var (client, _) = APIClient.test()
//
//        let btcTransactionSentSuccessfullyExpectation = self.expectation(
//            description: "btcTransactionSentSuccessfullyExpectation"
//        )
//
//        let subject = BitcoinTransactionSendingService(
//            client: client
//        )
//
//        let signedTransaction = SignedBitcoinChainTransaction(
//            msgSize: 1,
//            txHash: "txHash",
//            encodedMsg: "encodedMsg"
//        )
//
//        subject.send(signedTransaction: signedTransaction)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                    case .finished:
//                        break
//                    case .failure(let error):
//                        XCTFail("Failed with error: \(error.localizedDescription)")
//                        break
//                    }
//                },
//                receiveValue: { output in
//                    print(output)
//                    btcTransactionSentSuccessfullyExpectation.fulfill()
//                }
//            )
//            .store(in: &cancellables)
//
//        wait(
//            for: [
//                btcTransactionSentSuccessfullyExpectation
//            ],
//            timeout: 10.0
//        )
    }
}

#if DEBUG
import Foundation
import NetworkKit

extension APIClient {

    public static func test(
        _ requests: [URLRequest: Data] = [:]
    ) -> (
        client: APIClient,
        communicator: ReplayNetworkCommunicator
    ) {
        let communicator = ReplayNetworkCommunicator(
            requests,
            in: Bundle.module
        )
        return (
            APIClient(
                coin: .bitcoin,
                requestBuilder: RequestBuilder(
                    config: Network.Config(
                        scheme: "https",
                        host: "api.blockchain.info"
                    )
                ),
                networkAdapter: NetworkAdapter(
                    communicator: communicator
                )
            ),
            communicator
        )
//        fatalError("Not implemented")
    }
}
#endif

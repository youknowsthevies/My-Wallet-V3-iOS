// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class Version4WorkflowTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_upgrade_from_version_3_to_4_works_correctly() throws {
        // dummy decoded object on our end for a v3 wallet
        let hdWalletV3 = HDWallet(
            seedHex: "",
            passphrase: "",
            mnemonicVerified: false,
            defaultAccountIndex: 0,
            accounts: [
                .init(
                    index: 0,
                    label: "",
                    archived: false,
                    defaultDerivation: .legacy,
                    derivations: [
                        .init(
                            type: .legacy,
                            purpose: 44,
                            xpriv: "",
                            xpub: "",
                            addressLabels: [],
                            cache: .init(receiveAccount: "", changeAccount: "")
                        )
                    ]
                )
            ]
        )
        let version3Wrapper = Wrapper(
            pbkdf2Iterations: 5000,
            version: 3,
            payloadChecksum: "",
            language: "",
            syncPubKeys: false,
            wallet: NativeWallet(
                guid: "guid",
                sharedKey: "sharedKey",
                doubleEncrypted: false,
                doublePasswordHash: nil,
                metadataHDNode: nil,
                options: .default,
                hdWallets: [hdWalletV3],
                addresses: []
            )
        )

        let expectation = expectation(description: "should perform workflows")

        let workflow = Version4Workflow()

        workflow.upgrade(wrapper: version3Wrapper)
            .sink(receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide correct value")
            }, receiveValue: { wrapper in
                XCTAssertFalse(wrapper.wallet.hdWallets.isEmpty)
                XCTAssertNotNil(wrapper.wallet.defaultHDWallet)
                XCTAssertNotNil(wrapper.wallet.defaultHDWallet!.accounts.first)
                let account = wrapper.wallet.defaultHDWallet!.accounts.first
                let derivations = account!.derivations
                XCTAssertEqual(derivations.count, 2)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}

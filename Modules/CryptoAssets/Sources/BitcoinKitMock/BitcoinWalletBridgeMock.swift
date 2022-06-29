// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinKit
import Combine
import Foundation
import RxSwift

class BitcoinWalletBridgeMock: BitcoinWalletBridgeAPI {

    enum MockError: Error {
        case error
    }

    func update(accountIndex: Int, label: String) -> Completable {
        .empty()
    }

    func walletIndex(for receiveAddress: String) -> Single<Int32> {
        .never()
    }

    var receiveAddressValue: Single<String> = .error(MockError.error)

    func receiveAddress(forXPub xpub: String) -> Single<String> {
        receiveAddressValue
    }

    func firstReceiveAddress(forXPub xpub: String) -> Single<String> {
        receiveAddressValue
    }

    var noteValue: Single<String?> = .just(nil)

    func note(for transactionHash: String) -> Single<String?> {
        noteValue
    }

    func updateNote(for transactionHash: String, note: String?) -> Completable {
        .empty()
    }

    var defaultWalletValue: Single<BitcoinWalletAccount> = Single.error(MockError.error)
    var defaultWallet: Single<BitcoinWalletAccount> {
        defaultWalletValue
    }

    var walletsValue: Single<[BitcoinWalletAccount]> = Single.just([])
    var wallets: Single<[BitcoinWalletAccount]> {
        walletsValue
    }
}

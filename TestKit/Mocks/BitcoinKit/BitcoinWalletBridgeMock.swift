//
//  BitcoinWalletBridgeMock.swift
//  BitcoinKitTests
//
//  Created by Jack on 22/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import BitcoinKit
import Foundation
import RxSwift

class BitcoinWalletBridgeMock: BitcoinWalletBridgeAPI {
    
    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        .empty()
    }

    enum MockError: Error {
        case error
    }

    var memoValue: Single<String?> = .just(nil)
    func memo(for transactionHash: String) -> Single<String?> {
        memoValue
    }

    var hdWalletValue: Single<PayloadBitcoinHDWallet> = Single.error(MockError.error)
    var hdWallet: Single<PayloadBitcoinHDWallet> {
        hdWalletValue
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

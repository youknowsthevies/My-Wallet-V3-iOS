// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit
import WalletCore

public struct Wrapper: Equatable {
    public let pbkdf2Iterations: UInt32
    public let version: Int
    public let payloadChecksum: String
    public let language: String
    public let syncPubKeys: Bool
    public let warChecksum: String
    public let wallet: NativeWallet

    public init(
        pbkdf2Iterations: Int,
        version: Int,
        payloadChecksum: String,
        language: String,
        syncPubKeys: Bool,
        warChecksum: String,
        wallet: NativeWallet
    ) {
        self.pbkdf2Iterations = UInt32(pbkdf2Iterations)
        self.version = version
        self.payloadChecksum = payloadChecksum
        self.language = language
        self.syncPubKeys = syncPubKeys
        self.warChecksum = warChecksum
        self.wallet = wallet
    }
}

// MARK: - Creation Methods

func generateWrapper(
    wallet: NativeWallet,
    language: String = "en",
    version: WalletVersion = WalletVersion.supportedVersion
) -> Wrapper {
    Wrapper(
        pbkdf2Iterations: wallet.options.pbkdf2Iterations,
        version: version.rawValue,
        payloadChecksum: "",
        language: language,
        syncPubKeys: false,
        warChecksum: "",
        wallet: wallet
    )
}

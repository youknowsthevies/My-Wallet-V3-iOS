// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit
import WalletCore

public final class Wrapper: Equatable {
    public internal(set) var pbkdf2Iterations: UInt32
    public internal(set) var version: Int
    public internal(set) var payloadChecksum: String
    public internal(set) var language: String
    public internal(set) var syncPubKeys: Bool
    public internal(set) var warChecksum: String
    public internal(set) var wallet: NativeWallet

    init(
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

extension Wrapper {
    public static func == (lhs: Wrapper, rhs: Wrapper) -> Bool {
        lhs.pbkdf2Iterations == rhs.pbkdf2Iterations
            && lhs.version == rhs.version
            && lhs.payloadChecksum == rhs.payloadChecksum
            && lhs.language == rhs.language
            && lhs.syncPubKeys == rhs.syncPubKeys
            && lhs.warChecksum == rhs.warChecksum
            && lhs.wallet == rhs.wallet
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

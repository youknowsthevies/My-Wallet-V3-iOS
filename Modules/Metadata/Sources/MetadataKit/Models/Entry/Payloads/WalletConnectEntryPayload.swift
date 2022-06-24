// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WalletConnectEntryPayload: MetadataNodeEntry, Hashable {

    public enum CodingKeys: String, CodingKey {
        case sessions
    }

    public static let type: EntryType = .walletConnect

    /// Contains the raw json for wallet connect data
    public let sessions: String?

    public init(
        sessions: String
    ) {
        self.sessions = sessions
    }
}

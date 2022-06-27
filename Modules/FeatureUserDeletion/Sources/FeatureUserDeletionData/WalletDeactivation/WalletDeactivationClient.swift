import Combine
import NetworkKit

/// https://www.notion.so/blockchaincom/Deactivate-User-Wallet-BE-b58b66e89e39404eb370f4e04c2009f7

public protocol WalletDeactivationClientAPI: AnyObject {
    func deactivateWallet(
        guid: String,
        sharedKey: String,
        email: String,
        sessionToken: String
    ) -> AnyPublisher<Void, NetworkError>
}

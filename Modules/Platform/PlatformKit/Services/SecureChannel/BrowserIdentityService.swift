// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import WalletPayloadKit

final class BrowserIdentityService {

    // MARK: Types

    enum IdentityError: LocalizedError {
        case identitySaveFailed
        case unknownPubKeyHash(String)

        var errorDescription: String? {
            switch self {
            case .identitySaveFailed:
                return "BrowserIdentityService: Unable to save browser identity."
            case .unknownPubKeyHash:
                return "BrowserIdentityService: Browser not recognized."
            }
        }
    }

    // MARK: Private Properties

    private let appSettingsSecureChannel: AppSettingsSecureChannel
    private let cryptoService: WalletCryptoServiceAPI

    // MARK: Init

    init(
        appSettingsSecureChannel: AppSettingsSecureChannel = resolve(),
        cryptoService: WalletCryptoServiceAPI = resolve()
    ) {
        self.appSettingsSecureChannel = appSettingsSecureChannel
        self.cryptoService = cryptoService
    }

    func getIdentities() -> Result<[String: BrowserIdentity], Error> {
        guard let string = appSettingsSecureChannel.browserIdentities else {
            return .success([:])
        }
        guard let data = string.data(using: .utf8) else {
            return .success([:])
        }
        guard let decoded = try? JSONDecoder().decode([String: BrowserIdentity].self, from: data) else {
            return .success([:])
        }
        return .success(decoded)
    }

    func saveIdentities(identities: [String: BrowserIdentity]) -> Result<Void, Error> {
        Result {
            let data = try JSONEncoder().encode(identities)
            guard let string = String(data: data, encoding: .utf8) else {
                throw IdentityError.identitySaveFailed
            }
            appSettingsSecureChannel.browserIdentities = string
        }
    }

    func addBrowserIdentity(identity: BrowserIdentity) -> Result<Void, Error> {
        getIdentities()
            .flatMap { list in
                var newList = list
                newList[identity.pubKeyHash] = identity
                return saveIdentities(identities: newList)
            }
    }

    func getBrowserIdentity(pubKeyHash: String) -> Result<BrowserIdentity, Error> {
        getIdentities()
            .flatMap { identities in
                Result {
                    guard let browserIdentity = identities[pubKeyHash] else {
                        throw IdentityError.unknownPubKeyHash(pubKeyHash)
                    }
                    return browserIdentity
                }
            }
    }

    func deleteBrowserIdentity(pubKeyHash: String) -> Result<Void, Error> {
        getIdentities()
            .flatMap { list in
                var list = list
                list[pubKeyHash] = nil
                return saveIdentities(identities: list)
            }
    }

    func updateBrowserIdentityUsedTimestamp(pubKeyHash: String) -> Result<Void, Error> {
        getIdentities()
            .flatMap { list in
                var list = list
                var identity = list[pubKeyHash]
                identity?.lastUsed = UInt64(Date().timeIntervalSince1970 * 1000)
                list[pubKeyHash] = identity
                return saveIdentities(identities: list)
            }
    }

    /// Finds the `BrowserIdentity` with the given `pubKeyHash`and sets its `authorized`
    func addBrowserIdentityAuthorization(pubKeyHash: String, authorized: Bool) -> Result<Void, Error> {
        getIdentities()
            .flatMap { list in
                var list = list
                var identity = list[pubKeyHash]
                identity?.authorized = authorized
                list[pubKeyHash] = identity
                return saveIdentities(identities: list)
            }
    }

    /// Prunes entries that were never used and were create more than a cutoff date.
    func pruneBrowserIdentities() -> Result<Void, Error> {
        let cutOffMinutes: Int = 5
        let cutOffDate = Date().addingTimeInterval(-TimeInterval(cutOffMinutes * 60))
        let cutOffPoint = UInt64(cutOffDate.timeIntervalSince1970 * 1000)
        return getIdentities()
            .flatMap { list in
                let newList = list.filter { item in
                    item.value.lastUsed != 0 || item.value.creation > cutOffPoint
                }
                guard newList.count != list.count else {
                    return .success(())
                }
                return saveIdentities(identities: newList)
            }
    }

    func getDeviceKey() -> Data {
        var deviceKey = appSettingsSecureChannel.deviceKey
        if deviceKey == nil {
            deviceKey = Data.randomData(count: 32)?.hexValue
            appSettingsSecureChannel.deviceKey = deviceKey
        }
        return Data(hex: deviceKey!)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import BitcoinKit
import DIKit
import ERC20Kit
import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift
import SettingsKit
import StellarKit
import ToolKit

enum AssetAddressRepositoryError: Error {
    case jsonParsingError
}

/// Address usage status
enum AddressUsageStatus {
    
    /// Used address - indicates the address had been used by another transaction
    case used(address: String)
    
    /// Unused address - indicates the address has not been used yet
    case unused(address: String)
    
    /// Unknown usage status - indicates the address usage couldn't be deducted
    case unknown(address: String)
    
    /// Returns `true` if the status is `unused`
    var isUnused: Bool {
        switch self {
        case .unused:
            return true
        case .used, .unknown:
            return false
        }
    }
    
    /// Returns the address associated with the usage status
    var address: String {
        switch self {
        case .unknown(address: let address):
            return address
        case .unused(address: let address):
            return address
        case .used(address: let address):
            return address
        }
    }
}

enum AssetAddressType {
    case swipeToReceive
    case standard
}

/// Repository for asset addresses
@objc class AssetAddressRepository: NSObject, AssetAddressFetching {

    static let shared = AssetAddressRepository()

    /// Accessor for obj-c compatibility
    @objc class func sharedInstance() -> AssetAddressRepository { shared }

    private let walletManager: WalletManager
    private let stellarWalletAccountRepository: StellarWalletAccountRepository
    private let paxAssetAccountRepository: ERC20AssetAccountRepository<PaxToken>
    private let tetherAssetAccountRepository: ERC20AssetAccountRepository<TetherToken>
    private let urlSession: URLSession
    
    private let disposeBag = DisposeBag()
    
    init(walletManager: WalletManager = WalletManager.shared,
         stellarWalletRepository: StellarWalletAccountRepository = resolve(),
         paxAssetAccountRepository: ERC20AssetAccountRepository<PaxToken> = resolve(),
         tetherAssetAccountRepository: ERC20AssetAccountRepository<TetherToken> = resolve(),
         urlSession: URLSession = resolve()) {
        self.walletManager = walletManager
        self.stellarWalletAccountRepository = stellarWalletRepository
        self.paxAssetAccountRepository = paxAssetAccountRepository
        self.tetherAssetAccountRepository = tetherAssetAccountRepository
        self.urlSession = urlSession
        super.init()
        self.walletManager.swipeAddressDelegate = self
    }

    // TODO: move latest multiaddress response here

    /// Fetches the swipe to receive addresses for all assets if possible
    func fetchSwipeToReceiveAddressesIfNeeded() {

        // Perform guard checks
        let appSettings = BlockchainSettings.App.shared
        guard appSettings.swipeToReceiveEnabled else {
            Logger.shared.info("Swipe to receive is disabled.")
            return
        }

        let wallet = walletManager.wallet

        guard wallet.isInitialized() else {
            Logger.shared.warning("Wallet is not yet initialized.")
            return
        }

        guard wallet.didUpgradeToHd() else {
            fatalError("Wallet upgrade is not optional.")
        }

        // Only one address for Ethereum and all other ERC20 coins.
        let etherAddress = wallet.getEtherAddress()
        appSettings.swipeAddressForEther = etherAddress
        appSettings.swipeAddressForPax = etherAddress
        appSettings.swipeAddressForAave = etherAddress
        appSettings.swipeAddressForWDGLD = etherAddress
        appSettings.swipeAddressForYearnFinance = etherAddress
        appSettings.swipeAddressForTether = etherAddress

        // Only one address for Stellar.
        appSettings.swipeAddressForStellar = self.stellarWalletAccountRepository.defaultAccount?.publicKey
        
        // Retrieve swipe addresses for bitcoin and bitcoin cash
        [CryptoCurrency.bitcoin, CryptoCurrency.bitcoinCash].forEach {
            let swipeAddresses = self.swipeAddresses(for: $0)
            let numberOfAddressesToDerive: Int = Constants.Wallet.swipeToReceiveAddressCount - swipeAddresses.count
            if numberOfAddressesToDerive > 0 {
                wallet.getSwipeAddresses(numberOfAddressesToDerive, assetType: $0.legacy)
            }
        }
    }

    /// Gets address for the provided asset type
    /// - Parameter type: the type of the address
    /// - Parameter asset: the asset type
    /// - Returns: a candidate asset addresses
    func addresses(by type: AssetAddressType, asset: CryptoCurrency) -> [AssetAddress] {
        switch type {
        case .swipeToReceive:
            return swipeAddresses(for: asset)
        case .standard:
            fatalError("TODO")
        }
    }
    
    /// Gets the swipe addresses for the provided asset type
    /// - Parameter asset: the asset type
    /// - Returns: the asset address
    func swipeAddresses(for asset: CryptoCurrency) -> [AssetAddress] {
        let appSettings = BlockchainSettings.App.shared

        // TODO: In `BlockchainSettings.App`, create a method that receives an enum and returns a swipe address
        switch asset {
        case .aave:
            guard let address = appSettings.swipeAddressForAave else {
                return []
            }
            return [AnyERC20AssetAddress<AaveToken>(publicKey: address)]
        case .algorand:
            return []
        case .ethereum:
            guard let address = appSettings.swipeAddressForEther else {
                return []
            }
            return [EthereumAddress(stringLiteral: address)]
        case .stellar:
            guard let address = appSettings.swipeAddressForStellar else {
                return []
            }
            return [StellarAssetAddress(publicKey: address)]
        case .pax:
            guard let address = appSettings.swipeAddressForPax else {
                return []
            }
            return [AnyERC20AssetAddress<PaxToken>(publicKey: address)]
        case .polkadot:
            return []
        case .tether:
            guard let address = appSettings.swipeAddressForTether else {
                return []
            }
            return [AnyERC20AssetAddress<TetherToken>(publicKey: address)]
        case .wDGLD:
            guard let address = appSettings.swipeAddressForWDGLD else {
                return []
            }
            return [AnyERC20AssetAddress<WDGLDToken>(publicKey: address)]
        case .yearnFinance:
            guard let address = appSettings.swipeAddressForYearnFinance else {
                return []
            }
            return [AnyERC20AssetAddress<YearnFinanceToken>(publicKey: address)]
        case .bitcoinCash, .bitcoin:
            let swipeAddresses = KeychainItemWrapper.getSwipeAddresses(for: asset.legacy) as? [String] ?? []
            return AssetAddressFactory.create(fromAddressStringArray: swipeAddresses, assetType: asset)
        }
    }

    /// Removes the first swipe address for assetType.
    ///
    /// - Parameter assetType: the CryptoCurrency
    func removeFirstSwipeAddress(for assetType: CryptoCurrency) {
        KeychainItemWrapper.removeFirstSwipeAddress(for: assetType.legacy)
    }
    
    /// Removes a specific address for assetType.
    ///
    /// - Parameter address: the address
    /// - Parameter assetType: the CryptoCurrency
    /// - Parameter addressType: the type of the address
    func remove(address: String, for assetType: CryptoCurrency, addressType: AssetAddressType) {
        switch addressType {
        case .swipeToReceive:
            KeychainItemWrapper.removeSwipeAddress(address, assetType: assetType.legacy)
        case .standard:
            fatalError("\(#function) has not been implemented to support \(addressType)")
        }
    }

    /// Removes all swipe addresses for all assets
    @objc func removeAllSwipeAddresses() {
        KeychainItemWrapper.removeAllSwipeAddresses()
    }

    /// Removes all swipe addresses for the provided CryptoCurrency
    ///
    /// - Parameter assetType: the CryptoCurrency
    func removeAllSwipeAddresses(for cryptoCurrency: CryptoCurrency) {
        removeAllSwipeAddresses(forAsset: cryptoCurrency.legacy)
    }
    
    /// removes all swipe addresses for the provided LegacyAssetType
    ///
    /// - Parameter type: the LegacyAssetType
    @objc func removeAllSwipeAddresses(forAsset type: LegacyAssetType) {
        KeychainItemWrapper.removeAllSwipeAddresses(for: type)
    }
}

extension AssetAddressRepository: WalletSwipeAddressDelegate {
    func onRetrievedSwipeToReceive(addresses: [String], assetType: CryptoCurrency) {
        addresses.forEach {
            KeychainItemWrapper.addSwipeAddress($0, assetType: assetType.legacy)
        }
    }
}

extension AssetAddressRepository {
    
    /// Checks whether an address has been used (has ever had a transaction)
    ///
    /// - Parameters:
    ///   - address: address to be checked with network request
    /// (usually the same as address unless checking for corresponding BTC address for BCH
    ///   - asset: asset type for the address. Currently only supports BTC and BCH.
    /// - Returns: A single with the address usage status
    func checkUsability(of address: String, asset: CryptoCurrency) -> Single<AddressUsageStatus> {
        Single.just(())
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, _) -> Single<AddressUsageStatus> in
                // Continue only if address reusability is not supported for the given asset type
                guard !asset.shouldAddressesBeReused else {
                    Logger.shared.info("\(asset.name) addresses not supported for checking if it is unused.")
                    return .just(.unused(address: address))
                }
                return self.fetchAddressUsage(of: address, asset: asset)
            }
    }
    
    private func fetchAddressUsage(of address: String, asset: CryptoCurrency) -> Single<AddressUsageStatus> {
        let assetAddress: AssetAddress = AssetAddressFactory.create(fromAddressString: address, assetType: asset)

        guard let urlString = BlockchainAPI.shared.assetInfoURL(for: assetAddress) else {
            Logger.shared.warning("Cannot construct URL to check if the address '\(address)' is unused.")
            return .just(.unknown(address: address))
        }
        guard let url = URL(string: urlString) else {
            Logger.shared.warning("Cannot construct URL to check if the address '\(address)' is unused.")
            return .just(.unknown(address: address))
        }

        return isAddressUnused(address: address, url: url)
            .map { unused -> AddressUsageStatus in
                unused ? .unused(address: address) : .used(address: address)
            }
    }

    private func isAddressUnused(address: String, url: URL) -> Single<Bool> {
        struct Response: Decodable {
            let n_tx: Int
        }
        return Single<Bool>
            .create(weak: self) { (self, observer) -> Disposable in
                let task = self.urlSession.dataTask(with: url, completionHandler: { data, _, error in
                    guard error == nil else {
                        observer(.error(error!))
                        return
                    }
                    guard let data = data else {
                        observer(.error(AssetAddressRepositoryError.jsonParsingError))
                        return
                    }
                    guard let response = try? JSONDecoder().decode([String: Response].self, from: data) else {
                        observer(.error(AssetAddressRepositoryError.jsonParsingError))
                        return
                    }
                    if let result = response[address] {
                        observer(.success(result.n_tx == 0))
                        return
                    } else if address.hasPrefix("bitcoincash"), response.count == 1, let result = response.first {
                        observer(.success(result.value.n_tx == 0))
                        return
                    } else {
                        observer(.error(AssetAddressRepositoryError.jsonParsingError))
                        return
                    }
                })
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            }
    }
}

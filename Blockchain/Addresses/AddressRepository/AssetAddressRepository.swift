//
//  AssetAddressRepository.swift
//  Blockchain
//
//  Created by Chris Arriola on 5/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import DIKit
import ERC20Kit
import EthereumKit
import NetworkKit
import RxSwift
import PlatformKit
import StellarKit
import ToolKit

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
         paxAssetAccountRepository: ERC20AssetAccountRepository<PaxToken> = PAXServiceProvider.shared.services.assetAccountRepository,
         tetherAssetAccountRepository: ERC20AssetAccountRepository<TetherToken> = TetherServiceProvider.shared.services.assetAccountRepository,
         urlSession: URLSession = resolve()
        ) {
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
            Logger.shared.warning("Wallet has not yet been upgraded to HD.")
            return
        }

        // Only one address for ethereum and stellar
        appSettings.swipeAddressForEther = wallet.getEtherAddress()
        appSettings.swipeAddressForStellar = stellarWalletAccountRepository.defaultAccount?.publicKey
        paxAssetAccountRepository
            .assetAccountDetails
            .subscribe(onSuccess: { details in
                appSettings.swipeAddressForPax = details.account.accountAddress
            })
            .disposed(by: disposeBag)

        tetherAssetAccountRepository
            .assetAccountDetails
            .subscribe(onSuccess: { details in
                appSettings.swipeAddressForTether = details.account.accountAddress
            })
            .disposed(by: disposeBag)
        
        // Retrieve swipe addresses for bitcoin and bitcoin cash
        let assetTypesWithHDAddresses = [CryptoCurrency.bitcoin, CryptoCurrency.bitcoinCash]
        assetTypesWithHDAddresses.forEach {
            let swipeAddresses = self.swipeAddresses(for: $0)
            let numberOfAddressesToDerive = Constants.Wallet.swipeToReceiveAddressCount - swipeAddresses.count
            if numberOfAddressesToDerive > 0 {
                wallet.getSwipeAddresses(Int32(numberOfAddressesToDerive), assetType: $0.legacy)
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
        case .tether:
            guard let address = appSettings.swipeAddressForTether else {
                return []
            }
            return [AnyERC20AssetAddress<TetherToken>(publicKey: address)]
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

    /// removes all swipe addresses for the provided CryptoCurrency
    ///
    /// - Parameter assetType: the CryptoCurrency
    @objc func removeAllSwipeAddresses(for assetType: LegacyCryptoCurrency) {
        KeychainItemWrapper.removeAllSwipeAddresses(for: assetType.legacy)
    }
    
    /// removes all swipe addresses for the provided CryptoCurrency
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
        Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            // Continue only if address reusability is not supported for the given asset type
            guard !asset.shouldAddressesBeReused else {
                Logger.shared.info("\(asset.name) addresses not supported for checking if it is unused.")
                single(.success(.unused(address: address)))
                return Disposables.create()
            }
            
            var assetAddress = AssetAddressFactory.create(fromAddressString: address, assetType: asset)
            if let bchAddress = assetAddress as? BitcoinCashAssetAddress,
                let transformedBtcAddress = bchAddress.bitcoinAssetAddress(from: self.walletManager.wallet) {
                assetAddress = transformedBtcAddress
            }
            
            guard let urlString = BlockchainAPI.shared.assetInfoURL(for: assetAddress), let url = URL(string: urlString) else {
                Logger.shared.warning("Cannot construct URL to check if the address '\(address)' is unused.")
                single(.success(.unknown(address: address)))
                return Disposables.create()
            }
            
            let task = self.urlSession.dataTask(with: url, completionHandler: { data, _, error in
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject],
                    let transactions = json["txs"] as? [NSDictionary] else {
                        single(.error(NetworkError.jsonParseError))
                        return
                }
                let usage: AddressUsageStatus = transactions.isEmpty ? .unused(address: address) : .used(address: address)
                single(.success(usage))
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

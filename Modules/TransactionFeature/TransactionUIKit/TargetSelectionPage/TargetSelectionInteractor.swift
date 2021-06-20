// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

final class TargetSelectionInteractor {

    private let coincore: CoincoreAPI
    private let linkedBanksFactory: LinkedBanksFactoryAPI
    private let featureFetcher: FeatureFetching
    private let nameResolutionService: BlockchainNameResolutionServicing

    init(coincore: CoincoreAPI = resolve(),
         nameResolutionService: BlockchainNameResolutionServicing = resolve(),
         featureFetcher: FeatureFetching = resolve(),
         linkedBanksFactory: LinkedBanksFactoryAPI = resolve()) {
        self.coincore = coincore
        self.linkedBanksFactory = linkedBanksFactory
        self.featureFetcher = featureFetcher
        self.nameResolutionService = nameResolutionService
    }

    func getBitPayInvoiceTarget(data: String, asset: CryptoCurrency) -> Single<BitPayInvoiceTarget> {
        BitPayInvoiceTarget.make(from: data, asset: .bitcoin)
    }

    func getAvailableTargetAccounts(sourceAccount: BlockchainAccount,
                                    action: AssetAction) -> Single<[SingleAccount]> {
        switch action {
        case .swap,
             .send:
            return Single.just(sourceAccount)
                .flatMap(weak: self) { (self, account) -> Single<[SingleAccount]> in
                    self.coincore.getTransactionTargets(sourceAccount: account, action: action)
                }
        case .deposit:
            return linkedBanksFactory.nonWireTransferBanks.map { $0.map { $0 as SingleAccount } }
        case .withdraw:
            return linkedBanksFactory.linkedBanks.map { $0.map { $0 as SingleAccount } }
        case .receive,
             .sell,
             .viewActivity:
            unimplemented()
        }
    }

    func validateCrypto(address: String, account: BlockchainAccount) -> Single<Result<ReceiveAddress, Error>> {
        guard let crypto = account as? CryptoAccount else {
            fatalError("You cannot validate an address using this account type: \(account)")
        }
        guard let asset = coincore[crypto.asset] else {
            fatalError("asset for \(account) not found")
        }
        return asset
            .parse(address: address)
            .flatMap(weak: self) { (self, validatedAddress) -> Single<Result<ReceiveAddress, Error>> in
                guard let validatedAddress = validatedAddress else {
                    return self.validate(domainName: address, currency: crypto.asset)
                }
                return .just(.success(validatedAddress))
            }
    }

    private func validate(domainName: String, currency: CryptoCurrency) -> Single<Result<ReceiveAddress, Error>> {
        featureFetcher.fetchBool(for: .sendToDomainName)
            .flatMap(weak: self) { (self, isEnabled) -> Single<Result<ReceiveAddress, Error>> in
                guard isEnabled else {
                    return .just(.failure(CryptoAssetError.addressParseFailure))
                }
                return self.nameResolutionService
                    .validate(domainName: domainName, currency: currency)
                    .asObservable()
                    .take(1)
                    .asSingle()
                    .map { receiveAddress -> Result<ReceiveAddress, Error> in
                        switch receiveAddress {
                        case .some(let receiveAddress):
                            return .success(receiveAddress)
                        case .none:
                            return .failure(CryptoAssetError.addressParseFailure)
                        }
                    }
            }
    }
}

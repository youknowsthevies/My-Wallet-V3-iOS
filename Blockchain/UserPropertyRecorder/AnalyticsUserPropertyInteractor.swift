//
//  AnalyticsUserPropertyInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 01/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

/// This class connect the analytics service with the application layer
final class AnalyticsUserPropertyInteractor {
    
    // MARK: - Properties
    
    private let recorder: UserPropertyRecording
    private let dataRepository: BlockchainDataRepository
    private let tiersService: KYCTiersServiceAPI
    private let walletRepository: WalletRepositoryAPI
    private let balanceProvider: BalanceProviding
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(recorder: UserPropertyRecording = AnalyticsUserPropertyRecorder(),
         balanceProvider: BalanceProviding = DataProvider.default.balance,
         tiersService: KYCTiersServiceAPI = KYCServiceProvider.default.tiers,
         walletRepository: WalletRepositoryAPI = WalletManager.shared.repository,
         dataRepository: BlockchainDataRepository = .shared) {
        self.recorder = recorder
        self.dataRepository = dataRepository
        self.balanceProvider = balanceProvider
        self.walletRepository = walletRepository
        self.tiersService = tiersService
    }
    
    /// Records all the user properties
    func record() {
        
        let balances = balanceProvider.fiatBalances
            .filter { $0.isValue }
            .map { totalState in
                totalState.all.compactMap { $0.value }
            }
            .take(1)
            .asSingle()
        
        Single
            .zip(
                dataRepository.nabuUserSingle,
                tiersService.tiers,
                walletRepository.authenticatorType,
                walletRepository.guid,
                balances
            )
            .subscribe(
                onSuccess: { [weak self] (user, tiers, authenticatorType, guid, balances) in
                    self?.record(
                        user: user,
                        tiers: tiers,
                        authenticatorType: authenticatorType,
                        guid: guid,
                        balances: balances
                    )
                },
                onError: { error in
                    Logger.shared.error(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func record(user: NabuUser?,
                        tiers: KYC.UserTiers?,
                        authenticatorType: AuthenticatorType,
                        guid: String?,
                        balances: [AssetFiatCryptoBalancePairs]) {
        if let identifier = user?.personalDetails.identifier {
            recorder.record(id: identifier)
        }
        
        if let guid = guid {
            let property = HashedUserProperty(key: .walletID, value: guid)
            recorder.record(property)
        }
        
        if let tiers = tiers {
            let value = "\(tiers.latestTier.rawValue)"
            recorder.record(StandardUserProperty(key: .kycLevel, value: value))
        }
        
        if let date = user?.kycCreationDate {
            recorder.record(StandardUserProperty(key: .kycCreationDate, value: date))
        }
        
        if let date = user?.kycUpdateDate {
            recorder.record(StandardUserProperty(key: .kycUpdateDate, value: date))
        }
        
        if let isEmailVerified = user?.email.verified {
            recorder.record(StandardUserProperty(key: .emailVerified, value: String(isEmailVerified)))
        }
        
        recorder.record(StandardUserProperty(key: .twoFAEnabled, value: String(authenticatorType.isTwoFactor)))
        
        let firstBalance = balances[0]
        var totalFiatBalance = firstBalance.fiat
        
        var positives: [String] = []
        if firstBalance.crypto.isPositive {
            positives += [firstBalance.crypto.code]
        }
                
        for balance in balances.dropFirst() {
            do {
                if balance.crypto.isPositive {
                    positives += [balance.crypto.code]
                }
                totalFiatBalance = try totalFiatBalance + balance.fiat
            } catch {
                Logger.shared.error(error)
            }
        }
        
        recorder.record(StandardUserProperty(key: .fundedCoins, value: positives.joined(separator: ",")))
        
        var reportedBalance: String
        switch totalFiatBalance.amount {
        case 0:
            reportedBalance = "0"
        case (1...10):
            reportedBalance = "1-10"
        case (11...100):
            reportedBalance = "11-100"
        case (101...1000):
            reportedBalance = "101-1000"
        default: // > 1000
            reportedBalance = "1001"
        }
        reportedBalance += " \(totalFiatBalance.currency.code)"
        recorder.record(StandardUserProperty(key: .totalBalance, value: reportedBalance))
    }
}

//
//  AnnouncementInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import ERC20Kit
import EthereumKit
import PlatformKit
import PlatformUIKit
import RxSwift

/// The announcement interactor cross all the preliminary data
/// that is required to display announcements to the user
final class AnnouncementInteractor: AnnouncementInteracting {
    
    // MARK: - Services
    
    /// Dispatch queue
    private let dispatchQueueName = "announcements-interaction-queue"
    
    private let wallet: WalletProtocol
    private let dataRepository: BlockchainDataRepository
    private let tiersService: KYCTiersServiceAPI
    private let infoService: GeneralInformationServiceAPI
    private let exchangeService: ExchangeService
    private let repository: AuthenticatorRepositoryAPI
    private let simpleBuyServiceProvider: ServiceProviderAPI

    /// Returns announcement preliminary data, according to which the relevant
    /// announcement will be displayed
    var preliminaryData: Single<AnnouncementPreliminaryData> {
        guard wallet.isInitialized() else {
            return Single.error(AnnouncementError.uninitializedWallet)
        }
        
        let nabuUser = dataRepository.nabuUserSingle
        let tiers = tiersService.tiers
        let countries = infoService.countries
        let hasTrades = exchangeService.hasExecutedTrades()
        let simpleBuyOrderDetails = simpleBuyServiceProvider
            .pendingOrderDetails
            .pendingActionOrderDetails

        let isSimpleBuyAvailable = simpleBuyServiceProvider
            .supportedPairsInteractor
            .pairs
            .map { !$0.pairs.isEmpty }
            .take(1)
            .asSingle()

        return Single
            .zip(nabuUser,
                 tiers,
                 hasTrades,
                 countries,
                 repository.authenticatorType,
                 Single.zip(
                     isSimpleBuyAvailable,
                     simpleBuyOrderDetails,
                     simpleBuyServiceProvider.beneficiaries.hasLinkedBank
                 )
            )
            .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: dispatchQueueName))
            .observeOn(MainScheduler.instance)
            .map { (arg) -> AnnouncementPreliminaryData in
                let (user, tiers, hasTrades, countries, authenticatorType, (isSimpleBuyAvailable, pendingOrderDetails, hasLinkedBanks)) = arg
                return AnnouncementPreliminaryData(
                    user: user,
                    tiers: tiers,
                    hasTrades: hasTrades,
                    hasLinkedBanks: hasLinkedBanks,
                    countries: countries,
                    authenticatorType: authenticatorType,
                    pendingOrderDetails: pendingOrderDetails,
                    isSimpleBuyAvailable: isSimpleBuyAvailable
                )
            }
    }
    
    // MARK: - Setup
    
    init(repository: AuthenticatorRepositoryAPI = WalletManager.shared.repository,
         wallet: WalletProtocol = WalletManager.shared.wallet,
         dataRepository: BlockchainDataRepository = .shared,
         tiersService: KYCTiersServiceAPI = KYCServiceProvider.default.tiers,
         exchangeService: ExchangeService = .shared,
         infoService: GeneralInformationServiceAPI = UserInformationServiceProvider.default.general,
         paxAccountRepository: ERC20AssetAccountRepository<PaxToken> = PAXServiceProvider.shared.services.assetAccountRepository,
         simpleBuyServiceProvider: ServiceProviderAPI = DataProvider.default.buySell) {
        self.repository = repository
        self.wallet = wallet
        self.dataRepository = dataRepository
        self.tiersService = tiersService
        self.infoService = infoService
        self.exchangeService = exchangeService
        self.simpleBuyServiceProvider = simpleBuyServiceProvider
    }
}

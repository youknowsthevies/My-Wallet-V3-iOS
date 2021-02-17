//
//  AnnouncementInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 18/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import ERC20Kit
import EthereumKit
import PlatformKit
import PlatformUIKit
import RxSwift

/// The announcement interactor cross all the preliminary data
/// that is required to display announcements to the user
final class AnnouncementInteractor: AnnouncementInteracting {
    
    // MARK: - Services
    
    /// Returns announcement preliminary data, according to which the relevant
    /// announcement will be displayed
    var preliminaryData: Single<AnnouncementPreliminaryData> {
        guard wallet.isInitialized() else {
            return Single.error(AnnouncementError.uninitializedWallet)
        }
        
        let nabuUser = dataRepository.nabuUserSingle
        let tiers = tiersService.tiers
        let countries = infoService.countries
        let simpleBuyOrderDetails = pendingOrderDetailsService
            .pendingActionOrderDetails

        let isSimpleBuyAvailable = supportedPairsInteractor.pairs
            .map { !$0.pairs.isEmpty }
            .take(1)
            .asSingle()

        return Single
            .zip(nabuUser,
                 tiers,
                 countries,
                 repository.authenticatorType,
                 Single.zip(
                     isSimpleBuyAvailable,
                     simpleBuyOrderDetails,
                    beneficiariesService.hasLinkedBank.take(1).asSingle(),
                    simpleBuyEligibilityService.isEligible
                 )
            )
            .observeOn(MainScheduler.instance)
            .map { (arg) -> AnnouncementPreliminaryData in
                let (user,
                     tiers,
                     countries,
                     authenticatorType,
                     (isSimpleBuyAvailable, pendingOrderDetails, hasLinkedBanks, isSimpleBuyEligible)) = arg
                return AnnouncementPreliminaryData(
                    user: user,
                    tiers: tiers,
                    hasLinkedBanks: hasLinkedBanks,
                    countries: countries,
                    authenticatorType: authenticatorType,
                    pendingOrderDetails: pendingOrderDetails,
                    isSimpleBuyAvailable: isSimpleBuyAvailable,
                    isSimpleBuyEligible: isSimpleBuyEligible
                )
            }
    }
    
    // MARK: - Private properties
    
    /// Dispatch queue
    private let dispatchQueueName = "announcements-interaction-queue"
    
    private let wallet: WalletProtocol
    private let dataRepository: BlockchainDataRepository
    private let tiersService: KYCTiersServiceAPI
    private let infoService: GeneralInformationServiceAPI
    private let repository: AuthenticatorRepositoryAPI
    private let supportedPairsInteractor: SupportedPairsInteractorServiceAPI
    private let beneficiariesService: BeneficiariesServiceAPI
    private let pendingOrderDetailsService: PendingOrderDetailsServiceAPI
    private let simpleBuyEligibilityService: EligibilityServiceAPI
    
    // MARK: - Setup
    
    init(repository: AuthenticatorRepositoryAPI = WalletManager.shared.repository,
         wallet: WalletProtocol = WalletManager.shared.wallet,
         dataRepository: BlockchainDataRepository = .shared,
         tiersService: KYCTiersServiceAPI = resolve(),
         infoService: GeneralInformationServiceAPI = resolve(),
         paxAccountRepository: ERC20AssetAccountRepository<PaxToken> = resolve(),
         supportedPairsInteractor: SupportedPairsInteractorServiceAPI = resolve(),
         beneficiariesService: BeneficiariesServiceAPI = resolve(),
         pendingOrderDetailsService: PendingOrderDetailsServiceAPI = resolve(),
         simpleBuyEligibilityService: EligibilityServiceAPI = resolve()) {
        self.repository = repository
        self.wallet = wallet
        self.dataRepository = dataRepository
        self.tiersService = tiersService
        self.infoService = infoService
        self.supportedPairsInteractor = supportedPairsInteractor
        self.beneficiariesService = beneficiariesService
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.simpleBuyEligibilityService = simpleBuyEligibilityService
    }
}

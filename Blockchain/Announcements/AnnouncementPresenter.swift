// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import DIKit
import FeatureCryptoDomainDomain
import FeatureCryptoDomainUI
import FeatureDashboardUI
import FeatureKYCDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import RxToolKit
import SwiftUI
import ToolKit
import UIComponentsKit
import WalletPayloadKit

/// Describes the announcement visual. Plays as a presenter / provide for announcements,
/// By creating a list of pending announcements, on which subscribers can be informed.
final class AnnouncementPresenter {

    // MARK: - Rx

    /// Returns a driver with `.none` as default value for announcement action
    /// Scheduled on be executed on main scheduler, its resources are shared and it remembers the last value.
    var announcement: Driver<AnnouncementDisplayAction> {
        announcementRelay
            .asDriver()
            .distinctUntilChanged()
    }

    // MARK: Services

    private let tabSwapping: TabSwapping
    private let walletOperating: WalletOperationsRouting
    private let backupFlowStarter: BackupFlowStarterAPI
    private let settingsStarter: SettingsStarterAPI

    private let app: AppProtocol
    private let featureFetcher: RxFeatureFetching
    private let cashIdentityVerificationRouter: CashIdentityVerificationAnnouncementRouting
    private let interestIdentityVerificationRouter: InterestIdentityVerificationAnnouncementRouting
    private let kycRouter: KYCRouterAPI
    private let exchangeCoordinator: ExchangeCoordinator
    private let wallet: Wallet
    private let kycSettings: KYCSettingsAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let interactor: AnnouncementInteracting
    private let webViewServiceAPI: WebViewServiceAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let navigationRouter: NavigationRouterAPI
    private let exchangeProviding: ExchangeProviding
    private let accountsRouter: AccountsRouting

    private let coincore: CoincoreAPI
    private let nabuUserService: NabuUserServiceAPI
    private let claimEligibilityRepository: ClaimEligibilityRepositoryAPI
    private var claimFreeDomainEligible: Atomic<Bool> = .init(false)

    private let announcementRelay = BehaviorRelay<AnnouncementDisplayAction>(value: .hide)
    private let disposeBag = DisposeBag()

    private var currentAnnouncement: Announcement?

    // Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup

    init(
        app: AppProtocol = DIKit.resolve(),
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        exchangeProviding: ExchangeProviding = DIKit.resolve(),
        accountsRouter: AccountsRouting = DIKit.resolve(),
        interactor: AnnouncementInteracting = AnnouncementInteractor(),
        topMostViewControllerProvider: TopMostViewControllerProviding = DIKit.resolve(),
        featureFetcher: RxFeatureFetching = DIKit.resolve(),
        cashIdentityVerificationRouter: CashIdentityVerificationAnnouncementRouting = DIKit.resolve(),
        interestIdentityVerificationRouter: InterestIdentityVerificationAnnouncementRouting = DIKit.resolve(),
        tabSwapping: TabSwapping = DIKit.resolve(),
        walletOperating: WalletOperationsRouting = DIKit.resolve(),
        backupFlowStarter: BackupFlowStarterAPI = DIKit.resolve(),
        settingsStarter: SettingsStarterAPI = DIKit.resolve(),
        exchangeCoordinator: ExchangeCoordinator = .shared,
        kycRouter: KYCRouterAPI = DIKit.resolve(),
        reactiveWallet: ReactiveWalletAPI = WalletManager.shared.reactiveWallet,
        kycSettings: KYCSettingsAPI = DIKit.resolve(),
        webViewServiceAPI: WebViewServiceAPI = DIKit.resolve(),
        wallet: Wallet = WalletManager.shared.wallet,
        analyticsRecorder: AnalyticsEventRecorderAPI = DIKit.resolve(),
        coincore: CoincoreAPI = DIKit.resolve(),
        nabuUserService: NabuUserServiceAPI = DIKit.resolve(),
        claimEligibilityRepository: ClaimEligibilityRepositoryAPI = DIKit.resolve()
    ) {
        self.app = app
        self.interactor = interactor
        self.webViewServiceAPI = webViewServiceAPI
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.interestIdentityVerificationRouter = interestIdentityVerificationRouter
        self.cashIdentityVerificationRouter = cashIdentityVerificationRouter
        self.exchangeCoordinator = exchangeCoordinator
        self.kycRouter = kycRouter
        self.reactiveWallet = reactiveWallet
        self.kycSettings = kycSettings
        self.featureFetcher = featureFetcher
        self.wallet = wallet
        self.analyticsRecorder = analyticsRecorder
        self.tabSwapping = tabSwapping
        self.walletOperating = walletOperating
        self.backupFlowStarter = backupFlowStarter
        self.settingsStarter = settingsStarter
        self.navigationRouter = navigationRouter
        self.exchangeProviding = exchangeProviding
        self.accountsRouter = accountsRouter
        self.coincore = coincore
        self.nabuUserService = nabuUserService
        self.claimEligibilityRepository = claimEligibilityRepository

        announcement
            .asObservable()
            .filter(\.isHide)
            .mapToVoid()
            .bindAndCatch(weak: self) { (self) in
                self.currentAnnouncement = nil
            }
            .disposed(by: disposeBag)

        claimEligibilityRepository
            .checkClaimEligibility()
            .sink { [weak self] enabled in
                self?.claimFreeDomainEligible.mutate { $0 = enabled }
            }
            .store(in: &cancellables)
    }

    /// Refreshes announcements on demand
    func refresh() {
        reactiveWallet
            .waitUntilInitialized
            .asObservable()
            .bind { [weak self] _ in
                self?.calculate()
            }
            .disposed(by: disposeBag)
    }

    private func calculate() {
        let announcementsMetadata = featureFetcher
            .fetch(for: .announcements, as: AnnouncementsMetadata.self)
        let data: Single<AnnouncementPreliminaryData> = interactor.preliminaryData
            .delaySubscription(.seconds(10), scheduler: MainScheduler.asyncInstance)
        Single
            .zip(announcementsMetadata, data)
            .flatMap(weak: self) { (self, payload) -> Single<AnnouncementDisplayAction> in
                let action = self.resolve(metadata: payload.0, preliminaryData: payload.1)
                return .just(action)
            }
            .catchAndReturn(.hide)
            .asObservable()
            .bindAndCatch(to: announcementRelay)
            .disposed(by: disposeBag)
    }

    /// Resolves the first valid announcement according by the provided types and preliminary data
    // swiftlint:disable:next cyclomatic_complexity
    private func resolve(
        metadata: AnnouncementsMetadata,
        preliminaryData: AnnouncementPreliminaryData
    ) -> AnnouncementDisplayAction {
        // For other users, keep the current logic in place
        for type in metadata.order {
            // IOS-6127: wallets with no balance should show no announcements
            // NOTE: Need to do this here to ensure we show the announcement for ukEntitySwitch or claim domain no matter what.
            guard preliminaryData.hasAnyWalletBalance || type == .ukEntitySwitch || type == .claimFreeCryptoDomain
            else {
                return .none
            }

            let announcement: Announcement
            switch type {
            case .claimFreeCryptoDomain:
                guard claimFreeDomainEligible.value else {
                    return .none
                }
                announcement = claimFreeCryptoDomainAnnoucement
            case .resubmitDocumentsAfterRecovery:
                announcement = resubmitDocumentsAfterRecovery(user: preliminaryData.user)
            case .sddUsersFirstBuy:
                announcement = sddUsersFirstBuy(
                    tiers: preliminaryData.tiers,
                    isSDDEligible: preliminaryData.isSDDEligible,
                    hasAnyWalletBalance: preliminaryData.hasAnyWalletBalance,
                    reappearanceTimeInterval: metadata.interval
                )
            case .cloudBackup:
                announcement = cloudBackupAnnouncement
            case .interestFunds:
                announcement = interestAnnouncement(isKYCVerified: preliminaryData.tiers.isTier2Approved)
            case .fiatFundsNoKYC:
                announcement = cashAnnouncement(isKYCVerified: preliminaryData.tiers.isTier2Approved)
            case .fiatFundsKYC:
                announcement = fiatFundsLinkBank(
                    isKYCVerified: preliminaryData.tiers.isTier2Approved,
                    hasLinkedBanks: preliminaryData.simpleBuy.hasLinkedBanks
                )
            case .verifyEmail:
                announcement = verifyEmail(
                    user: preliminaryData.user,
                    reappearanceTimeInterval: metadata.interval
                )
            case .twoFA:
                announcement = twoFA(data: preliminaryData, reappearanceTimeInterval: metadata.interval)
            case .backupFunds:
                announcement = backupFunds(reappearanceTimeInterval: metadata.interval)
            case .buyBitcoin:
                announcement = buyBitcoin(reappearanceTimeInterval: metadata.interval)
            case .transferBitcoin:
                announcement = transferBitcoin(
                    isKycSupported: preliminaryData.isKycSupported,
                    reappearanceTimeInterval: metadata.interval
                )
            case .kycAirdrop:
                announcement = kycAirdrop(
                    user: preliminaryData.user,
                    tiers: preliminaryData.tiers,
                    isKycSupported: preliminaryData.isKycSupported,
                    reappearanceTimeInterval: metadata.interval
                )
            case .verifyIdentity:
                announcement = verifyIdentity(using: preliminaryData.user)
            case .exchangeLinking:
                announcement = exchangeLinking(user: preliminaryData.user)
            case .bitpay:
                announcement = bitpay
            case .resubmitDocuments:
                announcement = resubmitDocuments(user: preliminaryData.user)
            case .simpleBuyKYCIncomplete:
                announcement = simpleBuyFinishSignup(
                    tiers: preliminaryData.tiers,
                    hasIncompleteBuyFlow: preliminaryData.hasIncompleteBuyFlow,
                    reappearanceTimeInterval: metadata.interval
                )
            case .newSwap:
                announcement = newSwap(using: preliminaryData, reappearanceTimeInterval: metadata.interval)
            case .newAsset:
                announcement = newAsset(cryptoCurrency: preliminaryData.newAsset)
            case .assetRename:
                announcement = assetRename(
                    data: preliminaryData.assetRename
                )
            case .celoEUR:
                announcement = celoEUR(
                    celoEUR: preliminaryData.celoEUR,
                    user: preliminaryData.user,
                    tiers: preliminaryData.tiers
                )
            case .ukEntitySwitch:
                announcement = ukEntitySwitch(user: preliminaryData.user)
            case .walletConnect:
                announcement = walletConnect()
            case .taxCenter:
                announcement = taxCenter(
                    userCountry: preliminaryData.user.address?.country,
                    reappearanceTimeInterval: metadata.interval
                )
            }

            // Return the first different announcement that should show
            if announcement.shouldShow {
                if currentAnnouncement?.type != announcement.type {
                    currentAnnouncement = announcement
                    return .show(announcement.viewModel)
                } else { // Announcement is currently displaying
                    return .none
                }
            }
        }
        // None of the types were resolved into a displayable announcement
        return .none
    }

    // MARK: - Accessors

    /// Hides whichever announcement is now displaying
    private func hideAnnouncement() {
        announcementRelay.accept(.hide)
    }
}

// MARK: - Computes announcements

extension AnnouncementPresenter {

    /// Computes email verification announcement
    private func verifyEmail(
        user: NabuUser,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        VerifyEmailAnnouncement(
            isEmailVerified: user.email.verified,
            reappearanceTimeInterval: reappearanceTimeInterval,
            action: UIApplication.shared.openMailApplication,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            }
        )
    }

    /// Computes Simple Buy Finish Signup Announcement
    private func simpleBuyFinishSignup(
        tiers: KYC.UserTiers,
        hasIncompleteBuyFlow: Bool,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        SimpleBuyFinishSignupAnnouncement(
            canCompleteTier2: tiers.canCompleteTier2,
            hasIncompleteBuyFlow: hasIncompleteBuyFlow,
            reappearanceTimeInterval: reappearanceTimeInterval,
            action: { [weak self] in
                guard let self = self else { return }
                self.hideAnnouncement()
                self.handleBuyCrypto()
            },
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            }
        )
    }

    // Computes kyc airdrop announcement
    private func kycAirdrop(
        user: NabuUser,
        tiers: KYC.UserTiers,
        isKycSupported: Bool,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        KycAirdropAnnouncement(
            canCompleteTier2: tiers.canCompleteTier2,
            isKycSupported: isKycSupported,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycRouter.start(
                    tier: tier,
                    parentFlow: .airdrop,
                    from: self.tabSwapping
                )
            }
        )
    }

    // Computes transfer in bitcoin announcement
    private func transferBitcoin(isKycSupported: Bool, reappearanceTimeInterval: TimeInterval) -> Announcement {
        TransferInCryptoAnnouncement(
            isKycSupported: isKycSupported,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                guard let self = self else { return }
                self.hideAnnouncement()
                self.tabSwapping.switchTabToReceive()
            }
        )
    }

    /// Computes identity verification card announcement
    private func verifyIdentity(using user: NabuUser) -> Announcement {
        VerifyIdentityAnnouncement(
            isSunriverAirdropRegistered: user.isSunriverAirdropRegistered,
            isCompletingKyc: kycSettings.isCompletingKyc,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycRouter.start(
                    tier: tier,
                    parentFlow: .announcement,
                    from: self.tabSwapping
                )
            }
        )
    }

    /// Computes Bitpay announcement
    private var bitpay: Announcement {
        BitpayAnnouncement(
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            }
        )
    }

    /// Computes Wallet-Exchange linking announcement
    private func exchangeLinking(user: NabuUser) -> Announcement {
        ExchangeLinkingAnnouncement(
            shouldShowExchangeAnnouncement: !user.hasLinkedExchangeAccount,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak exchangeCoordinator] in
                exchangeCoordinator?.start()
            }
        )
    }

    private func showAssetDetailsScreen(for currency: CryptoCurrency) {
        app.post(event: blockchain.ux.asset[currency.code].select)
    }

    /// Computes asset rename card announcement.
    private func assetRename(
        data: AnnouncementPreliminaryData.AssetRename?
    ) -> Announcement {
        AssetRenameAnnouncement(
            data: data,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                guard let asset = data?.asset else {
                    return
                }
                self?.showAssetDetailsScreen(for: asset)
            }
        )
    }

    /// Computes CeloEUR card announcement.
    private func celoEUR(
        celoEUR: CryptoCurrency?,
        user: NabuUser,
        tiers: KYC.UserTiers
    ) -> Announcement {
        CeloEURAnnouncement(
            celoEUR: celoEUR,
            tiers: tiers,
            userCountry: user.address?.country,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [topMostViewControllerProvider, webViewServiceAPI] in
                guard let topMostViewController = topMostViewControllerProvider.topMostViewController else {
                    return
                }
                webViewServiceAPI.openSafari(
                    url: "https://www.blockchain.com/getceur",
                    from: topMostViewController
                )
            }
        )
    }

    private func ukEntitySwitch(user: NabuUser) -> Announcement {
        UKEntitySwitchAnnouncement(
            userCountry: user.address?.country,
            dismiss: hideAnnouncement,
            action: { [topMostViewControllerProvider, webViewServiceAPI] in
                guard let topMostViewController = topMostViewControllerProvider.topMostViewController else {
                    return
                }
                webViewServiceAPI.openSafari(
                    url: "https://support.blockchain.com/hc/en-us/articles/4418431131668",
                    from: topMostViewController
                )
            }
        )
    }

    private func walletConnect() -> Announcement {
        WalletConnectAnnouncement(
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [topMostViewControllerProvider, webViewServiceAPI] in
                guard let topMostViewController = topMostViewControllerProvider.topMostViewController else {
                    return
                }
                webViewServiceAPI.openSafari(
                    url: "https://medium.com/blockchain/introducing-walletconnect-access-web3-from-your-blockchain-com-wallet-da02e49ccea9",
                    from: topMostViewController
                )
            }
        )
    }

    private func taxCenter(
        userCountry: Country?,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        TaxCenterAnnouncement(
            userCountry: userCountry,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            }
        )
    }

    /// Computes new asset card announcement.
    private func newAsset(cryptoCurrency: CryptoCurrency?) -> Announcement {
        NewAssetAnnouncement(
            cryptoCurrency: cryptoCurrency,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                guard let cryptoCurrency = cryptoCurrency else {
                    return
                }
                self?.handleBuyCrypto(currency: cryptoCurrency)
            }
        )
    }

    /// Cash Support Announcement for users who have not KYC'd
    private func cashAnnouncement(isKYCVerified: Bool) -> Announcement {
        CashIdentityVerificationAnnouncement(
            shouldShowCashIdentityAnnouncement: !isKYCVerified,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak cashIdentityVerificationRouter] in
                cashIdentityVerificationRouter?.showCashIdentityVerificationScreen()
            }
        )
    }

    /// Cash Support Announcement for users who have not KYC'd
    private var cloudBackupAnnouncement: Announcement {
        CloudBackupAnnouncement(
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                guard let self = self else {
                    return
                }
                guard let topMostViewController = self.topMostViewControllerProvider.topMostViewController else {
                    return
                }
                self.webViewServiceAPI.openSafari(
                    url: "https://support.blockchain.com/hc/en-us/articles/360046143432",
                    from: topMostViewController
                )
            }
        )
    }

    /// Claim Free Crypto Domain Annoucement for eligible users
    private var claimFreeCryptoDomainAnnoucement: Announcement {
        ClaimFreeCryptoDomainAnnouncement(
            action: { [coincore, nabuUserService, navigationRouter] in
                let vc = ClaimIntroductionHostingController(
                    mainQueue: .main,
                    analyticsRecorder: DIKit.resolve(),
                    externalAppOpener: DIKit.resolve(),
                    searchDomainRepository: DIKit.resolve(),
                    orderDomainRepository: DIKit.resolve(),
                    userInfoProvider: {
                        Deferred {
                            Just([coincore[.ethereum], coincore[.bitcoin], coincore[.bitcoinCash], coincore[.stellar]])
                        }
                        .eraseError()
                        .flatMap { cryptoAssets -> AnyPublisher<([ResolutionRecord], NabuUser), Error> in
                            guard let providers = cryptoAssets as? [DomainResolutionRecordProviderAPI] else {
                                return .empty()
                            }
                            let recordPublisher = providers.map(\.resolutionRecord).zip()
                            let nabuUserPublisher = nabuUserService.user.eraseError()
                            return recordPublisher
                                .zip(nabuUserPublisher)
                                .eraseToAnyPublisher()
                        }
                        .map { records, nabuUser -> OrderDomainUserInfo in
                            OrderDomainUserInfo(
                                nabuUserId: nabuUser.identifier,
                                nabuUserName: nabuUser
                                    .personalDetails
                                    .firstName?
                                    .replacingOccurrences(of: " ", with: "") ?? "",
                                resolutionRecords: records
                            )
                        }
                        .eraseToAnyPublisher()
                    }
                )
                let nav = UINavigationController(rootViewController: vc)
                navigationRouter.present(viewController: nav, using: .modalOverTopMost)
            },
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            }
        )
    }

    /// Interest Account Announcement for users who have not KYC'd
    private func interestAnnouncement(isKYCVerified: Bool) -> Announcement {
        InterestIdentityVerificationAnnouncement(
            isKYCVerified: isKYCVerified,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak interestIdentityVerificationRouter] in
                interestIdentityVerificationRouter?.showInterestDashboardAnnouncementScreen(isKYCVerfied: isKYCVerified)
            }
        )
    }

    /// Cash Support Announcement for users who have KYC'd
    /// and have not linked a bank.
    private func fiatFundsLinkBank(isKYCVerified: Bool, hasLinkedBanks: Bool) -> Announcement {
        FiatFundsLinkBankAnnouncement(
            shouldShowLinkBankAnnouncement: false, // TODO: remove `false` and uncomment this: isKYCVerified && !hasLinkedBanks,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: {
                // TODO: Route to bank linking
            }
        )
    }

    /// Computes SDD Users Buy announcement
    private func sddUsersFirstBuy(
        tiers: KYC.UserTiers,
        isSDDEligible: Bool,
        hasAnyWalletBalance: Bool,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        // For now, we want to target non-KYCed SDD eligible users specifically, but we're going to review all announcements soon for Onboarding
        BuyBitcoinAnnouncement(
            isEnabled: tiers.isTier0 && isSDDEligible && !hasAnyWalletBalance,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                self?.handleBuyCrypto(currency: .bitcoin)
            }
        )
    }

    /// Computes Buy BTC announcement
    private func buyBitcoin(reappearanceTimeInterval: TimeInterval) -> Announcement {
        BuyBitcoinAnnouncement(
            isEnabled: !wallet.isBitcoinWalletFunded,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                self?.handleBuyCrypto(currency: .bitcoin)
            }
        )
    }

    /// Computes Swap card announcement
    private func newSwap(
        using data: AnnouncementPreliminaryData,
        reappearanceTimeInterval: TimeInterval
    ) -> Announcement {
        NewSwapAnnouncement(
            isEligibleForSimpleBuy: data.simpleBuy.isEligible,
            isTier1Or2Verified: data.tiers.isTier1Approved || data.tiers.isTier2Approved,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                self?.tabSwapping.switchTabToSwap()
                self?.analyticsRecorder.record(event: AnalyticsEvents.New.Swap.swapClicked(origin: .dashboardPromo))
            }
        )
    }

    /// Computes Backup Funds (recovery phrase)
    private func backupFunds(reappearanceTimeInterval: TimeInterval) -> Announcement {
        let shouldBackupFunds = !wallet.isRecoveryPhraseVerified() && wallet.isBitcoinWalletFunded
        return BackupFundsAnnouncement(
            shouldBackupFunds: shouldBackupFunds,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                self?.backupFlowStarter.startBackupFlow()
            }
        )
    }

    /// Computes 2FA announcement
    private func twoFA(data: AnnouncementPreliminaryData, reappearanceTimeInterval: TimeInterval) -> Announcement {
        let shouldEnable2FA = !data.hasTwoFA && wallet.isBitcoinWalletFunded
        return Enable2FAAnnouncement(
            shouldEnable2FA: shouldEnable2FA,
            reappearanceTimeInterval: reappearanceTimeInterval,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                self?.settingsStarter.showSettingsView()
            }
        )
    }

    /// Computes Upload Documents card announcement
    private func resubmitDocuments(user: NabuUser) -> Announcement {
        ResubmitDocumentsAnnouncement(
            needsDocumentResubmission: user.needsDocumentResubmission != nil
                && user.needsDocumentResubmission?.reason != 1,
            dismiss: { [weak self] in
                self?.hideAnnouncement()
            },
            action: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycRouter.start(
                    tier: tier,
                    parentFlow: .announcement,
                    from: self.tabSwapping
                )
            }
        )
    }

    private func resubmitDocumentsAfterRecovery(user: NabuUser) -> Announcement {
        ResubmitDocumentsAfterRecoveryAnnouncement(
            // reason 1: resubmission needed due to account recovery
            needsDocumentResubmission: user.needsDocumentResubmission?.reason == 1,
            action: { [weak self] in
                guard let self = self else { return }
                let tier = user.tiers?.selected ?? .tier1
                self.kycRouter.start(
                    tier: tier,
                    parentFlow: .announcement,
                    from: self.tabSwapping
                )
            }
        )
    }
}

extension AnnouncementPresenter {
    private func handleBuyCrypto(currency: CryptoCurrency = .bitcoin) {
        walletOperating.handleBuyCrypto(currency: currency)
        analyticsRecorder.record(
            event: AnalyticsEvents.New.SimpleBuy.buySellClicked(type: .buy, origin: .dashboardPromo)
        )
    }
}

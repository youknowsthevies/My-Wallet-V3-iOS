//
//  KYCCoordinator.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import KYCKit
import Localization
import NetworkKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit
import UIKit

enum KYCEvent {

    /// When a particular screen appears, we need to
    /// look at the `NabuUser` object and determine if
    /// there is data there for pre-populate the screen with.
    case pageWillAppear(KYCPageType)

    /// This will push on the next page in the KYC flow.
    case nextPageFromPageType(KYCPageType, KYCPagePayload?)

    /// Event emitted when the provided page type emits an error
    case failurePageForPageType(KYCPageType, KYCPageError)
}

protocol KYCCoordinatorDelegate: AnyObject {
    func apply(model: KYCPageModel)
}

public protocol KYCCoordinating: AnyObject {
    func start()

}

/// Coordinates the KYC flow. This component can be used to start a new KYC flow, or if
/// the user drops off mid-KYC and decides to continue through it again, the coordinator
/// will handle recovering where they left off.
final class KYCCoordinator: KYCRouterAPI {

    // MARK: - Public Properties

    weak var delegate: KYCCoordinatorDelegate?

    // MARK: - Private Properties

    private(set) var user: NabuUser?

    private(set) var country: CountryData?

    private var pager: KYCPagerAPI!

    private weak var rootViewController: UIViewController?

    private var navController: KYCOnboardingNavigationController!

    private let disposables = CompositeDisposable()

    private let disposeBag = DisposeBag()

    private let pageFactory = KYCPageViewFactory()

    private let appSettings: AppSettingsAPI
    private let loadingViewPresenter: LoadingViewPresenting

    private var userTiersResponse: KYC.UserTiers?
    private var kycSettings: KYCSettingsAPI

    private let tiersService: KYCTiersServiceAPI
    private let networkAdapter: NetworkAdapterAPI
    private let analyticsService: AnalyticsServiceAPI
    private let dataRepository: DataRepositoryAPI
    private let requestBuilder: RequestBuilder

    private let webViewServiceAPI: WebViewServiceAPI

    private let kycStoppedRelay = PublishRelay<Void>()
    private let kycFinishedRelay = PublishRelay<KYC.Tier>()

    private var parentFlow = KYCParentFlow.none

    /// KYC finsihed with `tier1` in-progress / approved
    var tier1Finished: Observable<Void> {
        kycFinishedRelay
            .filter { $0 == .tier1 }
            .mapToVoid()
    }

    /// KYC finsihed with `tier2` in-progress / approved
    var tier2Finished: Observable<Void> {
        kycFinishedRelay
            .filter { $0 == .tier2 }
            .mapToVoid()
    }

    var kycStopped: Observable<KYC.Tier> {
        kycFinishedRelay.asObservable()
    }

    init(
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail),
        webViewServiceAPI: WebViewServiceAPI = resolve(),
        tiersService: KYCTiersServiceAPI = resolve(),
        appSettings: AppSettingsAPI = resolve(),
        analyticsService: AnalyticsServiceAPI = resolve(),
        dataRepository: DataRepositoryAPI = resolve(),
        kycSettings: KYCSettingsAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail)
    ) {
        self.requestBuilder = requestBuilder
        self.analyticsService = analyticsService
        self.dataRepository = dataRepository
        self.webViewServiceAPI = webViewServiceAPI
        self.tiersService = tiersService
        self.appSettings = appSettings
        self.kycSettings = kycSettings
        self.loadingViewPresenter = loadingViewPresenter
        self.networkAdapter = networkAdapter

        registerForKYCFinish()
    }

    deinit {
        disposables.dispose()
    }

    // MARK: Public

    func start() {
        start(tier: .tier1)
    }

    func start(tier: KYC.Tier) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            Logger.shared.warning("Cannot start KYC. rootViewController is nil.")
            return
        }
        start(from: rootViewController, tier: tier, parentFlow: .none)
    }

    func start(from viewController: UIViewController, tier: KYC.Tier, parentFlow: KYCParentFlow) {
        self.parentFlow = parentFlow
        rootViewController = viewController
        analyticsService.trackEvent(title: tier.startAnalyticsKey)

        loadingViewPresenter.show(with: LocalizationConstants.loading)
        let postTierObservable = post(tier: tier).asObservable()
        let userObservable = dataRepository.fetchNabuUser().asObservable()

        let disposable = Observable.zip(userObservable, postTierObservable)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .hideLoaderOnDisposal(loader: loadingViewPresenter)
            .subscribe(onNext: { [weak self] (user, tiersResponse) in
                self?.pager = KYCPager(tier: tier, tiersResponse: tiersResponse)
                Logger.shared.debug("Got user with ID: \(user.personalDetails.identifier ?? "")")
                guard let strongSelf = self else {
                    return
                }
                strongSelf.userTiersResponse = tiersResponse
                strongSelf.user = user

                let startingPage = user.isSunriverAirdropRegistered == true ?
                    KYCPageType.welcome :
                    KYCPageType.startingPage(forUser: user, tiersResponse: tiersResponse)
                if startingPage != .accountStatus {
                    /// If the starting page is accountStatus, they do not have any additional
                    /// pages to view, so we don't want to set `isCompletingKyc` to `true`.
                    strongSelf.kycSettings.isCompletingKyc = true
                }

                strongSelf.initializeNavigationStack(viewController, user: user, tier: tier)
                strongSelf.restoreToMostRecentPageIfNeeded(tier: tier)
            }, onError: { error in
                Logger.shared.error("Failed to get user: \(error.localizedDescription)")
                AlertViewPresenter.shared.standardError(message: LocalizationConstants.Errors.genericError)
            })
        disposables.insertWithDiscardableResult(disposable)
    }

    private func registerForKYCFinish() {
        kycStoppedRelay
            .flatMap(weak: self) { (self, _) -> Observable<KYC.UserTiers> in
                self.tiersService.fetchTiers().asObservable()
            }
            .map { $0 }
            .catchErrorJustReturn(nil)
            .compactMap { (tiers: KYC.UserTiers?) in
                tiers?.latestTier ?? nil
            }
            .bindAndCatch(to: kycFinishedRelay)
            .disposed(by: disposeBag)
    }

    // Called when the entire KYC process has been completed.
    func finish() {
        stop()
    }

    // Called when the KYC process is completed or stopped before completing.
    func stop() {
        if navController == nil { return }
        navController.dismiss(animated: true) { [weak self] in
            self?.kycStoppedRelay.accept(())
            NotificationCenter.default.post(
                name: Constants.NotificationKeys.kycStopped,
                object: nil
            )
        }
    }

    func handle(event: KYCEvent) {
        switch event {
        case .pageWillAppear(let type):
            handlePageWillAppear(for: type)
        case .failurePageForPageType(_, let error):
            handleFailurePage(for: error)
        case .nextPageFromPageType(let type, let payload):
            handlePayloadFromPageType(type, payload)
            let disposable = pager.nextPage(from: type, payload: payload)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] nextPage in
                    guard let self = self else {
                        return
                    }

                    switch (self.parentFlow, nextPage) {
                    case (.simpleBuy, .accountStatus):
                        self.finish()
                        return
                    default:
                        break
                    }

                    let controller = self.pageFactory.createFrom(
                        pageType: nextPage,
                        in: self,
                        payload: payload
                    )

                    if let informationController = controller as? KYCInformationController, nextPage == .accountStatus {
                        self.presentInformationController(informationController)
                    } else {
                        self.navController.pushViewController(controller, animated: true)
                    }
                }, onError: { error in
                    Logger.shared.error("Error getting next page: \(error.localizedDescription)")
                }, onCompleted: { [weak self] in
                    Logger.shared.info("No more next pages")
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.kycSettings.isCompletingKyc = false
                    strongSelf.finish()
                })
            disposables.insertWithDiscardableResult(disposable)
        }
    }

    func presentInformationController(_ controller: KYCInformationController) {
        /// Refresh the user's tiers to get their status.
        /// Sometimes we receive an `INTERNAL_SERVER_ERROR` if we refresh this
        /// immediately after submitting all KYC data. So, we apply a delay here.
        tiersService.tiers
            .handleLoaderForLifecycle(loader: loadingViewPresenter)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let self = self else { return }
                    let status = response.tierAccountStatus(for: .tier2)

                    let isReceivingAirdrop = self.user?.isSunriverAirdropRegistered == true
                    controller.viewModel = KYCInformationViewModel.create(
                        for: status,
                        isReceivingAirdrop: isReceivingAirdrop
                    )
                    controller.viewConfig = KYCInformationViewConfig.create(
                        for: status,
                        isReceivingAirdrop: isReceivingAirdrop
                    )
                    controller.primaryButtonAction = { viewController in
                        switch status {
                        case .approved:
                            self.finish()
                        case .pending:
                            break
                        case .failed, .expired:
                            if let blockchainSupportURL = URL(string: Constants.Url.blockchainSupport) {
                                UIApplication.shared.open(blockchainSupportURL)
                            }
                        case .none, .underReview:
                            return
                        }
                    }

                    self.navController.pushViewController(controller, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }

    // MARK: View Restoration

    /// Restores the user to the most recent page if they dropped off mid-flow while KYC'ing
    private func restoreToMostRecentPageIfNeeded(tier: KYC.Tier) {
        guard let currentUser = user else {
            return
        }
        guard let response = userTiersResponse else { return }

        let latestPage = kycSettings.latestKycPage

        let startingPage = KYCPageType.startingPage(forUser: currentUser, tiersResponse: response)

        if startingPage == .accountStatus {
            /// The `tier` on KYCPager cannot be `tier1` if the user's `startingPage` is `.accountStatus`.
            /// If their `startingPage` is `.accountStatus`, they're done.
            pager = KYCPager(tier: .tier2, tiersResponse: response)
        }

        guard let endPageForLastUsedTier = KYCPageType.pageType(
            for: currentUser,
            tiersResponse: response,
            latestPage: latestPage
            ) else {
            return
        }

        // If a user has moved to a new tier, they need to use the starting page for the new tier
        let endPage = endPageForLastUsedTier.rawValue >= startingPage.rawValue ? endPageForLastUsedTier : startingPage

        var currentPage = startingPage
        while currentPage != endPage {
            guard let nextPage = currentPage.nextPage(
                forTier: tier,
                user: user,
                country: country,
                tiersResponse: response
            ) else { return }

            currentPage = nextPage

            let nextController = pageFactory.createFrom(
                pageType: currentPage,
                in: self,
                payload: createPagePayload(page: currentPage, user: currentUser)
            )

            navController.pushViewController(nextController, animated: false)
        }
    }

    private func createPagePayload(page: KYCPageType, user: NabuUser) -> KYCPagePayload? {
        switch page {
        case .confirmPhone:
            return .phoneNumberUpdated(phoneNumber: user.mobile?.phone ?? "")
        case .confirmEmail:
            return .emailPendingVerification(email: user.email.address)
        case .accountStatus:
            guard let response = userTiersResponse else { return nil }
            return .accountStatus(
                status: response.tierAccountStatus(for: .tier2),
                isReceivingAirdrop: user.isSunriverAirdropRegistered == true
            )
        case .enterEmail,
             .welcome,
             .country,
             .states,
             .profile,
             .address,
             .tier1ForcedTier2,
             .enterPhone,
             .verifyIdentity,
             .resubmitIdentity,
             .applicationComplete:
            return nil
        }
    }

    private func initializeNavigationStack(_ viewController: UIViewController, user: NabuUser, tier: KYC.Tier) {
        guard let response = userTiersResponse else { return }
        let startingPage = user.isSunriverAirdropRegistered == true ?
            KYCPageType.welcome :
            KYCPageType.startingPage(forUser: user, tiersResponse: response)
        var controller: KYCBaseViewController
        if startingPage == .accountStatus {
            controller = pageFactory.createFrom(
                pageType: startingPage,
                in: self,
                payload: .accountStatus(
                    status: response.tierAccountStatus(for: .tier2),
                    isReceivingAirdrop: user.isSunriverAirdropRegistered == true
                )
            )
        } else {
            controller = pageFactory.createFrom(
                pageType: startingPage,
                in: self
            )
        }

        navController = presentInNavigationController(controller, in: viewController)
    }

    // MARK: Private Methods

    private func handlePayloadFromPageType(_ pageType: KYCPageType, _ payload: KYCPagePayload?) {
        guard let payload = payload else { return }
        switch payload {
        case .countrySelected(let country):
            self.country = country
        case .phoneNumberUpdated,
             .emailPendingVerification,
             .accountStatus:
            // Not handled here
            return
        }
    }

    private func handleFailurePage(for error: KYCPageError) {

        let informationViewController = KYCInformationController.make(with: self)
        informationViewController.viewConfig = KYCInformationViewConfig(
            titleColor: UIColor.gray5,
            isPrimaryButtonEnabled: true,
            imageTintColor: nil
        )

        switch error {
        case .countryNotSupported(let country):
            kycSettings.isCompletingKyc = false
            informationViewController.viewModel = KYCInformationViewModel.createForUnsupportedCountry(country)
            informationViewController.primaryButtonAction = { [unowned self] viewController in
                viewController.presentingViewController?.presentingViewController?.dismiss(animated: true)
                let interactor = KYCCountrySelectionInteractor()
                let disposable = interactor.selected(
                    country: country,
                    shouldBeNotifiedWhenAvailable: true
                )
                self.disposables.insertWithDiscardableResult(disposable)
            }
            presentInNavigationController(informationViewController, in: navController)
        case .stateNotSupported(let state):
            kycSettings.isCompletingKyc = false
            informationViewController.viewModel = KYCInformationViewModel.createForUnsupportedState(state)
            informationViewController.primaryButtonAction = { [unowned self] viewController in
                viewController.presentingViewController?.presentingViewController?.dismiss(animated: true)
                let interactor = KYCCountrySelectionInteractor()
                let disposable = interactor.selected(
                    state: state,
                    shouldBeNotifiedWhenAvailable: true
                )
                self.disposables.insertWithDiscardableResult(disposable)
            }
            presentInNavigationController(informationViewController, in: navController)
        }
    }

    private func handlePageWillAppear(for type: KYCPageType) {
        if type == .accountStatus || type == .applicationComplete {
            kycSettings.latestKycPage = nil
        } else {
            kycSettings.latestKycPage = type
        }

        // Optionally apply page model
        switch type {
        case .tier1ForcedTier2,
             .welcome,
             .confirmEmail,
             .country,
             .states,
             .accountStatus,
             .applicationComplete,
             .resubmitIdentity:
            break
        case .enterEmail:
            guard let current = user else { return }
            delegate?.apply(model: .email(current))
        case .profile:
            guard let current = user else { return }
            delegate?.apply(model: .personalDetails(current))
        case .address:
            guard let current = user else { return }
            delegate?.apply(model: .address(current, country))
        case .enterPhone, .confirmPhone:
            guard let current = user else { return }
            delegate?.apply(model: .phone(current))
        case .verifyIdentity:
            guard let countryCode = country?.code ?? user?.address?.countryCode else { return }
            delegate?.apply(model: .verifyIdentity(countryCode: countryCode))
        }
    }

    private func post(tier: KYC.Tier) -> Single<KYC.UserTiers> {
        let body = KYCTierPostBody(selectedTier: tier)
        guard let request = requestBuilder.post(
            path: ["kyc", "tiers"],
            body: try? JSONEncoder().encode(body),
            authenticated: true
        ) else {
            return .error(RequestBuilder.Error.buildingRequest)
        }
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    @discardableResult private func presentInNavigationController(
        _ viewController: UIViewController,
        in presentingViewController: UIViewController
    ) -> KYCOnboardingNavigationController {
        let navController = KYCOnboardingNavigationController.make()
        navController.pushViewController(viewController, animated: false)
        navController.modalTransitionStyle = .coverVertical
        presentingViewController.present(navController, animated: true)
        return navController
    }
}

fileprivate extension KYCPageType {

    /// The page type the user should be placed in given the information they have provided
    static func pageType(for user: NabuUser, tiersResponse: KYC.UserTiers, latestPage: KYCPageType? = nil) -> KYCPageType? {
        // Note: latestPage is only used by tier 2 flow, for tier 1, we need to infer the page,
        // because the user may need to select the country again.
        let tier = user.tiers?.selected ?? .tier1
        switch tier {
        case .tier0:
            return nil
        case .tier1:
            return tier1PageType(for: user)
        case .tier2:
            return tier1PageType(for: user) ?? tier2PageType(for: user, tiersResponse: tiersResponse, latestPage: latestPage)
        }
    }

    private static func tier1PageType(for user: NabuUser) -> KYCPageType? {
        guard user.email.verified else {
            return .enterEmail
        }

        guard user.personalDetails.firstName != nil else {
            return .country
        }

        guard user.address != nil else { return .country }

        return nil
    }

    private static func tier2PageType(for user: NabuUser, tiersResponse: KYC.UserTiers, latestPage: KYCPageType? = nil) -> KYCPageType? {
        if let latestPage = latestPage {
            return latestPage
        }

        guard let mobile = user.mobile else { return .enterPhone }

        guard mobile.verified else { return .confirmPhone }

        if tiersResponse.canCompleteTier2 {
            switch tiersResponse.canCompleteTier2 {
            case true:
                return user.needsDocumentResubmission == nil ? .verifyIdentity : .resubmitIdentity
            case false:
                return nil
            }
        }

        guard tiersResponse.canCompleteTier2 == false else { return .verifyIdentity }

        return nil
    }
}

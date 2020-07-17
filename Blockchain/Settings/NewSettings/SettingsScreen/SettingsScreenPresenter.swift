//
//  SettingsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class SettingsScreenPresenter {

    // MARK: - Types

    typealias Section = SettingsSectionType
    
    // MARK: - Navigation Properties
    
    let trailingButton: Screen.Style.TrailingButton = .none
    
    var leadingButton: Screen.Style.LeadingButton {
        if #available(iOS 13.0, *) {
            return .none
        } else {
            return .close
        }
    }
    
    let barStyle: Screen.Style.Bar = .lightContent()
    
    // MARK: - Public Properties
    
    var sectionObservable: Observable<[SettingsSectionViewModel]> {
        sectionsProvider.sections
    }
    
    var sectionArrangement: [Section] {
        sectionRelay.value
    }
    
    // MARK: - Cell Presenters
    
    let sectionsProvider: SettingsSectionsProvider
    
    // MARK: - Public
    
    let actionRelay = PublishRelay<SettingsScreenAction>()

    // MARK: Private Properties
    
    private unowned let router: SettingsRouterAPI
    private let sectionRelay = BehaviorRelay<[Section]>(value: Section.default)
    private let interactor: SettingsScreenInteractor
    private let disposeBag = DisposeBag()
    
    // MARK: - Section Presenters
    
    private let aboutSectionPresenter: AboutSectionPresenter
    private let cardsSectionPresenter: CardsSectionPresenter
    private let securitySectionPresenter: SecuritySectionPresenter
    private let profileSectionPresenter: ProfileSectionPresenter
    private let preferencesSectionPresenter: PreferencesSectionPresenter
    private let connectPresenter: ConnectSectionPresenter
    
    // MARK: - Init
    
    init(interactor: SettingsScreenInteractor = SettingsScreenInteractor(),
         router: SettingsRouterAPI) {
        self.aboutSectionPresenter = AboutSectionPresenter()
        
        self.connectPresenter = .init(
            featureConfiguration: interactor.pitLinkingConfiguration,
            exchangeConnectionStatusProvider: interactor.pitConnnectionProviding
        )
        
        self.securitySectionPresenter = .init(
            smsTwoFactorService: interactor.smsTwoFactorService,
            biometryProvider: interactor.biometryProviding,
            settingsAuthenticater: interactor.settingsAuthenticating,
            recoveryPhraseStatusProvider: interactor.recoveryPhraseStatusProviding
        )
        
        self.cardsSectionPresenter = .init(
            interactor: interactor.cardSectionInteractor,
            paymentMethodTypesService: interactor.simpleBuyService.paymentMethodTypes,
            tierLimitsProviding: interactor.tiersProviding,
            featureConfiguration: interactor.simpleBuyCardsConfiguration,
            featureFetcher: interactor.featureConfigurator
        )
        
        self.profileSectionPresenter = .init(
            tiersLimitsProvider: interactor.tiersProviding,
            emailVerificationInteractor: interactor.emailVerificationBadgeInteractor,
            mobileVerificationInteractor: interactor.mobileVerificationBadgeInteractor
        )
        
        self.preferencesSectionPresenter = .init(
            emailNotificationService: interactor.emailNotificationsService,
            preferredCurrencyBadgeInteractor: interactor.preferredCurrencyBadgeInteractor
        )
        
        sectionsProvider = SettingsSectionsProvider(
            about: aboutSectionPresenter,
            connect: connectPresenter,
            cards: cardsSectionPresenter,
            security: securitySectionPresenter,
            profile: profileSectionPresenter,
            preferences: preferencesSectionPresenter
        )
        
        self.router = router
        self.interactor = interactor
        
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        // Bind notices
        actionRelay
            .bindAndCatch(to: router.actionRelay)
            .disposed(by: disposeBag)
        
        sectionsProvider
            .sections
            .map { $0.map { $0.sectionType } }
            .bindAndCatch(to: sectionRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public
    
    /// Should be called each time the `Settings` screen comes into view
    func refresh() {
        interactor.refresh()
    }
    
    // MARK: - Exposed
    
    func navigationBarLeadingButtonTapped() {
        router.previousRelay.accept(())
    }
}

//
//  UpdateMobileRouter.swift
//  Blockchain
//
//  Created by AlexM on 3/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

final class UpdateMobileRouter: Router {
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?
    
    private var stateService: UpdateMobileStateServiceAPI!
    private let serviceProvider: MobileSettingsServiceAPI & SettingsServiceAPI
    private let disposeBag = DisposeBag()
    
    init(topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         navigationControllerAPI: NavigationControllerAPI?,
         service: MobileSettingsServiceAPI & SettingsServiceAPI = UserInformationServiceProvider.default.settings) {
        self.serviceProvider = service
        self.navigationControllerAPI = navigationControllerAPI
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }
    
    func start() {
        stateService = UpdateMobileRouterStateService()
        stateService.action
            .bind(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    func next(to state: UpdateMobileRouterStateService.State) {
        switch state {
        case .start:
            break
        case .end:
            navigationControllerAPI?.popToRootViewControllerAnimated(animated: true)
        case .mobileNumber:
            showUpdateMobileScreen()
        case .codeEntry:
            showCodeEntryScreen()
        }
    }
    
    func previous() {
        dismiss()
    }
    
    // MARK: - Private Functions
    
    func showUpdateMobileScreen() {
        let presenter = UpdateMobileScreenPresenter(stateService: stateService, settingsAPI: serviceProvider)
        let controller = UpdateMobileScreenViewController(presenter: presenter)
        present(viewController: controller)
    }
    
    func showCodeEntryScreen() {
        let presenter = MobileCodeEntryScreenPresenter(stateService: stateService, service: serviceProvider)
        let controller = MobileCodeEntryViewController(presenter: presenter)
        present(viewController: controller)
    }
}

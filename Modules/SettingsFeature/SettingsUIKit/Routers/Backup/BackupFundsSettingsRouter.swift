// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import SettingsKit

public final class BackupFundsSettingsRouter: BackupRouterAPI {
    
    // MARK: - BackupRouterAPI
    
    public let entry: BackupRouterEntry = .settings
    public let completionRelay = PublishRelay<Void>()
    
    private var stateService: BackupRouterStateService!
    private let navigationRouter: NavigationRouterAPI
    private let recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI
    private let disposeBag = DisposeBag()
    
    public init(navigationRouter: NavigationRouterAPI = resolve(),
         recoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI = resolve()) {
        self.navigationRouter = navigationRouter
        self.recoveryPhraseVerifyingService = recoveryPhraseVerifyingService
    }
    
    public func start() {
        stateService = BackupRouterStateService(entry: entry)
        stateService.action
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.previous()
                case .next(let state):
                    self.next(to: state)
                case .complete:
                    self.navigationRouter.navigationControllerAPI?.popToRootViewControllerAnimated(animated: true)
                    self.completionRelay.accept(())
                case .dismiss:
                    self.navigationRouter.navigationControllerAPI?.popToRootViewControllerAnimated(animated: true)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    public func next(to state: BackupRouterStateService.State) {
        switch state {
        case .start, .end:
            break
        case .backupFunds(let presentationType, let entry):
            showBackupFunds(presentationType: presentationType, entry: entry)
        case .recovery:
            let presenter = RecoveryPhraseScreenPresenter(
                stateService: stateService,
                recoveryPhraseVerifying: recoveryPhraseVerifyingService
            )
            let controller = RecoveryPhraseViewController(presenter: presenter)
            navigationRouter.navigationControllerAPI?.pushViewController(controller, animated: true)
        case .verification:
            let presenter = VerifyBackupScreenPresenter(
                stateService: stateService,
                service: recoveryPhraseVerifyingService
            )
            let controller = VerifyBackupViewController(presenter: presenter)
            navigationRouter.navigationControllerAPI?.pushViewController(controller, animated: true)
        }
    }
    
    public func previous() {
        navigationRouter.dismiss()
    }
    
    // MARK: - Private Functions
    
    private func showBackupFunds(presentationType: PresentationType, entry: BackupRouterEntry) {
        let presenter = BackupFundsScreenPresenter(stateService: stateService, entry: entry)
        let controller = DetailsScreenViewController(presenter: presenter)
        controller.isModalInPresentation = true
        navigationRouter.present(viewController: controller, using: presentationType)
    }
}


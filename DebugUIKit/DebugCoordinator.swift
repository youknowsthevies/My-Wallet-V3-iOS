//
//  DebugCoordinator.swift
//  DebugUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 23/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit
import UIKit

public enum DebugScreenContext: String, Hashable {
    case tag
}

public protocol DebugCoordinating {
    /// Enables the debug menu which can be activated by shaking the device
    func enableDebugMenu(for window: UIWindow?)

    /// Removes the debug menu from being presented
    func disableDebugMenu()
}

final class DebugCoordinator: NSObject, DebugCoordinating {

    private var disposeBag = DisposeBag()

    private var screenLifetimeBag = DisposeBag()
    private var navigationController: UINavigationController?

    private var isDisplayed = PublishRelay<Bool>()

    public func enableDebugMenu(for window: UIWindow?) {
        guard let window = window else { return }

        let motionEnded = window.rx.motionEnded
            .filter { $0 == .motionShake }
            .share()

        let isDisplayed = motionEnded
            .map(weak: self) { (self, _) -> Bool in
                self.navigationController == nil
            }
            .startWith(true)

        motionEnded
            .withLatestFrom(isDisplayed)
            .filter { $0 }
            .subscribe(onNext: { [weak self, window] _ in
                guard let self = self else { return }
                guard let topViewController = window.rootViewController?.topMostViewController else { return }
                self.showMenu(in: topViewController)
            })
            .disposed(by: disposeBag)
    }

    public func disableDebugMenu() {
        disposeBag = DisposeBag()
    }

    private func showMenu(in rootController: UIViewController) {
        let viewModel = DebugViewModel(itemsProvider: DebugItemType.provideAllItems)
        let debugViewController = DebugViewController(viewModel: viewModel)
        debugViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let navigationController = UINavigationController(rootViewController: debugViewController)
        navigationController.presentationController?.delegate = self
        self.navigationController = navigationController

        viewModel.routeTo
            .subscribe(onNext: { [weak self] effect in
                self?.handle(effect)
            })
            .disposed(by: screenLifetimeBag)

        rootController.present(navigationController, animated: true, completion: nil)
    }

    private func dismissDebugController() {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            self?.navigationController = nil
            self?.screenLifetimeBag = DisposeBag()
        })
    }

    private func handle(_ effect: DebugViewModel.Effects) {
        switch effect {
        case .route(let type):
            route(to: type)
        case .close:
            dismissDebugController()
        }
    }

    private func route(to type: DebugItemType) {
        switch type {
        case .interalFeatureFlags:
            let viewModel = InternalFeatureFlagViewModel()
            let viewController = InternalFeatureFlagViewController(viewModel: viewModel)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension DebugCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        navigationController = nil
        screenLifetimeBag = DisposeBag()
    }
}

#if DEBUG
/// Needed as we're capturing the shake motion on a window level
// swiftlint:disable all
extension UIWindow {
    open override var canBecomeFirstResponder: Bool {
        true
    }

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
    }
}
// swiftlint:enable all
#endif

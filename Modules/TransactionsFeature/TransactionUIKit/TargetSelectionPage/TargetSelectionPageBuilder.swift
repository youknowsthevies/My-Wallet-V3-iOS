//
//  TargetSelectionBuilder.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift

// MARK: - Listener Bridge

enum TargetSelectionListenerBridge {
    case simple(AccountPickerDidSelect)
    case listener(TargetSelectionPageListener)
}

// MARK: - Builder

typealias BackButtonInterceptor = () -> Observable<(step: TransactionStep, backStack: [TransactionStep], isGoingBack: Bool)>

protocol TargetSelectionBuildable {
    func build(listener: TargetSelectionListenerBridge,
               navigationModel: ScreenNavigationModel,
               backButtonInterceptor: @escaping BackButtonInterceptor) -> TargetSelectionPageRouting
}

final class TargetSelectionPageBuilder: TargetSelectionBuildable {

    // MARK: - Private Properties

    private let accountProvider: SourceAndTargetAccountProviding
    private let action: AssetAction

    // MARK: - Init

    public init(accountProvider: SourceAndTargetAccountProviding,
                action: AssetAction) {
        self.accountProvider = accountProvider
        self.action = action
    }

    // MARK: - Public Methods

    public func build(listener: TargetSelectionListenerBridge,
                      navigationModel: ScreenNavigationModel,
                      backButtonInterceptor: @escaping BackButtonInterceptor) -> TargetSelectionPageRouting {
        let shouldOverrideNavigationEffects: Bool
        switch listener {
        case .listener:
            shouldOverrideNavigationEffects = true
        case .simple:
            shouldOverrideNavigationEffects = false
        }
        let viewController = TargetSelectionViewController(
            shouldOverrideNavigationEffects: shouldOverrideNavigationEffects
        )
        let reducer = TargetSelectionPageReducer(action: action, navigationModel: navigationModel)
        let presenter = TargetSelectionPagePresenter(
            viewController: viewController,
            action: action,
            selectionPageReducer: reducer
        )
        let interactor = TargetSelectionPageInteractor(
            targetSelectionPageModel: .init(interactor: TargetSelectionInteractor()),
            presenter: presenter,
            accountProvider: accountProvider,
            listener: listener,
            action: action,
            backButtonInterceptor: backButtonInterceptor
        )
        return TargetSelectionPageRouter(interactor: interactor, viewController: viewController)
    }
}

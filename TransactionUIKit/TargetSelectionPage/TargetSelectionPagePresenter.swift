//
//  TargetSelectionPagePresenter.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa

protocol TargetSelectionPagePresentable: Presentable {
    // TODO: Adds correct input/output state
    func connect(state: Driver<Void>) -> Driver<Void>
}

final class TargetSelectionPagePresenter: Presenter<TargetSelectionPageViewControllable>, TargetSelectionPagePresentable {

    // MARK: - Private Properties

    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel
    private let headerModel: TargetSelectionHeaderType

    // MARK: - Init

    init(viewController: TargetSelectionPageViewControllable,
         action: AssetAction,
         navigationModel: ScreenNavigationModel,
         headerModel: TargetSelectionHeaderType) {
        self.action = action
        self.navigationModel = navigationModel
        self.headerModel = headerModel
        super.init(viewController: viewController)
    }

    // MARK: - Methods

    func connect(state: Driver<Void>) -> Driver<Void> {
        return .empty()
    }
}

extension TargetSelectionPagePresenter {
    struct State {
        var headerModel: TargetSelectionHeaderType
        var navigationModel: ScreenNavigationModel
        var sections: [TargetSelectionPageSectionModel]
    }
}

//
//  TargetSelectoionPageReducer.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 08/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

/// Types adopting this should be able to provide a stream of presentable state of type `TargetSelectionPagePresenter.State` which is used by `TargetSelectionPagePresentable` that presents the neccessary sections define in the state.
protocol TargetSelectionPageReducerAPI {
    /// Provides a stream of `TargetSelectionPagePresenter.State` from the given `TargetSelectionPageInteractor.State`
    /// - Parameter interactorState: A stream of `TargetSelectionPageInteractor.State` as defined by `TargetSelectionPageInteractor`
    func presentableState(for interactorState: Driver<TargetSelectionPageInteractor.State>) -> Driver<TargetSelectionPagePresenter.State>
}

final class TargetSelectionPageReducer: TargetSelectionPageReducerAPI {

    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel

    init(action: AssetAction,
         navigationModel: ScreenNavigationModel) {
        self.action = action
        self.navigationModel = navigationModel
    }

    func presentableState(for interactorState: Driver<TargetSelectionPageInteractor.State>) -> Driver<TargetSelectionPagePresenter.State> {
        let action = self.action
        let sourceSections = interactorState.map(\.sourceInteractors)
            .map { items -> [TargetSelectionPageCellItem] in
                items.map { interactor in
                    TargetSelectionPageCellItem(interactor: interactor, assetAction: action)
                }
            }
            .flatMap { [weak self] items -> Driver<TargetSelectionPageSectionModel> in
                guard let self = self else { return .empty() }
                return .just(.source(header: self.provideSourceSectionHeader(), items: items))
            }

        let destinationSections = interactorState.map(\.destinationInteractors)
            .map { items -> [TargetSelectionPageCellItem] in
                items.map { interactor in
                    TargetSelectionPageCellItem(interactor: interactor, assetAction: action)
                }
            }
            .flatMap { [weak self] items -> Driver<TargetSelectionPageSectionModel> in
                guard let self = self else { return .empty() }
                return .just(.destination(header: self.provideDestinationSectionHeader(), items: items))
            }

        let navigationModel = self.navigationModel
        return Driver.combineLatest(sourceSections, destinationSections)
            .map { [$0] + [$1] }
            .map { sections -> TargetSelectionPagePresenter.State in
                TargetSelectionPagePresenter.State(
                    actionButtonModel: .primary(with: LocalizationConstants.Transaction.next),
                    navigationModel: navigationModel,
                    sections: sections
                )
            }
    }

    // MARK: - Static methods

    private func provideSourceSectionHeader() -> TargetSelectionHeaderBuilder {
        TargetSelectionHeaderBuilder(
            headerType: .titledSection(
                .init(
                    title: LocalizationConstants.Transaction.Swap.newSwapDisclaimer,
                    sectionTitle: LocalizationConstants.Transaction.Swap.swap
                )
            )
        )
    }

    private func provideDestinationSectionHeader() -> TargetSelectionHeaderBuilder {
        TargetSelectionHeaderBuilder(
            headerType: .section(
                .init(
                    sectionTitle: LocalizationConstants.Transaction.receive
                )
            )
        )
    }
}

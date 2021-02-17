//
//  TargetSelectionPageInteractor.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

protocol TargetSelectionPageRouting: ViewableRouting {
}

protocol TargetSelectionPageListener: AnyObject {
    func didSelect(blockchainAccount: BlockchainAccount)
    func didTapBack()
    func didTapClose()
}

final class TargetSelectionPageInteractor: PresentableInteractor<TargetSelectionPagePresentable>,
                                           TargetSelectionPageInteractable {

    weak var router: TargetSelectionPageRouting?

    // MARK: - Private Properties

    private let targetSelectionService: TargetSelectionPageServiceAPI
    private let accountProvider: SourceAndTargetAccountProviding
    private let didSelect: AccountPickerDidSelect?
    weak var listener: TargetSelectionPageListener?

    // MARK: - Init

    init(presenter: TargetSelectionPagePresentable,
         targetSelectionService: TargetSelectionPageServiceAPI,
         accountProvider: SourceAndTargetAccountProviding,
         listener: TargetSelectionListenerBridge) {
        self.targetSelectionService = targetSelectionService
        self.accountProvider = accountProvider
        switch listener {
        case .simple(let didSelect):
            self.didSelect = didSelect
            self.listener = nil
        case .listener(let listener):
            self.didSelect = nil
            self.listener = listener
        }
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let interactorServiceState = targetSelectionService.state

        presenter.connect(state: interactorServiceState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)
    }

    // MARK: - Private methods

    private func handle(effects: Effects) {
        switch effects {
        case .select(let account):
            didSelect?(account)
            listener?.didSelect(blockchainAccount: account)
        case .back:
            listener?.didTapBack()
        case .closed:
            listener?.didTapClose()
        case .none:
            break
        }
    }
}

extension TargetSelectionPageInteractor {
    struct State {
        static let empty = State(sourceInteractors: [], destinationInteractors: [], actionButtonEnabled: false)
        let sourceInteractors: [TargetSelectionPageCellItem.Interactor]
        let destinationInteractors: [TargetSelectionPageCellItem.Interactor]
        var actionButtonEnabled: Bool
    }

    enum Effects {
        case select(BlockchainAccount)
        case back
        case closed
        case none
    }
}

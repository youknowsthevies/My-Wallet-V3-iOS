//
//  TargetSelectionPageInteractor.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs
import RxSwift

protocol TargetSelectionPageRouting: ViewableRouting {
}

protocol TargetSelectionPageListener: class {
}

final class TargetSelectionPageInteractor: PresentableInteractor<TargetSelectionPagePresentable>, TargetSelectionPageInteractable {

    weak var router: TargetSelectionPageRouting?
    weak var listener: TargetSelectionPageListener?

    override init(presenter: TargetSelectionPagePresentable) {
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
    }
}

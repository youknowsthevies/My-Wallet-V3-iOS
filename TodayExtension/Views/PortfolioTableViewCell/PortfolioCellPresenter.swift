//
//  PortfolioCellPresenter.swift
//  TodayExtension
//
//  Created by Alex McGregor on 7/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

final class PortfolioCellPresenter {
    
    let balanceContent: LabelContent
    let deltaContent: LabelContent
    
    init(interactor: PortfolioCellInteractor) {
        balanceContent = .init(
            text: interactor.balanceFiatValue.displayString,
            font: .systemFont(ofSize: 20.0, weight: .semibold),
            color: .white,
            alignment: .left,
            accessibility: .none
        )
        deltaContent = .init(
            text: interactor.changeFiatValue.displayString + interactor.delta,
            font: .systemFont(ofSize: 12.0, weight: .medium),
            color: interactor.isPositive ? .positivePrice : .negativePrice,
            alignment: .left,
            accessibility: .none
        )
    }
}

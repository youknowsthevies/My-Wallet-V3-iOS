//
//  TodayExtensionSectionHeaderViewModel.swift
//  TodayExtension
//
//  Created by Alex McGregor on 7/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit

struct TodayExtensionSectionHeaderViewModel {
    let titleLabelContent: LabelContent
    
    init(title: LabelContent) {
        self.titleLabelContent = title
    }
}

extension TodayExtensionSectionHeaderViewModel {
    static let walletBalance: TodayExtensionSectionHeaderViewModel = .init(
        title: LabelContent(
            text: LocalizationConstants.TodayExtension.Headers.balance.uppercased(),
            font: .systemFont(ofSize: 10.0, weight: .semibold),
            color: .descriptionText,
            alignment: .left,
            accessibility: .none
        )
    )
    
    static let prices: TodayExtensionSectionHeaderViewModel = .init(
        title: LabelContent(
            text: LocalizationConstants.TodayExtension.Headers.prices.uppercased(),
            font: .systemFont(ofSize: 10.0, weight: .semibold),
            color: .descriptionText,
            alignment: .left,
            accessibility: .none
        )
    )
}

//
//  YodleePendingContent.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 21/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa

struct YodleePendingContent: Equatable {
    let compositeViewType: CompositeStatusViewType
    let mainTitleContent: LabelContent
    let subtitleTextViewModel: InteractableTextViewModel
    let buttonContent: YodleeButtonsContent?

    var subtitleLinkTap: Signal<TitledLink> {
        subtitleTextViewModel.tap
            .asSignal(onErrorSignalWith: .empty())
    }
}

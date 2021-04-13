//
//  YodleeButtonsContent.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 21/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

struct YodleeButtonsContent: Equatable {
    let identifier: UUID
    let continueButtonViewModel: ButtonViewModel?
    let tryAgainButtonViewModel: ButtonViewModel?
    let cancelActionButtonViewModel: ButtonViewModel?

    var isCancelButtonHidden: Bool {
        cancelActionButtonViewModel == nil
    }

    var isTryAgainButtonHidden: Bool {
        tryAgainButtonViewModel == nil
    }

    var isContinueButtonHidden: Bool {
        continueButtonViewModel == nil
    }

    static func == (lhs: YodleeButtonsContent, rhs: YodleeButtonsContent) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

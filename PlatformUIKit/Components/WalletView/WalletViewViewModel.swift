//
//  WalletViewViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 2/22/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift

final class WalletViewViewModel {
    
    var identifier: String {
        nameLabelContent.text
    }
    
    let badgeImageViewModel: BadgeImageViewModel
    let nameLabelContent: LabelContent
    let balanceLabelContent: Driver<LabelContent>
    
    init(account: SingleAccount) {
        badgeImageViewModel = .default(
            with: account.currencyType.logoImageName,
            cornerRadius: .round,
            accessibilityIdSuffix: ""
        )
        badgeImageViewModel.marginOffsetRelay.accept(0.0)
        
        balanceLabelContent = account
                    .balance
                    .map(\.displayString)
                    .map { value in
                        .init(
                            text: value,
                            font: .main(.medium, 14.0),
                            color: .descriptionText,
                            alignment: .left,
                            accessibility: .none
                        )
                    }
                    .asDriver(onErrorJustReturn: .empty)
        
        nameLabelContent = .init(
            text: account.label,
            font: .main(.semibold, 16.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .none
        )
    }
}

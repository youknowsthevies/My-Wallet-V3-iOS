//
//  RadioSelectionCellPresenter.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 2/19/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxDataSources
import RxSwift

public final class RadioAccountCellPresenter: IdentifiableType {
    
    // MARK: - Public Properties
    
    /// The image corresponding to `imageName`
    public let image: Driver<UIImage?>
    
    // MARK: - RxDataSources
    
    public let identity: AnyHashable
    
    // MARK: - Internal
    
    /// The `viewModel` for the `WalletView`
    let viewModel: Driver<WalletViewViewModel>
    
    /// Selection relay
    let selectedRelay = PublishRelay<Bool>()

    /// Name for radio image
    let imageName = BehaviorRelay<String?>(value: nil)
    
    // MARK: - Init
    
    public init(account: SingleAccount, selected: Bool = false) {
        let model: WalletViewViewModel = .init(account: account)
        viewModel = .just(model)
        identity = model.identifier + (selected ? "_selected" : "_unselected")
        image = selectedRelay.asObservable()
            .startWith(selected)
            .map { $0 ? "checkbox-selected" : "checkbox-empty" }
            .asDriver(onErrorJustReturn: nil)
            .map { name in
                if let name = name {
                    return UIImage(named: name, in: .platformUIKit, compatibleWith: nil)
                }
                return nil
            }
    }
}

extension RadioAccountCellPresenter: Equatable {
    public static func == (lhs: RadioAccountCellPresenter, rhs: RadioAccountCellPresenter) -> Bool {
        lhs.identity == rhs.identity
    }
}

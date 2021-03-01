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

public final class RadioSelectionCellPresenter {
    
    enum Content {
        /// Shows a `WalletView` - A view with a `BadgeImageView`,
        /// the name of the wallet, and its balance in crypto.
        case wallet(WalletViewViewModel)
        
        var identifier: String {
            switch self {
            case .wallet(let viewModel):
                return viewModel.identifier
            }
        }
    }
    
    let content: Content
    
    /// Selection relay
    let selectedRelay = PublishRelay<Bool>()
    
    /// Name for radio image
    let imageName = BehaviorRelay<String?>(value: nil)
    
    /// The image corresponding to `imageName`
    public let image: Driver<UIImage?>
    
    public init(account: SingleAccount, selected: Bool = false) {
        content = .wallet(.init(account: account))
        image = Observable
            .merge(selectedRelay.asObservable(), Observable.just(selected))
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

extension RadioSelectionCellPresenter: IdentifiableType, Equatable {

    public var identity: AnyHashable {
        content.identifier
    }
    
    public static func == (lhs: RadioSelectionCellPresenter, rhs: RadioSelectionCellPresenter) -> Bool {
        switch (lhs.content, rhs.content) {
        case (.wallet(let left), .wallet(let right)):
            return left.identifier == right.identifier
        default:
            return false
        }
    }
}

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
    
    /// Streams the image content 
    public let imageContent: Driver<ImageViewContent>
    
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
    
    public init(account: SingleAccount, selected: Bool = false, accessibilityPrefix: String = "") {
        let model = WalletViewViewModel(
            account: account,
            descriptor: .init(
                accessibilityPrefix: accessibilityPrefix
            )
        )
        viewModel = .just(model)
        identity = model.identifier + (selected ? "_selected" : "_unselected")
        imageContent = selectedRelay.asObservable()
            .startWith(selected)
            .map { $0 ? "checkbox-selected" : "checkbox-empty" }
            .asDriver(onErrorJustReturn: nil)
            .compactMap { name -> ImageViewContent? in
                guard let name = name else {
                    return nil
                }
                return ImageViewContent(
                    imageName: name,
                    accessibility: .init(id: .value("\(accessibilityPrefix).\(name)")),
                    renderingMode: .normal,
                    bundle: .platformUIKit)
            }
    }
}

extension RadioAccountCellPresenter: Equatable {
    public static func == (lhs: RadioAccountCellPresenter, rhs: RadioAccountCellPresenter) -> Bool {
        lhs.identity == rhs.identity
    }
}

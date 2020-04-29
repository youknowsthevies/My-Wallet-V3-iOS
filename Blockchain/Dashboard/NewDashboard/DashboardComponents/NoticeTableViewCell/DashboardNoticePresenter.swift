//
//  DashboardNoticePresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import PlatformUIKit

final class DashboardNoticePresenter {
    
    /// MARK: - Exposed Properties
    
    /// Streams only distinct actions
    var action: Driver<NoticeDisplayAction> {
        actionRelay
            .asDriver()
            .distinctUntilChanged()
    }
    
    /// MARK: - Private Properties
    
    let actionRelay = BehaviorRelay<NoticeDisplayAction>(value: .hide)
    
    private let interactor: DashboardNoticeInteractor
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: DashboardNoticeInteractor) {
        self.interactor = interactor
    }
    
    func refresh() {
        interactor.lockbox
            .subscribe(onSuccess: { [weak self] shouldDisplay in
                if shouldDisplay {
                    self?.displayLockboxNotice()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func displayLockboxNotice() {
        typealias LocalizedString = LocalizationConstants.Dashboard.Balance
        typealias AccessibilityId = Accessibility.Identifier.Dashboard.Notice
        let viewModel = NoticeViewModel(
            imageViewContent: .init(
                imageName: "lockbox-icon",
                accessibility: .id(AccessibilityId.imageView),
                bundle: .platformUIKit
            ),
            labelContent: .init(
                text: LocalizedString.lockboxNotice,
                font: .main(.medium, 12),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.label)
            ),
            verticalAlignment: .top
        )
        actionRelay.accept(.show(viewModel))
    }
}

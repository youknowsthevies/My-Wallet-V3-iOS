// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class DashboardNoticePresenter {

    // MARK: - Exposed Properties

    /// Streams only distinct actions
    var action: Driver<DashboardItemDisplayAction<NoticeViewModel>> {
        actionRelay
            .asDriver()
            .distinctUntilChanged()
    }

    // MARK: - Private Properties

    let actionRelay = BehaviorRelay<DashboardItemDisplayAction<NoticeViewModel>>(value: .hide)

    private let interactor: DashboardNoticeInteractor
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(interactor: DashboardNoticeInteractor = .init()) {
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
            labelContents: .init(
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

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class SecureChannelResultPresenter: RibBridgePresenter, PendingStatePresenterAPI {

    let pendingStatusViewMainContainerViewRatio: CGFloat = 1
    let pendingStatusViewSideContainerRatio: CGFloat = 0.55
    let pendingStatusViewEdgeSize: CGFloat = 72
    var viewModel: Driver<PendingStateViewModel> {
        Driver.just(model)
    }

    private let model: PendingStateViewModel
    private let disposeBag = DisposeBag()

    init(state: State, dismiss: @escaping () -> Void) {
        model = state.viewModel
        model.button?.tapRelay
            .subscribe(onNext: { _ in
                dismiss()
            })
            .disposed(by: disposeBag)
        super.init(interactable: Interactor())
    }
}

extension SecureChannelResultPresenter {

    enum State {
        private typealias LocalizedString = LocalizationConstants.SecureChannel.ResultSheet

        case approved
        case denied
        case error

        var title: String {
            switch self {
            case .approved:
                return LocalizedString.Approved.title
            case .denied:
                return LocalizedString.Denied.title
            case .error:
                return LocalizedString.Error.title
            }
        }

        var subtitle: String {
            switch self {
            case .approved:
                return LocalizedString.Approved.subtitle
            case .denied:
                return LocalizedString.Denied.subtitle
            case .error:
                return LocalizedString.Error.subtitle
            }
        }

        var sideImage: String {
            switch self {
            case .approved:
                return PendingStateViewModel.Image.success.name
            case .denied, .error:
                return "Icon-Close-Circle-Red"
            }
        }

        var viewModel: PendingStateViewModel {
            PendingStateViewModel(
                compositeStatusViewType: .composite(
                    .init(
                        baseViewType: .image("icon-laptop"),
                        sideViewAttributes: .init(type: .image(sideImage), position: .rightCorner)
                    )
                ),
                title: title,
                subtitle: subtitle,
                button: ButtonViewModel.primary(with: LocalizedString.CTA.ok)
            )
        }
    }
}

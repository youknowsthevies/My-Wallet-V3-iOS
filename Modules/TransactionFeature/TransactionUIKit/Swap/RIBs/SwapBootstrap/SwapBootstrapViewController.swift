// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RIBs
import RxSwift

final class SwapBootstrapViewController: UIViewController, SwapBootstrapPresentable, SwapBootstrapViewControllable {

    func showLoading() {
        LoadingViewPresenter.shared.show(in: view, with: nil)
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift

protocol BuyFlowRouting: Routing {

    func start(from presenter: UIViewController)
}

final class BuyFlowRouter: RIBs.Router<BuyFlowInteractor>, BuyFlowRouting {

    func start(from presenter: UIViewController) {
        // TODO: IOS-4879 Present Enter Amount Screen
        let viewController = UIViewController()
        viewController.view.backgroundColor = .red
        presenter.present(viewController, animated: true)
    }
}

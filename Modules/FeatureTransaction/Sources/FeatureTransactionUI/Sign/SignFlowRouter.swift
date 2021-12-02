// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RIBs
import UIKit

protocol SignFlowRouting: Routing {
    func start(
        sourceAccount: CryptoAccount,
        destination: TransactionTarget,
        presenter: UIViewController
    )
}

final class SignFlowRouter: RIBs.Router<SignFlowInteractor>, SignFlowRouting {

    override init(interactor: SignFlowInteractor) {
        super.init(interactor: interactor)
    }

    func start(
        sourceAccount: CryptoAccount,
        destination: TransactionTarget,
        presenter: UIViewController
    ) {
        let builder = TransactionFlowBuilder()
        let router = builder.build(
            withListener: interactor,
            action: .sign,
            sourceAccount: sourceAccount,
            target: destination
        )
        attachChild(router)
        let viewController = router.viewControllable.uiviewController
        presenter.present(viewController, animated: true)
    }
}

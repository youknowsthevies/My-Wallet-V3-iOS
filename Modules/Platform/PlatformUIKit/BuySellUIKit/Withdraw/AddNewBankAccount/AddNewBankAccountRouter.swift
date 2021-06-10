// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

public protocol AddNewBankAccountInteractable: Interactable {
    var router: AddNewBankAccountRouting? { get set }
    var listener: AddNewBankAccountListener? { get set }
}

public protocol AddNewBankAccountViewControllable: ViewControllable { }

public final class AddNewBankAccountRouter: ViewableRouter<AddNewBankAccountInteractable, AddNewBankAccountViewControllable>,
                                     AddNewBankAccountRouting {

    public override init(interactor: AddNewBankAccountInteractable,
                         viewController: AddNewBankAccountViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    public override func didLoad() {
        super.didLoad()
    }

    public func showTermsScreen(link: TitledLink) {
        let webRouter = WebViewRouter(topMostViewControllerProvider: viewController.uiviewController)
        webRouter.launchRelay.accept(link)
    }
}

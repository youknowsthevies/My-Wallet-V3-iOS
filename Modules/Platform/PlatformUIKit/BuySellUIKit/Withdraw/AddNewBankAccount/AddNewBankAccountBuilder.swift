// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import UIKit

protocol AddNewBankAccountBuildable {
    func build(listener: AddNewBankAccountListener) -> AddNewBankAccountRouter
}

final class AddNewBankAccountBuilder: AddNewBankAccountBuildable {

    private let currency: FiatCurrency
    private let isOriginDeposit: Bool

    /// Initializes a new instance of `AddNewBankAccountBuilder`
    ///
    /// - Parameters:
    ///     - currency: A value of `FiatCurrency` for the relevant information of the screen
    ///     - isOriginDeposit: Alters the navigation title of the screen.
    ///      Set `true` if you require the title of the screen to display "_Deposit [Currency]_"
    ///      otherwise the title will display "_Add a [Currency] Bank_"
    init(currency: FiatCurrency, isOriginDeposit: Bool) {
        self.currency = currency
        self.isOriginDeposit = isOriginDeposit
    }

    func build(listener: AddNewBankAccountListener) -> AddNewBankAccountRouter {
        let presenter = AddNewBankAccountPagePresenter(isOriginDeposit: isOriginDeposit,
                                                       fiatCurrency: currency)
        let viewController = DetailsScreenViewController(presenter: presenter)

        let interactor = AddNewBankAccountInteractor(presenter: presenter,
                                                     fiatCurrency: currency)
        interactor.listener = listener
        return AddNewBankAccountRouter(interactor: interactor,
                                       viewController: viewController)
    }
}

/// Conforming to AddNewBankAccountViewControllable for RIB compatibility
extension DetailsScreenViewController: AddNewBankAccountViewControllable { }

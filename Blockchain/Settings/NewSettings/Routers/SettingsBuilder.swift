//
//  SettingsBuilder.swift
//  Blockchain
//
//  Created by Daniel on 30/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit

protocol SettingsBuilding: AnyObject {
    func removeCardPaymentMethodViewController(cardData: CardData) -> UIViewController
    func removeBankPaymentMethodViewController(beneficiary: Beneficiary) -> UIViewController
}

final class SettingsBuilder: SettingsBuilding {
    
    /// Generate remove card payment method view controller
    /// - Parameter cardData: CC data
    /// - Returns: The view controller
    func removeCardPaymentMethodViewController(cardData: CardData) -> UIViewController {
        let data = PaymentMethodRemovalData(cardData: cardData)
        return removePaymentMethodViewController(
            buttonLocalizedString: LocalizationConstants.Settings.Card.remove,
            removalData: data
        )
    }
    
    /// Generate remove bank payment method view controller
    /// - Parameter cardData: Bank data
    /// - Returns: The view controller
    func removeBankPaymentMethodViewController(beneficiary: Beneficiary) -> UIViewController {
        let data = PaymentMethodRemovalData(beneficiary: beneficiary)
        return removePaymentMethodViewController(
            buttonLocalizedString: LocalizationConstants.Settings.Bank.remove,
            removalData: data
        )
    }
    
    private func removePaymentMethodViewController(buttonLocalizedString: String,
                                                   removalData: PaymentMethodRemovalData,
                                                   deletionService: PaymentMethodDeletionServiceAPI = resolve()) -> UIViewController {
        let interactor = RemovePaymentMethodScreenInteractor(
            data: removalData,
            deletionService: deletionService
        )
        let presenter = RemovePaymentMethodScreenPresenter(
            buttonLocalizedString: buttonLocalizedString,
            interactor: interactor
        )
        let viewController = RemovePaymentMethodViewController(presenter: presenter)
        return viewController
    }
}

//
//  LinkBankSplashScreenBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 10/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import RIBs

// MARK: - Builder

protocol LinkBankSplashScreenBuildable {
    func build(withListener listener: LinkBankSplashScreenListener, data: BankLinkageData) -> LinkBankSplashScreenRouting
}

final class LinkBankSplashScreenBuilder: LinkBankSplashScreenBuildable {

    func build(withListener listener: LinkBankSplashScreenListener, data: BankLinkageData) -> LinkBankSplashScreenRouting {
        let viewController = LinkBankSplashScreenViewController()
        let contentReducer = LinkBankSplashScreenContentReducer()
        let interactor = LinkBankSplashScreenInteractor(presenter: viewController,
                                                        bankLinkageData: data,
                                                        contentReducer: contentReducer)
        interactor.listener = listener
        return LinkBankSplashScreenRouter(interactor: interactor, viewController: viewController)
    }
}

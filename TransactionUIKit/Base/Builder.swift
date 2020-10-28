//
//  Builder.swift
//  TransactionUIKit
//
//  Created by Paulo on 15/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import UIKit

public final class Builder {
    private typealias LocalizedSend = LocalizationConstants.Send
    private typealias LocalizedReceive = LocalizationConstants.Receive

    private let sendSelectionService: AccountSelectionServiceAPI
    private let receiveSelectionService: AccountSelectionServiceAPI

    init(sendSelectionService: AccountSelectionServiceAPI,
         receiveSelectionService: AccountSelectionServiceAPI) {
        self.sendSelectionService = sendSelectionService
        self.receiveSelectionService = receiveSelectionService
    }

    public func receive() -> UIViewController {
        let header = AccountPickerHeaderModel(
            title: LocalizedReceive.Header.receiveCryptoNow,
            subtitle: LocalizedReceive.Header.chooseAWalletToReceiveTo,
            image: ImageAsset.iconReceive.image
        )
        let navigation = ScreenNavigationModel(
            leadingButton: .drawer,
            trailingButton: .none,
            titleViewStyle: .text(value: LocalizedReceive.Text.request),
            barStyle: .lightContent()
        )
        let interactor = AccountPickerScreenInteractor(
            singleAccountsOnly: true,
            action: .receive,
            selectionService: receiveSelectionService
        )
        let presenter = AccountPickerScreenPresenter(
            interactor: interactor,
            headerModel: .default(header),
            navigationModel: navigation
        )
        return AccountPickerScreenModalViewController(presenter: presenter)
    }

    public func send() -> UIViewController {
        let header = AccountPickerHeaderModel(
            title: LocalizedSend.Header.sendCryptoNow,
            subtitle: LocalizedSend.Header.chooseAWalletToSendFrom,
            image: ImageAsset.iconSend.image
        )
        let navigation = ScreenNavigationModel(
            leadingButton: .drawer,
            trailingButton: .none,
            titleViewStyle: .text(value: LocalizedSend.Text.send),
            barStyle: .lightContent()
        )
        let interactor = AccountPickerScreenInteractor(
            singleAccountsOnly: true,
            action: .send,
            selectionService: sendSelectionService
        )
        let presenter = AccountPickerScreenPresenter(
            interactor: interactor,
            headerModel: .default(header),
            navigationModel: navigation
        )
        return AccountPickerScreenModalViewController(presenter: presenter)
    }
}

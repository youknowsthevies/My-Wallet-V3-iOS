// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import ToolKit
import UIComponentsKit
import UIKit

public final class ReceiveBuilder {
    private typealias LocalizedReceive = LocalizationConstants.Receive

    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let receiveSelectionService: AccountSelectionServiceAPI

    init(
        internalFeatureFlagService: InternalFeatureFlagServiceAPI,
        receiveSelectionService: AccountSelectionServiceAPI
    ) {
        self.internalFeatureFlagService = internalFeatureFlagService
        self.receiveSelectionService = receiveSelectionService
    }

    var receiveAccountPickerRouter: AccountPickerRouting!

    public func receive() -> UIViewController {
        let searchable = StaticFeatureFlags.isDynamicAssetsEnabled
        let header = AccountPickerHeaderModel(
            imageContent: .init(
                imageResource: ImageAsset.iconReceive.imageResource,
                accessibility: .none,
                renderingMode: .normal
            ),
            searchable: searchable,
            subtitle: LocalizedReceive.Header.chooseWalletToReceive,
            title: LocalizedReceive.Header.receiveCryptoNow
        )
        let navigationModel = ScreenNavigationModel(
            leadingButton: .drawer,
            trailingButton: .none,
            titleViewStyle: .text(value: LocalizedReceive.Text.request),
            barStyle: .lightContent()
        )
        let builder = AccountPickerBuilder(
            accountProvider: ReceiveAccountProvider(),
            action: .receive
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            self?.receiveSelectionService.record(selection: account)
        }
        receiveAccountPickerRouter = builder.build(
            listener: .simple(didSelect),
            navigationModel: navigationModel,
            headerModel: .default(header)
        )
        receiveAccountPickerRouter.interactable.activate()
        receiveAccountPickerRouter.load()
        return receiveAccountPickerRouter.viewControllable.uiviewController
    }
}

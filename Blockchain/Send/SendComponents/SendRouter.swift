//
//  SendRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 09/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

/// Router for the send flow
final class SendRouter {

    private weak var baseViewController: UIViewController?
    private let asset: CryptoCurrency

    init(asset: CryptoCurrency) {
        precondition(asset == .ethereum, "Only Ethereum is supported.")
        self.asset = asset
    }

    func presentQRScan(using builder: QRCodeScannerViewControllerBuilder<AddressQRCodeParser>) {
        guard let viewController = builder.build() else { return }
        baseViewController?.present(viewController, animated: true, completion: nil)
    }

    func sendViewController() -> SendViewController {
        let services = SendServiceContainer(asset: asset)
        let interactor = SendInteractor(services: services)
        let presenter = SendPresenter(router: self, interactor: interactor)
        let viewController = SendViewController(presenter: presenter)
        baseViewController = viewController
        return viewController
    }
}

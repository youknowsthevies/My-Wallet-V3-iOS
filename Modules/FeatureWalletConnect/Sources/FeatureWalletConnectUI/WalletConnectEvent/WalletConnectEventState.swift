// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization
import UIComponentsKit
import UIKit
import WalletConnectSwift

public struct WalletConnectEventState: Equatable {
    enum ConnectionState: Equatable {
        case idle
        case success
        case fail
    }

    let state: ConnectionState
    let imageResource: ImageResource?
    let title: String
    var subtitle: String?
    let primaryButtonTitle: String
    var secondaryButtonTitle: String?
    let primaryAction: WalletConnectEventAction
    var secondaryAction: WalletConnectEventAction?
    var decorationImage: UIImage?

    init(meta: Session.ClientMeta, state: ConnectionState) {
        self.state = state
        if let url = meta.icons.first {
            imageResource = .remote(url: url)
        } else {
            imageResource = nil
        }

        switch state {
        case .idle:
            title = String(format: LocalizationConstants.WalletConnect.dAppWantsToConnect, meta.name)
            subtitle = meta.url.absoluteString
            secondaryButtonTitle = LocalizationConstants.cancel
            primaryButtonTitle = LocalizationConstants.WalletConnect.confirm
            primaryAction = .accept
            secondaryAction = .close
        case .fail:
            title = String(format: LocalizationConstants.WalletConnect.dAppConnectionFail, meta.name)
            subtitle = LocalizationConstants.WalletConnect.dAppConnectionFailMessage
            primaryButtonTitle = LocalizationConstants.okString
            primaryAction = .close
            decorationImage = UIImage(named: "fail-decorator", in: .featureWalletConnectUI, with: nil)!
        case .success:
            title = String(format: LocalizationConstants.WalletConnect.dAppConnectionSuccess, meta.name)
            primaryButtonTitle = LocalizationConstants.okString
            primaryAction = .close
            decorationImage = UIImage(named: "success-decorator", in: .featureWalletConnectUI, with: nil)!
        }
    }
}

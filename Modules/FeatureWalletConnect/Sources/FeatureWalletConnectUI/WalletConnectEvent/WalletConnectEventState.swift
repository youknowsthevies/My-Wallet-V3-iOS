// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import FeatureWalletConnectDomain
import Foundation
import Localization
import SwiftUI
import UIComponentsKit
import WalletConnectSwift

public struct WalletConnectEventState: Equatable {

    private typealias LocalizedString = LocalizationConstants.WalletConnect

    enum ConnectionState: Equatable {
        case idle
        case success
        case fail
        case details
        case chainID(name: String)
    }

    let session: Session
    let state: ConnectionState
    let imageResource: ImageResource?
    let title: String
    var subtitle: String?
    var primaryButtonTitle: String?
    var secondaryButtonTitle: String?
    var primaryAction: WalletConnectEventAction?
    var secondaryAction: WalletConnectEventAction?
    var decorationImage: UIImage?
    var secondaryButtonColor: Color = .buttonSecondaryText

    init(session: Session, state: ConnectionState) {
        self.state = state
        self.session = session

        let meta = session.dAppInfo.peerMeta

        if let url = meta.icons.first {
            imageResource = .remote(url: url)
        } else {
            imageResource = nil
        }

        switch state {
        case .idle:
            title = String(format: LocalizedString.Connection.dAppWantsToConnect, meta.name)
            subtitle = meta.url.host
            secondaryButtonTitle = LocalizedString.cancel
            primaryButtonTitle = LocalizedString.confirm
            primaryAction = .accept
            secondaryAction = .close
        case .fail:
            title = String(format: LocalizedString.Connection.dAppConnectionFail, meta.name)
            subtitle = LocalizedString.Connection.dAppConnectionFailMessage
            primaryButtonTitle = LocalizedString.ok
            primaryAction = .close
            decorationImage = UIImage(named: "fail-decorator", in: .featureWalletConnectUI, with: nil)!
        case .success:
            title = String(format: LocalizedString.Connection.dAppConnectionSuccess, meta.name)
            primaryButtonTitle = LocalizedString.ok
            primaryAction = .close
            decorationImage = UIImage(named: "success-decorator", in: .featureWalletConnectUI, with: nil)!
        case .details:
            title = meta.name
            subtitle = meta.description
            secondaryButtonTitle = LocalizedString.List.disconnect
            secondaryAction = .disconnect
            secondaryButtonColor = .textError
        case .chainID(let name):
            title = LocalizedString.ChangeChain.title(dAppName: meta.name, networkName: name)
            subtitle = meta.url.host
            primaryButtonTitle = LocalizedString.confirm
            primaryAction = .accept
            secondaryButtonTitle = LocalizedString.cancel
            secondaryAction = .close
        }
    }

    func analyticsEvent(for action: WalletConnectEventAction) -> AnalyticsEvent? {
        switch (state, action) {
        case (.idle, .accept):
            return AnalyticsEvents
                .New
                .WalletConnect
                .dappConnectionActioned(
                    action: .confirm,
                    appName: session.dAppInfo.peerMeta.name
                )
        case (.idle, .close):
            return AnalyticsEvents
                .New
                .WalletConnect
                .dappConnectionActioned(
                    action: .cancel,
                    appName: session.dAppInfo.peerMeta.name
                )
        case (.idle, _):
            return nil
        case (.fail, _):
            return AnalyticsEvents
                .New
                .WalletConnect
                .dappConnectionRejected(appName: session.dAppInfo.peerMeta.name)
        case (.success, _):
            return AnalyticsEvents
                .New
                .WalletConnect
                .dappConnectionConfirmed(appName: session.dAppInfo.peerMeta.name)
        case (.details, .disconnect):
            return AnalyticsEvents
                .New
                .WalletConnect
                .connectedDappActioned(
                    action: .disconnect,
                    appName: session.dAppInfo.peerMeta.name,
                    origin: .appsList
                )
        case (.details, .openWebsite):
            return AnalyticsEvents
                .New
                .WalletConnect
                .connectedDappActioned(
                    action: .launch,
                    appName: session.dAppInfo.peerMeta.name,
                    origin: .appsList
                )
        case (.details, _):
            return nil
        case (.chainID, _):
            return nil
        }
    }
}

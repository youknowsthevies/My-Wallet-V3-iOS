import AnalyticsKit
@_exported import BlockchainNamespace
import DIKit
import ErrorsUI
import FeatureAppUI
import FeatureAttributionDomain
import FeatureCoinUI
import Firebase
import FirebaseProtocol
import ToolKit
import UIKit

let app: AppProtocol = App(
    remoteConfiguration: Session.RemoteConfiguration(
        remote: FirebaseRemoteConfig.RemoteConfig.remoteConfig(),
        default: [
            blockchain.app.configuration.tabs: blockchain.app.configuration.tabs.json(in: .main),
            blockchain.app.configuration.frequent.action: blockchain.app.configuration.frequent.action.json(in: .main),
            blockchain.app.configuration.request.console.logging: false,
            blockchain.app.configuration.manual.login.is.enabled: BuildFlag.isInternal,
            blockchain.app.configuration.SSL.pinning.is.enabled: true,
            blockchain.app.configuration.unified.sign_in.is.enabled: false,
            blockchain.app.configuration.native.wallet.payload.is.enabled: false,
            blockchain.app.configuration.native.bitcoin.transaction.is.enabled: false,
            blockchain.app.configuration.apple.pay.is.enabled: false,
            blockchain.app.configuration.card.issuing.is.enabled: false,
            blockchain.app.configuration.redesign.checkout.is.enabled: false,
            blockchain.app.configuration.customer.support.is.enabled: BuildFlag.isAlpha
        ]
    )
)

extension FirebaseRemoteConfig.RemoteConfig: RemoteConfiguration_p {}
extension FirebaseRemoteConfig.RemoteConfigValue: RemoteConfigurationValue_p {}
extension FirebaseRemoteConfig.RemoteConfigFetchStatus: RemoteConfigurationFetchStatus_p {}
extension FirebaseRemoteConfig.RemoteConfigSource: RemoteConfigurationSource_p {}

extension AppProtocol {

    func bootstrap(
        analytics recorder: AnalyticsEventRecorderAPI = resolve(),
        deepLink: DeepLinkCoordinator = resolve(),
        attributionService: AttributionServiceAPI = resolve()
    ) {
        observers.insert(CoinViewAnalyticsObserver(app: self, analytics: recorder))
        observers.insert(CoinViewObserver(app: self))
        observers.insert(AttributionAppObserver(app: self, attributionService: attributionService))
        observers.insert(deepLink)
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        observers.insert(PulseBlockchainNamespaceEventLogger(app: self))
        #endif
        observers.insert(ErrorActionObserver(app: self, application: UIApplication.shared))
        observers.insert(RootViewAnalyticsObserver(self, analytics: recorder))

        Task {
            let result = try await Installations.installations().authTokenForcingRefresh(true)
            state.transaction { state in
                state.set(blockchain.user.token.firebase.installation, to: result.authToken)
            }
        }
    }
}

extension Tag.Event {

    fileprivate func json(in bundle: Bundle) -> Any? {
        guard let path = Bundle.main.path(forResource: description, ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    }
}

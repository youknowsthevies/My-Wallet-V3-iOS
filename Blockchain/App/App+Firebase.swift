import AnalyticsKit
@_exported import BlockchainNamespace
import DIKit
import FeatureAppUI
import FeatureCoinUI
import FeatureNotificationSettingsDomain
import Firebase
import FirebaseProtocol

let app: AppProtocol = App(
    remote: FirebaseRemoteConfig.RemoteConfig.remoteConfig()
)

extension FirebaseRemoteConfig.RemoteConfig: RemoteConfiguration_p {}
extension FirebaseRemoteConfig.RemoteConfigValue: RemoteConfigurationValue_p {}
extension FirebaseRemoteConfig.RemoteConfigFetchStatus: RemoteConfigurationFetchStatus_p {}
extension FirebaseRemoteConfig.RemoteConfigSource: RemoteConfigurationSource_p {}

extension AppProtocol {
    func bootstrap(analytics recorder: AnalyticsEventRecorderAPI = resolve()) {
        observers.insert(CoinViewAnalytics(app: self, analytics: recorder))
        observers.insert(FirebaseAnalytics(app: self, analytics: recorder))
        observers.insert(CoinViewObserver(app: self))
        observers.insert(NotificationLanguageObserver(app: self))
        observers.insert(resolve() as DeepLinkCoordinator)
        #if DEBUG || ALPHA_BUILD || INTERNAL_BUILD
        observers.insert(PulseBlockchainNamespaceEventLogger(app: self))
        #endif
    }
}

@_exported import BlockchainNamespace
import Firebase
import FirebaseProtocol

let app: AppProtocol = App(
    remote: FirebaseRemoteConfig.RemoteConfig.remoteConfig()
)

extension FirebaseRemoteConfig.RemoteConfig: RemoteConfiguration_p {}
extension FirebaseRemoteConfig.RemoteConfigValue: RemoteConfigurationValue_p {}
extension FirebaseRemoteConfig.RemoteConfigFetchStatus: RemoteConfigurationFetchStatus_p {}
extension FirebaseRemoteConfig.RemoteConfigSource: RemoteConfigurationSource_p {}

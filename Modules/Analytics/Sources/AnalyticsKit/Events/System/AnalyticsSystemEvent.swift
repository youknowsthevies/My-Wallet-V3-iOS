// Copyright © Blockchain Luxembourg S.A. All rights reserved.
// swiftlint:disable line_length

import Combine
import Foundation
import UIKit

enum SystemEvent: AnalyticsEvent {

    case applicationBackgrounded
    case applicationCrashed
    case applicationInstalled(ApplicationSystemEventParamaters)
    case applicationOpened(ApplicationOpenedSystemEventParamaters)
    case applicationUpdated(ApplicationUpdatedSystemEventParamaters)

    case pushNotificationReceived(ApplicationPushNotificationParamaters)
    case pushNotificationTapped(ApplicationPushNotificationParamaters)
}

extension SystemEvent {

    var type: AnalyticsEventType { .nabu }

    static var applicationInstalled: SystemEvent {
        .applicationInstalled(.init())
    }

    static func applicationOpened(_ notification: Notification) -> SystemEvent {
        .applicationOpened(.init(notification: notification))
    }

    static var applicationUpdated: SystemEvent {
        .applicationUpdated(.init())
    }
}

private var systemEventAnalytics: SystemEventAnalytics?

extension SystemEventAnalytics {

    public static func start(
        notificationCenter: NotificationCenter = .default,
        userDefaults: UserDefaults = .standard,
        recordingOn recorder: AnalyticsEventRecorderAPI,
        didCrashOnPreviousExecution: @escaping () -> Bool
    ) {
        systemEventAnalytics = SystemEventAnalytics(
            notificationCenter: notificationCenter,
            userDefaults: userDefaults,
            recordingOn: recorder,
            didCrashOnPreviousExecution: didCrashOnPreviousExecution
        )
    }
}

public class SystemEventAnalytics {

    let app = App()
    let userDefaults: UserDefaults
    let didCrashOnPreviousExecution: () -> Bool

    var bundle: Bundle = .main
    var bag: Set<AnyCancellable> = []

    public init(
        notificationCenter: NotificationCenter = .default,
        userDefaults: UserDefaults = .standard,
        recordingOn recorder: AnalyticsEventRecorderAPI,
        didCrashOnPreviousExecution: @escaping () -> Bool
    ) {

        self.userDefaults = userDefaults
        self.didCrashOnPreviousExecution = didCrashOnPreviousExecution

        if userDefaults.string(forKey: ApplicationUpdatedSystemEventParamaters.installedVersion) == nil {
            userDefaults.set(app.version, forKey: ApplicationUpdatedSystemEventParamaters.installedVersion)
        }

        notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification)
            .replaceOutput(with: SystemEvent.applicationBackgrounded)
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .compactMap { _ in
                let update = ApplicationUpdatedSystemEventParamaters()
                guard update.previousVersion == nil else { return nil }
                return SystemEvent.applicationInstalled
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .map(SystemEvent.applicationOpened(_:))
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .compactMap { _ in
                let update = ApplicationUpdatedSystemEventParamaters()
                let isDifferent = !(update.version == update.previousVersion || update.build == update.previousBuild)
                guard update.previousVersion != nil, isDifferent else {
                    return nil
                }
                return SystemEvent.applicationUpdated
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .compactMap { [pushNotificationParameters] notification in
                pushNotificationParameters(notification)
                    .map(SystemEvent.pushNotificationTapped)
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.didFinishLaunchingNotification)
            .compactMap { [didCrashOnPreviousExecution] _ in
                guard didCrashOnPreviousExecution() else { return nil }
                return SystemEvent.applicationCrashed
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.willEnterForegroundNotification)
            .map(SystemEvent.applicationOpened)
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.willTerminateNotification)
            .sink(to: SystemEventAnalytics.willTerminate(notification:), on: self)
            .store(in: &bag)

        notificationCenter.publisher(for: UIApplication.pushNotificationReceivedNotification)
            .compactMap { [pushNotificationParameters] notification in
                pushNotificationParameters(notification)
                    .map(SystemEvent.pushNotificationReceived)
            }
            .sink(receiveValue: recorder.record(event:))
            .store(in: &bag)
    }

    func pushNotificationParameters(notification: Notification) -> ApplicationPushNotificationParamaters? {
        let key = UIApplication.LaunchOptionsKey.remoteNotification
        if
            let payload = notification.userInfo?[key] as? [String: Any],
            let aps = payload["aps"] as? [String: Any]
        {
            return .init(
                campaign: .init(
                    content: aps["body"] as? String,
                    medium: aps["medium"] as? String,
                    name: aps["title"] as? String,
                    source: aps["source"] as? String
                )
            )
        } else {
            return nil
        }
    }

    func willTerminate(notification: Notification) {
        userDefaults.set(app.version, forKey: ApplicationUpdatedSystemEventParamaters.previousVersion)
        userDefaults.set(app.build, forKey: ApplicationUpdatedSystemEventParamaters.previousBuild)
    }
}

public struct ApplicationSystemEventParamaters: AnalyticsEventParameters, Encodable {
    public let version: String
    public let build: String
}

public struct ApplicationPushNotificationParamaters: AnalyticsEventParameters, Encodable {

    public struct Campaign: Encodable {
        public var content: String?
        public var medium: String? = "Push Notification"
        public var name: String?
        public var source: String?
    }

    public var campaign: Campaign?
}

extension ApplicationSystemEventParamaters {
    init(app: App = .init()) {
        version = app.version ?? "<unknown>"
        build = app.build ?? "<unknown>"
    }
}

public struct ApplicationOpenedSystemEventParamaters: AnalyticsEventParameters, Encodable {
    public let version: String
    public let build: String
    public let fromBackground: Bool
    public let referringApplication: String?
    public let url: String?
}

extension ApplicationOpenedSystemEventParamaters {

    init(app: App = .init(), notification: Notification) {
        version = app.version ?? "<unknown>"
        build = app.build ?? "<unknown>"
        fromBackground = notification.name == UIApplication.willEnterForegroundNotification
        referringApplication = notification.userInfo?[UIApplication.LaunchOptionsKey.sourceApplication] as? String
        url = notification.userInfo?[UIApplication.LaunchOptionsKey.url] as? String
    }
}

public struct ApplicationUpdatedSystemEventParamaters: AnalyticsEventParameters, Encodable {
    public let version: String
    public let build: String
    public let installedVersion: String?
    public let previousVersion: String?
    public let previousBuild: String?
}

extension ApplicationUpdatedSystemEventParamaters {

    static let installedVersion = "ApplicationUpdatedSystemEventParamaterInstalledVersion"
    static let previousVersion = "ApplicationUpdatedSystemEventParamaterPreviousVersion"
    static let previousBuild = "ApplicationUpdatedSystemEventParamaterPreviousBuild"

    init(app: App = .init(), userDefaults: UserDefaults = .standard) {
        version = app.version ?? "<unknown>"
        build = app.build ?? "<unknown>"
        installedVersion = userDefaults.string(forKey: Self.installedVersion)
        previousVersion = userDefaults.string(forKey: Self.previousVersion)
        previousBuild = userDefaults.string(forKey: Self.previousBuild)
    }
}

extension UIApplication {
    public static let pushNotificationReceivedNotification: NSNotification.Name = .init(rawValue: "UIApplicationPushNotificationReceivedNotification")
}

extension Publisher where Failure == Never {

    func replaceOutput<T>(with: T) -> Publishers.Map<Self, T> {
        map { _ in with }
    }

    func sink<Root>(
        to handler: @escaping (Root) -> (Output) -> Void,
        on root: Root
    ) -> AnyCancellable where Root: AnyObject {
        sink { [weak root] value in
            guard let root = root else { return }
            handler(root)(value)
        }
    }
}

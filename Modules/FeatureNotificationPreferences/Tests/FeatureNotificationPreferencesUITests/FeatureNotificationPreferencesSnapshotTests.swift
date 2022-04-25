// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureNotificationPreferencesUI
import Foundation
import Mocks
import SnapshotTesting
import TestKit
import XCTest

final class FeatureNotificationPreferencesSnapshotTests: XCTestCase {
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private var notificationRepoMock: NotificationPreferencesRepositoryMock!

    private var rootStore: Store<NotificationPreferencesState, NotificationPreferencesAction>!

    enum Config {
        static let recordingSnapshots: Bool = false
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = Config.recordingSnapshots
        notificationRepoMock = NotificationPreferencesRepositoryMock()

        let preferencesToReturn = [
            MockGenerator.marketingNotificationPreference,
            MockGenerator.transactionalNotificationPreference,
            MockGenerator.priceAlertNotificationPreference
        ]
        notificationRepoMock.fetchPreferencesSubject.send(preferencesToReturn)

        rootStore = .init(
            initialState: .init(viewState: .idle),
            reducer: notificationPreferencesReducer,
            environment: FeatureNotificationPreferencesEnvironment(
                mainQueue: mainScheduler.eraseToAnyScheduler(),
                notificationPreferencesRepository: notificationRepoMock
            )
        )
    }

    override func tearDownWithError() throws {
        notificationRepoMock = nil
        rootStore = nil
        try super.tearDownWithError()
    }

    func test_iPhoneSE_snapshot_display_notification_preferences() throws {
        let view = FeatureNotificationPreferencesView(store: rootStore)
        view.viewStore.send(.onAppear)
        mainScheduler.advance()
        assert(view, on: .iPhoneSe)
    }

    func test_iPhoneXR_snapshot_display_notification_preferences() throws {
        let view = FeatureNotificationPreferencesView(store: rootStore)
        view.viewStore.send(.onAppear)
        mainScheduler.advance()
        assert(view, on: .iPhoneXr)
    }

    func test_iPhoneXsMax_snapshot_display_notification_preferences() throws {
        let view = FeatureNotificationPreferencesView(store: rootStore)
        view.viewStore.send(.onAppear)
        mainScheduler.advance()
        assert(view, on: .iPhoneXsMax)
    }
}

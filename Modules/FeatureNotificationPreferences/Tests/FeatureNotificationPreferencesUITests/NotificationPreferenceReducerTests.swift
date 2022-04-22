//
//  File.swift
//  
//
//  Created by Augustin Udrea on 21/04/2022.
//

import ComposableArchitecture
import XCTest
@testable import FeatureNotificationPreferencesUI
import NetworkError
import UIComponentsKit
import Mocks

class NotificationPreferencesReducerTest: XCTestCase {
    private var testStore: TestStore<
        NotificationPreferencesState,
        NotificationPreferencesState,
        NotificationPreferencesAction,
        NotificationPreferencesAction,
        FeatureNotificationPreferencesEnvironment
    >!
    
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private var notificationRepoMock: NotificationPreferencesRepositoryMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        notificationRepoMock = NotificationPreferencesRepositoryMock()
        testStore = TestStore(
            initialState: .init(viewState: .idle),
            reducer: featureNotificationReducer,
            environment: FeatureNotificationPreferencesEnvironment(mainQueue: mainScheduler.eraseToAnyScheduler(),
                                                                   notificationPreferencesRepository: notificationRepoMock)
        )
    }
    
    
    func test_fetchSettings_on_startup() {
        testStore.send(.onAppear) { state in
            state.viewState = .loading
        }
    }
    
    func test_reload_tap() {
        let preferencesToReturn = [MockGenerator.marketingNotificationPreference]
        notificationRepoMock.fetchPreferencesSubject.send(preferencesToReturn)
        
        testStore.send(.onReloadTap)
        
        XCTAssertTrue(self.notificationRepoMock.fetchSettingsCalled)
        
        mainScheduler.advance()
        
        testStore.receive(.onFetchedSettings(Result.success(preferencesToReturn))) { state in
            state.viewState = .data(notificationDetailsState: preferencesToReturn)
        }
    }
    
    func test_onFetchedSettings_success() {
        let preferencesToReturn = [MockGenerator.marketingNotificationPreference]

        testStore.send(.onFetchedSettings(Result.success(preferencesToReturn))) { state in
            state.viewState = .data(notificationDetailsState: preferencesToReturn)
        }
    }
    
    func test_onFetchedSettings_failure() {
        testStore.send(.onFetchedSettings(Result.failure(NetworkError.serverError(.badResponse)))) { state in
            state.viewState = .error
        }
    }
        
    func test_onSaveSettings() {            
        testStore.send(.notificationDetailsChanged(.save))
        mainScheduler.advance()
        XCTAssertTrue(notificationRepoMock.updateCalled)
        testStore.receive(.onReloadTap)
    }
}

//
//  File.swift
//  
//
//  Created by Augustin Udrea on 21/04/2022.
//

import ToolKitMock
import ComposableArchitecture
import XCTest
import FeatureNotificationPreferencesUI
import UIComponentsKit

class NotificationPreferencesReducerTest: XCTestCase {
    private var testStore: TestStore<
        NotificationPreferencesState,
        NotificationPreferencesState,
        NotificationPreferencesAction,
        NotificationPreferencesAction,
        FeatureNotificationPreferencesEnvironment
    >!
    
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test


    override func setUpWithError() throws {
        try super.setUpWithError()
        testStore = TestStore(
            initialState: .init(viewState: .idle),
            reducer: featureNotificationReducer,
            environment: FeatureNotificationPreferencesEnvironment(mainQueue: mainScheduler.eraseToAnyScheduler(),
                                                                   notificationPreferencesRepository: NotificationPreferencesRepositoryMock(),
                                                                   updatePreferencesService: UpdateContactPreferencesServiceMock())
        )
    }
    
    
    func test_fetchSettings_on_startup() {
        testStore.send(.onAppear) { state in
            state.notificationPrefrences?.isEmpty == false
        }
    }

}

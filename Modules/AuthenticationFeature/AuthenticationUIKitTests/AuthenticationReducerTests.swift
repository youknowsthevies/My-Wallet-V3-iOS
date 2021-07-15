// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AuthenticationKit
@testable import AuthenticationUIKit
import ComposableArchitecture
import XCTest

class AuthenticationReducerTests: XCTestCase {

    private var testStore: TestStore<
        AuthenticationState,
        AuthenticationState,
        AuthenticationAction,
        AuthenticationAction,
        AuthenticationEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // TODO: Add tests when the implementation is finalized
}

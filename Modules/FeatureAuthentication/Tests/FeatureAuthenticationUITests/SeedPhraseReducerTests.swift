// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationUI
import HDWalletKit
import ToolKit
import XCTest

@testable import AnalyticsKitMock
@testable import ToolKitMock

final class SeedPhraseReducerTests: XCTestCase {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        SeedPhraseState,
        SeedPhraseState,
        SeedPhraseAction,
        SeedPhraseAction,
        SeedPhraseEnvironment
    >!

    private let recoverFromMetadata = PassthroughSubject<EmptyValue, WalletRecoveryError>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        testStore = TestStore(
            initialState: .init(context: .restoreWallet),
            reducer: seedPhraseReducer,
            environment: SeedPhraseEnvironment(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                validator: SeedPhraseValidator(words: Set(WordList.default.words)),
                passwordValidator: PasswordValidator(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder(),
                walletRecoveryService: .mock(),
                walletCreationService: .mock()
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = SeedPhraseState(context: .restoreWallet)
        XCTAssertEqual(state.seedPhrase, "")
        XCTAssertEqual(state.seedPhraseScore, .none)
    }

    func test_seed_phrase_validator_should_update_score() {
        let completePhrase = "echo abandon dose scheme win real fiber snake void board utility jacket"
        let incompletePhrase = "echo"
        let excessPhrase = "echo abandon dose scheme win real fiber snake void board utility jacket more"
        let invalidPhrase = "echo abandon dose scheme win real fiber snake void board utility mac"
        let invalidRange = NSRange(location: 65, length: 3)
        // GIVEN: Complete Seed Phrase
        testStore.send(.didChangeSeedPhrase(completePhrase)) { state in
            state.seedPhrase = completePhrase
        }
        // WHEN: Validate Seed Phrase
        testStore.receive(.validateSeedPhrase)
        mockMainQueue.advance()
        // THEN: Seed Phrase Score should be `complete`
        testStore.receive(.didChangeSeedPhraseScore(.valid)) { state in
            state.seedPhraseScore = .valid
        }

        // GIVEN: Incomplete Seed Phrase
        testStore.send(.didChangeSeedPhrase(incompletePhrase)) { state in
            state.seedPhrase = incompletePhrase
        }
        // WHEN: Validate Seed Phrase
        testStore.receive(.validateSeedPhrase)
        mockMainQueue.advance()
        // THEN: Seed Phrase Score should be `incomplete`
        testStore.receive(.didChangeSeedPhraseScore(.incomplete)) { state in
            state.seedPhraseScore = .incomplete
        }

        // GIVEN: Excess Seed Phrase
        testStore.send(.didChangeSeedPhrase(excessPhrase)) { state in
            state.seedPhrase = excessPhrase
        }
        // WHEN: Validate Seed Phrase
        testStore.receive(.validateSeedPhrase)
        mockMainQueue.advance()
        // THEN: Seed Phrase Score should be `excess`
        testStore.receive(.didChangeSeedPhraseScore(.excess)) { state in
            state.seedPhraseScore = .excess
        }

        // GIVEN: Invalid Seed Phrase
        testStore.send(.didChangeSeedPhrase(invalidPhrase)) { state in
            state.seedPhrase = invalidPhrase
        }
        // WHEN: Validate Seed Phrase
        testStore.receive(.validateSeedPhrase)
        mockMainQueue.advance()
        // THEN: Seed Phrase Score should be `invalid`
        testStore.receive(.didChangeSeedPhraseScore(.invalid([invalidRange]))) { state in
            state.seedPhraseScore = .invalid([invalidRange])
        }
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
@testable import FeatureOnboardingUI
import XCTest

final class OnboardingChecklistReducerTests: XCTestCase {

    private var testStore: TestStore<
        OnboardingChecklist.State,
        OnboardingChecklist.State,
        OnboardingChecklist.Action,
        OnboardingChecklist.Action,
        OnboardingChecklist.Environment
    >!
    private var testMainScheduler: TestSchedulerOf<DispatchQueue>!
    private var userStateSubject: PassthroughSubject<UserState, Never>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        userStateSubject = PassthroughSubject()
        testMainScheduler = DispatchQueue.test
        testStore = .init(
            initialState: OnboardingChecklist.State(),
            reducer: OnboardingChecklist.reducer,
            environment: OnboardingChecklist.Environment(
                userState: userStateSubject.eraseToAnyPublisher(),
                presentBuyFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(
                        UserState(
                            hasCompletedKYC: true,
                            hasLinkedPaymentMethods: true,
                            hasEverPurchasedCrypto: true
                        )
                    )
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                presentKYCFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(
                        UserState(
                            hasCompletedKYC: true,
                            hasLinkedPaymentMethods: false,
                            hasEverPurchasedCrypto: false
                        )
                    )
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                presentPaymentMethodLinkingFlow: { [userStateSubject, testMainScheduler] completion in
                    userStateSubject?.send(
                        UserState(
                            hasCompletedKYC: true,
                            hasLinkedPaymentMethods: true,
                            hasEverPurchasedCrypto: false
                        )
                    )
                    testMainScheduler?.schedule {
                        completion(true)
                    }
                },
                mainQueue: testMainScheduler.eraseToAnyScheduler()
            )
        )
    }

    override func tearDownWithError() throws {
        testStore = nil
        testMainScheduler = nil
        userStateSubject = nil
        try super.tearDownWithError()
    }

    func test_action_didSelectItem_kycCompleted_no_items_completed() throws {
        resetUserStateToClean()
        testStore.assert(
            .send(.startObservingUserState),
            // user taps on verify identity item
            .send(.didSelectItem(.verifyIdentity)),
            // kyc is done
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            // then they go through kyc
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity]
            },
            .send(.stopObservingUserState)
        )
    }

    func test_action_didSelectItem_linkPaymentMethod_no_items_completed() throws {
        resetUserStateToClean()
        testStore.assert(
            .send(.startObservingUserState),
            // user taps on verify identity item
            .send(.didSelectItem(.linkPaymentMethods)),
            // then they go through kyc
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            // kyc is done
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity]
            },
            // then they go through linking a payment method
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
            },
            .send(.stopObservingUserState)
        )
    }

    func test_action_didSelectItem_linkPaymentMethod_kyc_completed() throws {
        resetUserStateToKYCCompleted()
        testStore.assert(
            .send(.startObservingUserState),
            // user taps on verify identity item
            .send(.didSelectItem(.linkPaymentMethods)),
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            // then they go through linking a payment method
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
            },
            .send(.stopObservingUserState)
        )
    }

    func test_action_didSelectItem_buyCrypto_no_items_completed() throws {
        resetUserStateToClean()
        testStore.assert(
            .send(.startObservingUserState),
            // user taps on verify identity item
            .send(.didSelectItem(.buyCrypto)),
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            // then they go through kyc
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity]
            },
            // then they go through linking a payment method
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
            },
            // then they go through buy
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: true
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
            },
            .send(.stopObservingUserState)
        )
    }

    func test_action_didSelectItem_buyCrypto_kyc_completed() throws {
        resetUserStateToKYCCompleted()
        testStore.assert(
            .send(.startObservingUserState),
            // user taps on verify identity item
            .send(.didSelectItem(.buyCrypto)),
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            // then they go through linking a payment method
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
            },
            // then they go through buy
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: true
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
            },
            .send(.stopObservingUserState)
        )
    }

    func test_action_didSelectItem_buyCrypto_kyc_and_payment_completed() throws {
        resetUserStateToKYCAndPaymentsCompleted()
        testStore.assert(
            .send(.startObservingUserState),
            // user taps on verify identity item
            .send(.didSelectItem(.buyCrypto)),
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            // then they go through buy
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: true
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity, .linkPaymentMethod, .buyCrypto]
            },
            .send(.stopObservingUserState)
        )
    }

    func test_action_dismissFullScreenChecklist() throws {
        testStore.assert(
            // user taps on close
            .send(.dismissFullScreenChecklist),
            // then the full screen checklist gets dismissed
            .receive(.dismiss()) {
                $0.route = nil
            }
        )
    }

    func test_action_presentFullScreenChecklist() throws {
        testStore.assert(
            // user taps on overview
            .send(.presentFullScreenChecklist),
            // then the full screen checklist gets presented
            .receive(.enter(into: .fullScreenChecklist, context: .none)) {
                $0.route = .enter(into: .fullScreenChecklist, context: .none)
            }
        )
    }

    func test_action_startAndStopObservingUserState() throws {
        testStore.assert(
            // view is displayed and starts listening to changes
            .send(.startObservingUserState),
            // a new value is sent
            .do { [weak self] in
                self?.resetUserState(
                    to: UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            },
            // that new value is received
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity]
            },
            // the view is dimissed and the values stream subscription is cancelled
            .send(.stopObservingUserState),
            // the next do block serves to ensure no further changes are listened to
            .do { [weak self] in
                self?.resetUserStateToKYCAndPaymentsCompleted()
                self?.testMainScheduler.advance()
            }
        )
    }
}

// MARK: - Helpers

extension OnboardingChecklistReducerTests {

    private func resetUserStateToClean() {
        testStore.assert(
            .send(.startObservingUserState),
            .do { [weak self] in
                self?.resetUserState(
                    to: UserState(
                        hasCompletedKYC: false,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            },
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: false,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = []
            },
            .send(.stopObservingUserState)
        )
    }

    private func resetUserStateToKYCCompleted() {
        testStore.assert(
            .send(.startObservingUserState),
            .do { [weak self] in
                self?.resetUserState(
                    to: UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            },
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: false,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity]
            },
            .send(.stopObservingUserState)
        )
    }

    private func resetUserStateToKYCAndPaymentsCompleted() {
        testStore.assert(
            .send(.startObservingUserState),
            .do { [weak self] in
                self?.resetUserState(
                    to: UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: false
                    )
                )
            },
            .do { [weak self] in
                self?.testMainScheduler.advance()
            },
            .receive(
                .userStateDidChange(
                    UserState(
                        hasCompletedKYC: true,
                        hasLinkedPaymentMethods: true,
                        hasEverPurchasedCrypto: false
                    )
                )
            ) {
                $0.completedItems = [.verifyIdentity, .linkPaymentMethod]
            },
            .send(.stopObservingUserState)
        )
    }

    private func resetUserState(to userState: UserState) {
        userStateSubject.send(userState)
    }
}

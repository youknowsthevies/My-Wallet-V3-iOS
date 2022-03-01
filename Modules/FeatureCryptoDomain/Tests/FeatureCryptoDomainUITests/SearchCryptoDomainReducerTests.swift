// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
@testable import FeatureCryptoDomainData
@testable import FeatureCryptoDomainMock
@testable import FeatureCryptoDomainUI
import OrderedCollections
import XCTest

final class SearchCryptoDomainReducerTests: XCTestCase {

    private var mockMainQueue: ImmediateSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        SearchCryptoDomainState,
        SearchCryptoDomainState,
        SearchCryptoDomainAction,
        SearchCryptoDomainAction,
        SearchCryptoDomainEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.immediate
        testStore = TestStore(
            initialState: .init(),
            reducer: searchCryptoDomainReducer,
            environment: SearchCryptoDomainEnvironment(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                searchDomainRepository: SearchDomainRepository(
                    apiClient: MockSearchDomainClient()
                )
            )
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        mockMainQueue = nil
        testStore = nil
    }

    func test_on_appear_should_search_domains() {
        testStore.send(.onAppear)
        testStore.receive(.searchDomains)
        testStore.receive(.didReceiveDomainsResult(.success(mockSearchDomainResults))) { state in
            state.searchResults = mockSearchDomainResults
        }
    }

    func test_valid_search_text_should_search_domains() {
        testStore.send(.set(\.$searchText, "valid")) { state in
            state.isSearchTextValid = true
            state.searchText = "valid"
        }
        testStore.receive(.searchDomains)
        testStore.receive(.didReceiveDomainsResult(.success(mockSearchDomainResults))) { state in
            state.searchResults = mockSearchDomainResults
        }
    }

    func test_invalid_search_text_should_not_search_domains() {
        testStore.send(.set(\.$searchText, "in.valid")) { state in
            state.isSearchTextValid = false
            state.searchText = "in.valid"
        }
    }

    func test_select_free_domain_should_go_to_checkout() {
        testStore.send(.selectFreeDomain(mockSearchDomainResults[1])) { state in
            state.selectedDomains = OrderedSet([mockSearchDomainResults[1]])
        }
        testStore.receive(.navigate(to: .checkout)) { state in
            state.route = RouteIntent(route: .checkout, action: .navigateTo)
            state.checkoutState = .init(
                selectedDomains: OrderedSet([mockSearchDomainResults[1]])
            )
        }
    }

    func test_select_premium_domain_should_open_bottom_sheet() {
        testStore.send(.selectPremiumDomain(mockSearchDomainResults[0])) { state in
            state.selectedPremiumDomain = mockSearchDomainResults[0]
        }
        testStore.receive(.set(\.$isPremiumDomainBottomSheetShown, true)) { state in
            state.isPremiumDomainBottomSheetShown = true
        }
    }

    func test_remove_at_checkout_should_update_state() {
        testStore.send(.selectFreeDomain(mockSearchDomainResults[1])) { state in
            state.selectedDomains = OrderedSet([mockSearchDomainResults[1]])
        }
        testStore.receive(.navigate(to: .checkout)) { state in
            state.route = RouteIntent(route: .checkout, action: .navigateTo)
            state.checkoutState = .init(
                selectedDomains: OrderedSet([mockSearchDomainResults[1]])
            )
        }
        testStore.send(.checkoutAction(.removeDomain(mockSearchDomainResults[1]))) { state in
            state.checkoutState?.selectedDomains = OrderedSet([])
            state.selectedDomains = OrderedSet([])
        }
        testStore.receive(.checkoutAction(.set(\.$isRemoveBottomSheetShown, false)))
    }
}

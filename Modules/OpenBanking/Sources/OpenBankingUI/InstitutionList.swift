// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import OpenBanking
import SwiftUI
import ToolKit
import UIComponentsKit
import ComponentLibrary

public struct InstitutionListState: Equatable, NavigationState {

    public var route: RouteIntent<InstitutionListRoute>?

    var account: Result<OpenBanking.BankAccount, OpenBanking.Error>?
    var selection: ApproveState?
}

public enum InstitutionListAction: NavigationAction, FailAction {

    case route(RouteIntent<InstitutionListRoute>?)
    case fail(OpenBanking.Error)

    case fetch
    case fetched(OpenBanking.BankAccount)
    case select(OpenBanking.Institution)
    case showTransferDetails

    case approve(ApproveAction)
    case dismiss
}

public enum InstitutionListRoute: CaseIterable, NavigationRoute {

    case approve

    @ViewBuilder
    public func destination(in store: Store<InstitutionListState, InstitutionListAction>) -> some View {
        switch self {
        case .approve:
            IfLetStore(
                store.scope(state: \.selection, action: InstitutionListAction.approve),
                then: ApproveView.init(store:)
            )
        }
    }
}

public let institutionListReducer = Reducer<InstitutionListState, InstitutionListAction, OpenBankingEnvironment>
    .combine(
        approveReducer
            .optional()
            .pullback(
                state: \.selection,
                action: /InstitutionListAction.approve,
                environment: \.environment
            ),
        .init { state, action, environment in
            switch action {
            case .route(let route):
                state.route = route
                return .none
            case .fetch:
                return try environment.openBanking
                    .createBankAccount()
                    .receive(on: environment.scheduler.main)
                    .eraseToEffect()
                    .mapped(to: InstitutionListAction.fetched)
            case .fetched(let account):
                state.account = .success(account)
                return .none
            case .showTransferDetails:
                return .fireAndForget(environment.showTransferDetails)
            case .select(let institution):
                let account = try state.account
                    .or(throw: OpenBanking.Error.message(R.InstitutionList.Error.invalidAccount))
                    .get()
                state.selection = .init(
                    bank: .init(account: account, action: .link(institution: institution))
                )
                return .navigate(to: .approve)
            case .approve(.deny):
                state.route = nil
                return .none
            case .approve(.bank(.cancel)):
                state.route = nil
                state.account = nil
                return Effect(value: .fetch)
            case .approve:
                return .none
            case .dismiss:
                return .fireAndForget(environment.dismiss)
            case .fail(let error):
                state.account = .failure(error)
                return .none
            }
        }
    )

public struct InstitutionList: View {

    private let store: Store<InstitutionListState, InstitutionListAction>

    @State private var loading: CGFloat = 44
    @State private var padding: CGFloat = 40

    public init(store: Store<InstitutionListState, InstitutionListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                switch viewStore.account {
                case .none:
                    ProgressView(value: 0.25)
                        .frame(width: 12.vmin, alignment: .center)
                        .aspectRatio(1, contentMode: .fit)
                        .progressViewStyle(IndeterminateProgressStyle())
                        .onAppear { viewStore.send(.fetch) }
                case .success(let account):
                    SearchableList(
                        account.attributes.institutions?.map(Item.init) ?? [],
                        placeholder: R.InstitutionList.search,
                        content: { bank in
                            Button(
                                action: { viewStore.send(.select(bank.institution)) },
                                label: { bank }
                            )
                        },
                        empty: {
                            NoSearchResults
                        }
                    )
                case .failure(let error):
                    InfoView(
                        .init(
                            media: .bankIcon,
                            overlay: .init(media: .error),
                            title: R.Error.title,
                            subtitle: "\(error.description)"
                        ),
                        in: .platformUIKit
                    )
                }
            }
            .navigationRoute(in: store)
            .navigationTitle(R.InstitutionList.title)
            .whiteNavigationBarStyle()
            .trailingNavigationButton(.close) {
                viewStore.send(.dismiss)
            }
        }
    }

    @ViewBuilder var NoSearchResults: some View {
        WithViewStore(store) { view in
            Spacer()
            Text(R.InstitutionList.Error.couldNotFindBank)
                .typography(.body2)
                .foregroundColor(.textTitle)
                .frame(alignment: .center)
                .padding(10.5.vmin)
                .multilineTextAlignment(.center)
            Spacer()
            PrimaryButton(title: R.InstitutionList.Error.showTransferDetails) {
                view.send(.showTransferDetails)
            }
        }
    }
}

extension InstitutionList {

    public struct Item: View, Identifiable {

        let institution: OpenBanking.Institution

        public var id: Identity<OpenBanking.Institution> {
            institution.id
        }

        private var image: URL? {
            institution.media.first(where: { $0.type == .icon })?.source
                ?? institution.media.first?.source
        }

        private var title: String {
            institution.fullName
        }

        @State private var icon: CGFloat = 44
        @State private var row: CGFloat = 75
        @State private var chevron: CGFloat = 8

        init(_ institution: OpenBanking.Institution) {
            self.institution = institution
        }

        public var body: some View {
            HStack {
                Group {
                    if let image = image {
                        ImageResourceView(
                            url: image,
                            placeholder: { Color.viewPrimaryBackground }
                        )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    } else {
                        Color.viewPrimaryBackground
                    }
                }
                .frame(width: 12.vw, height: 12.vw, alignment: .center)
                Text(title)
                    .typography(.title3)
                Spacer()
                Image(systemName: "chevron.right")
                    .frame(width: 8.pt)
                    .padding()
                    .foregroundColor(.disclosureIndicator)
            }
            .frame(height: 9.5.vh, alignment: .center)
        }
    }
}

extension InstitutionList.Item: CustomStringConvertible {
    public var description: String { title }
}

#if DEBUG
struct InstitutionList_Previews: PreviewProvider {

    static var previews: some View {
        InstitutionList.Item(.mock)
        NavigationView {
            InstitutionList(
                store: Store<InstitutionListState, InstitutionListAction>(
                    initialState: InstitutionListState(),
                    reducer: institutionListReducer,
                    environment: .mock
                )
            )
            .ignoresSafeArea()
        }
    }
}
#endif

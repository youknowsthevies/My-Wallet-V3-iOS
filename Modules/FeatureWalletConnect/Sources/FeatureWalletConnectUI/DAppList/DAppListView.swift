// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureWalletConnectDomain
import SwiftUI
import UIComponentsKit
import WalletConnectSwift

struct DAppListView: View {
    private let store: Store<DAppListState, DAppListAction>

    init(store: Store<DAppListState, DAppListAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    VStack {
                        HStack(alignment: .top) {
                            Spacer()
                            RoundedRectangle(cornerRadius: 100)
                                .frame(width: 32, height: 4)
                                .foregroundColor(.borderPrimary)
                                .offset(x: 16, y: -6)
                            Spacer()
                            Button(action: {
                                viewStore.send(.close)
                            }, label: {
                                Image(uiImage: UIImage(named: "close-button", in: .featureWalletConnectUI, with: nil)!)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                            })
                        }
                        .padding([.horizontal], 24)
                        HStack {
                            Text(viewStore.title)
                                .typography(.body2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding([.horizontal], 24)
                        .offset(y: -12)
                        Divider()
                        DAppList()
                    }
                    .padding([.vertical], 24)
                }
                .gesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .global)
                        .onEnded { drag in
                            if drag.translation.height >= 20 {
                                viewStore.send(.close)
                            }
                        }
                )
                .onAppear { viewStore.send(.onAppear) }
            }
        }
    }

    @ViewBuilder func DAppList() -> some View {
        WithViewStore(store) { viewStore in
            VStack {
                ForEach(viewStore.sessions) { session in
                    DAppItem(session: .init(session: session)).onTapGesture {
                        viewStore.send(.showSessionDetails(session))
                    }
                    if viewStore.sessions.firstIndex(of: session) != viewStore.sessions.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    @ViewBuilder func DAppItem(session: DAppListState.DAppViewState) -> some View {
        HStack(spacing: 16) {
            if let imageResource = session.imageResource {
                ImageResourceView(imageResource, placeholder: { Color.viewPrimaryBackground })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(session.name)
                    .typography(.body2)
                    .lineLimit(1)
                Text(session.domain)
                    .typography(.paragraph1)
                    .foregroundColor(.textSubheading)
            }
            Spacer()
            ImageResourceView(systemName: "ellipsis")
                .foregroundColor(.textSubheading)
                .frame(width: 16, height: 4)
        }
        .backgroundTexture(.white)
        .frame(height: 79)
        .padding([.horizontal], 24)
    }
}

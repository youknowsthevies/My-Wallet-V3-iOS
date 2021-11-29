// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureWalletConnectDomain
import SwiftUI
import UIComponentsKit
import WalletConnectSwift

struct DAppListView: View {
    @GestureState private var dragState = WalletConnectEventView.BottomSheet.DragState.inactive

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
                    .backgroundTexture(.white)
                    .clipShape(RoundedCorner(cornerRadius: 8, corners: [.topLeft, .topRight]))
                }
                .backgroundTexture(.clear)
                .offset(y: self.dragState.yOffset)
                .animation(self.dragState.animate ? .easeInOut : nil)
                .gesture(
                    DragGesture()
                        .updating($dragState) { drag, state, _ in
                            state = .dragging(translation: drag.translation)
                        }
                        .onChanged { _ in
                            if dragState.dismiss {
                                viewStore.send(.close)
                            }
                        }
                )
                .onAppear { viewStore.send(.onAppear) }
            }
            .backgroundTexture(.lightContentBackground.opacity(0.64))
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
                ImageResourceView(imageResource)
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

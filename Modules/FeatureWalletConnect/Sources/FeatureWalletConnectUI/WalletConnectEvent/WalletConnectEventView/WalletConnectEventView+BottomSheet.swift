// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI
import UIComponentsKit

extension WalletConnectEventView {
    struct BottomSheet: View {

        @GestureState private var dragState = DragState.inactive
        private let store: Store<WalletConnectEventState, WalletConnectEventAction>

        init(store: Store<WalletConnectEventState, WalletConnectEventAction>) {
            self.store = store
        }

        var body: some View {
            WithViewStore(self.store) { viewStore in
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
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
                        if let imageResource = viewStore.imageResource {
                            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                                ImageResourceView(imageResource)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 64, height: 64)
                                    .cornerRadius(13)
                                if let decorationImage = viewStore.decorationImage {
                                    Image(uiImage: decorationImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .offset(x: 15, y: -15)
                                }
                            }
                        }
                        Text(viewStore.title)
                            .typography(.title3)
                            .multilineTextAlignment(.center)
                        Text(viewStore.subtitle ?? "")
                            .typography(.paragraph1)
                            .foregroundColor(.textSubheading)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 32)
                        if let secondaryButtonTitle = viewStore.secondaryButtonTitle,
                           let secondaryAction = viewStore.secondaryAction
                        {
                            Button(secondaryButtonTitle) {
                                viewStore.send(secondaryAction)
                            }
                            .buttonStyle(
                                SecondaryButtonStyle(
                                    isEnabled: true,
                                    foregroundColor: viewStore.secondaryButtonColor
                                )
                            )
                        }
                        PrimaryButton(title: viewStore.primaryButtonTitle) {
                            viewStore.send(viewStore.primaryAction)
                        }
                    }
                    .padding(24)
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
            }
        }
    }
}

extension WalletConnectEventView.BottomSheet {
    enum DragState {

        static let maxOffset: CGFloat = UIScreen.main.bounds.height
        static let closingThreshold: CGFloat = maxOffset / 4

        case inactive
        case dragging(translation: CGSize)

        var yOffset: CGFloat {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                let offset = yOffset(translation: translation)
                return shouldDismiss(yOffset: offset)
                    ? Self.maxOffset
                    : offset
            }
        }

        var animate: Bool {
            switch self {
            case .inactive:
                return true
            case .dragging(let translation):
                let offset = max(0, translation.height)
                return offset >= Self.closingThreshold
            }
        }

        var dismiss: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging(let translation):
                let offset = yOffset(translation: translation)
                return shouldDismiss(yOffset: offset)
            }
        }

        private func yOffset(translation: CGSize) -> CGFloat {
            max(0, translation.height)
        }

        private func shouldDismiss(yOffset: CGFloat) -> Bool {
            yOffset >= Self.closingThreshold
        }
    }
}

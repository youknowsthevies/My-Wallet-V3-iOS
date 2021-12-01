// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI
import UIComponentsKit

extension WalletConnectEventView {
    struct BottomSheet: View {

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
                                ImageResourceView(imageResource, placeholder: { Color.viewPrimaryBackground })
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
                }
                .gesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .global)
                        .onEnded { drag in
                            if drag.translation.height >= 20 {
                                viewStore.send(.close)
                            }
                        }
                )
            }
        }
    }
}

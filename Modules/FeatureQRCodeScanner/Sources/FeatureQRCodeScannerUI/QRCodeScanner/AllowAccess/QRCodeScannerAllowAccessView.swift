// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI

struct QRCodeScannerAllowAccessView: View {
    private typealias LocalizedString = LocalizationConstants.QRCodeScanner.AllowAccessScreen
    private typealias Accessibility = AccessibilityIdentifiers.QRScanner.AllowAccessScreen

    private let store: Store<AllowAccessState, AllowAccessAction>

    init(store: Store<AllowAccessState, AllowAccessAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center) {
                ZStack {
                    indicator
                        .padding(.vertical, Spacing.padding1)
                    HStack(alignment: .center) {
                        Spacer()
                        closeButton(viewStore: viewStore)
                            .padding([.top, .trailing], Spacing.padding2)
                    }
                }
                scannerHeader
                scannerList
                if !viewStore.informationalOnly {
                    Spacer()
                    PrimaryButton(title: LocalizedString.buttonTitle) {
                        viewStore.send(.allowCameraAccess)
                    }
                    .padding([.leading, .trailing], Spacing.padding3)
                    .padding([.top, .bottom], Spacing.padding2)
                    .accessibility(identifier: Accessibility.ctaButton)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { drag in
                        if drag.translation.height >= 20 {
                            viewStore.send(.dismiss)
                        }
                    }
            )
        }
    }

    private var scannerHeader: some View {
        HStack(alignment: .top) {
            Text(LocalizedString.title)
                .typography(.body2)
                .accessibility(identifier: Accessibility.headerTitle)
                .padding(.leading, Spacing.padding3)
            Spacer()
        }
    }

    private var scannerList: some View {
        VStack(alignment: .center, spacing: 0) {
            PrimaryRow(
                title: LocalizedString.ScanQRPoint.title,
                subtitle: LocalizedString.ScanQRPoint.description,
                leading: {
                    Icon.people
                        .frame(width: 24, height: 24)
                        .accentColor(.semantic.primary)
                },
                trailing: { EmptyView() }
            )
            PrimaryRow(
                title: LocalizedString.AccessWebWallet.title,
                subtitle: LocalizedString.AccessWebWallet.description,
                leading: {
                    Icon.computer
                        .frame(width: 24, height: 24)
                        .accentColor(.semantic.primary)
                },
                trailing: { EmptyView() }
            )
            PrimaryRow(
                title: LocalizedString.ConnectToDapps.title,
                subtitle: LocalizedString.ConnectToDapps.description,
                leading: {
                    Image("WalletConnect", bundle: .featureQRCodeScannerUI)
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.semantic.primary)
                },
                trailing: { EmptyView() },
                action: { }
            )
        }
        .accessibility(identifier: Accessibility.scannerList)
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.semantic.dark)
            .frame(width: 32.pt, height: 4.pt)
    }

    private func closeButton(
        viewStore: ViewStore<AllowAccessState, AllowAccessAction>
    ) -> some View {
        Button(
            action: {
                viewStore.send(.dismiss)
            },
            label: {
                Icon.closeCirclev2
                    .frame(width: 24, height: 24)
                    .accentColor(.semantic.muted)
            }
        )
    }
}

struct QRCodeScannerAllowAccessView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerAllowAccessView(
            store: .init(
                initialState: AllowAccessState(
                    informationalOnly: false
                ),
                reducer: qrScannerAllowAccessReducer,
                environment: AllowAccessEnvironment(
                    allowCameraAccess: {
                    },
                    dismiss: {
                    }
                )
            )
        )
        .frame(height: 70.vh)
    }
}

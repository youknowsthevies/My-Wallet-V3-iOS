// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import SwiftUI

struct QRCodeScannerAllowAccessView: View {
    private typealias LocalizedString = LocalizationConstants.QRCodeScanner.AllowAccessScreen
    private typealias Accessibility = AccessibilityIdentifiers.QRScanner.AllowAccessScreen

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.padding3) {
            scannerHeader
                .padding([.leading, .trailing], Spacing.padding3)
            scannerList
            Spacer()
            PrimaryButton(title: LocalizedString.buttonTitle) {
                presentationMode.wrappedValue.dismiss()
            }
            .padding([.leading, .trailing], Spacing.padding3)
            .accessibility(identifier: Accessibility.ctaButton)
        }
        .navigationBarTitleDisplayMode(.inline)
        .primaryNavigation(trailing: { closeButton })
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Icon.closeCirclev2
                .frame(width: 24, height: 24)
                .accentColor(.semantic.muted)
        }
    }

    private var scannerHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.padding2) {
            Text(LocalizedString.title)
                .typography(.body2)
                .accessibility(identifier: Accessibility.headerTitle)
        }
    }

    private var scannerList: some View {
        VStack(alignment: .center, spacing: 10) {
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
                tags: [
                    TagView(
                        text: LocalizedString.ConnectToDapps.betaTagTitle,
                        variant: .infoAlt,
                        size: .small
                    )
                ],
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
}

struct QRCodeScannerAllowAccessView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerAllowAccessView()
    }
}

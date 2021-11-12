// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

struct WalletSectionHeaderExamplesView: View {

    init() {
        UITableView.appearance().backgroundColor = .white
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.baseline) {
                Text("A list with Wallet Section Headers")
                    .foregroundColor(.white)
                    .background(Color.black)
                List {
                    Section(header: WalletSectionHeader(title: "Wallets & Accounts")) {
                        Text("first row")
                        Text("second row")
                        Text("third row")
                    }
                    Section(header: WalletSectionHeader(title: "More Wallets")) {
                        Text("first row")
                        Text("second row")
                        Text("third row")
                    }
                }
                .frame(height: 400)

                Text("Wallet Section Headers inside VStack")
                    .foregroundColor(.white)
                    .background(Color.black)
                VStack {
                    Section(header: WalletSectionHeader(title: "Wallets & Accounts")) {
                        Text("first row")
                        Text("second row")
                        Text("third row")
                    }
                    Section(header: WalletSectionHeader(title: "More Wallets")) {
                        Text("first row")
                        Text("second row")
                        Text("third row")
                    }
                }
                .background(Color.white)
            }
            .padding(.vertical)
        }
    }
}

struct WalletSectionHeaderExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        WalletSectionHeaderExamplesView()
    }
}

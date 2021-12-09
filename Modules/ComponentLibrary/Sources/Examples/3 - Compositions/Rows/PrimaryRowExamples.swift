// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import SwiftUI

// swiftlint:disable line_length
struct PrimaryRowExamplesView: View {

    var body: some View {
        ExampleController(selection: 0)
    }

    struct ExampleController: View {

        @State var selection: Int

        init(selection: Int) {
            _selection = State(initialValue: selection)
        }

        var body: some View {
            ScrollView {
                Group {
                    LazyVStack {
                        PrimaryRow(
                            title: "Trading",
                            subtitle: "Buy & Sell",
                            isSelected: Binding(
                                get: {
                                    selection == 0
                                },
                                set: { _ in
                                    selection = 0
                                }
                            )
                        )

                        PrimaryRow(
                            title: "Email Address",
                            subtitle: "satoshi@blockchain.com",
                            tags: [Tag(text: "Confirmed", variant: .success)],
                            isSelected: Binding(
                                get: {
                                    selection == 1
                                },
                                set: { _ in
                                    selection = 1
                                }
                            )
                        )

                        PrimaryRow(
                            title: "From: BTC Trading Account",
                            subtitle: "To: 0x093871209487120934812027675",
                            isSelected: Binding(
                                get: {
                                    selection == 2
                                },
                                set: { _ in
                                    selection = 2
                                }
                            )
                        )

                        PrimaryRow(
                            title: "Link a Bank",
                            subtitle: "Instant Connection",
                            description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                            tags: [
                                Tag(text: "Fastest", variant: .success),
                                Tag(text: "Warning Alert", variant: .warning)
                            ],
                            isSelected: Binding(
                                get: {
                                    selection == 3
                                },
                                set: { _ in
                                    selection = 3
                                }
                            )
                        )

                        PrimaryRow(
                            title: "Cloud Backup",
                            subtitle: "Buy & Sell",
                            trailing: {
                                Switch()
                            }
                        )
                    }
                }
                Group {
                    LazyVStack {
                        PrimaryRow(
                            title: "Features and Limits",
                            isSelected: Binding(
                                get: {
                                    selection == 5
                                },
                                set: { _ in
                                    selection = 5
                                }
                            )
                        )

                        PrimaryRow(
                            title: "Back Up Your Wallet",
                            subtitle: "Step 1",
                            isSelected: Binding(
                                get: {
                                    selection == 6
                                },
                                set: { _ in
                                    selection = 6
                                }
                            ),
                            leading: {
                                Icon.wallet
                                    .fixedSize()
                                    .accentColor(.semantic.dark)
                            }
                        )

                        PrimaryRow(
                            title: "Gold Level",
                            subtitle: "Higher Trading Limits",
                            tags: [Tag(text: "Approved", variant: .success)],
                            isSelected: Binding(
                                get: {
                                    selection == 7
                                },
                                set: { _ in
                                    selection = 7
                                }
                            ),
                            leading: {
                                Icon.apple
                                    .fixedSize()
                                    .accentColor(.semantic.orangeBG)
                            }
                        )
                    }
                }
                Group {
                    LazyVStack {
                        PrimaryRow(
                            title: "Trade",
                            subtitle: "BTC -> ETH",
                            isSelected: Binding(
                                get: {
                                    selection == 8
                                },
                                set: { _ in
                                    selection = 8
                                }
                            ),
                            leading: {
                                Icon.trade
                                    .fixedSize()
                                    .accentColor(.semantic.success)
                            }
                        )

                        PrimaryRow(
                            title: "Link a Bank",
                            subtitle: "Instant Connection",
                            description: "Securely link a bank to buy crypto, deposit cash and withdraw back to your bank at anytime.",
                            tags: [
                                Tag(text: "Fastest", variant: .success),
                                Tag(text: "Warning Alert", variant: .warning)
                            ],
                            isSelected: Binding(
                                get: {
                                    selection == 9
                                },
                                set: { _ in
                                    selection = 9
                                }
                            ),
                            leading: {
                                Icon.bank
                                    .fixedSize()
                                    .accentColor(.semantic.primary)
                            }
                        )

                        PrimaryRow(
                            title: "Features and Limits",
                            isSelected: Binding(
                                get: {
                                    selection == 10
                                },
                                set: { _ in
                                    selection = 10
                                }
                            ),
                            leading: {
                                Icon.blockchain
                                    .fixedSize()
                                    .accentColor(.semantic.primary)
                            }
                        )
                    }
                }
            }
        }
    }

    private struct Switch: View {
        @State var isOn: Bool = false

        var body: some View {
            PrimarySwitch(
                variant: .green,
                accessibilityLabel: "Test",
                isOn: $isOn
            )
        }
    }
}

struct PrimaryRowExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryRowExamplesView()
    }
}

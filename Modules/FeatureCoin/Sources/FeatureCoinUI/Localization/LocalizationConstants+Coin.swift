// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum Coin {
        enum Label {
            enum Title {
                static let currentCryptoPrice = NSLocalizedString(
                    "Current %@ Price",
                    comment: "Coin View: Current crypto price label title"
                )
                static let aboutCrypto = NSLocalizedString(
                    "About %@",
                    comment: "Coin View: About crypto label title"
                )

                static let notTradable = NSLocalizedString(
                    "%@ (%@) is not tradable.",
                    comment: "Coin View: Not tradeable crypto label title"
                )

                static let addToWatchListInfo = NSLocalizedString(
                    "Add to your watchlist to be notified when %@ is available to trade.",
                    comment: "Coin View: add crypto to watchlist label title"
                )
            }
        }

        enum Link {
            enum Title {
                static let visitWebsite = NSLocalizedString(
                    "Visit Website ->",
                    comment: "Coin View: Visit website link title"
                )
            }
        }

        enum Button {
            enum Title {
                static let buy = NSLocalizedString(
                    "Buy",
                    comment: "Coin View: Buy CTA"
                )
                static let sell = NSLocalizedString(
                    "Sell",
                    comment: "Coin View: Sell CTA"
                )
                static let send = NSLocalizedString(
                    "Send",
                    comment: "Coin View: Send CTA"
                )
                static let receive = NSLocalizedString(
                    "Receive",
                    comment: "Coin View: Receive CTA"
                )
            }
        }

        enum Accounts {
            static let sectionTitle = NSLocalizedString(
                "Wallets & Accounts",
                comment: "Coin View: accounts section header title"
            )

            static let tradingAccountTitle = NSLocalizedString(
                "Trading Account",
                comment: "Coin View: trading account title"
            )

            static let tradingAccountSubtitle = NSLocalizedString(
                "Buy and Sell Bitcoin",
                comment: "Coin View: trading account subtitle"
            )

            static let rewardsAccountTitle = NSLocalizedString(
                "Rewards Account",
                comment: "Coin View: rewards account title"
            )

            static let rewardsAccountSubtitle = NSLocalizedString(
                "Earn %.1f%% APY",
                comment: "Coin View: rewards account subtitle"
            )

            static let exchangeAccountTitle = NSLocalizedString(
                "Exchange Account",
                comment: "Coin View: exchange account title"
            )

            static let exchangeAccountSubtitle = NSLocalizedString(
                "Connect to the Exchange",
                comment: "Coin View: exchange account subtitle"
            )
        }

        enum Graph {

            static let price = NSLocalizedString(
                "Price",
                comment: "Coin View Graph: graph title showing price"
            )

            static let currentPrice = NSLocalizedString(
                "Current Price",
                comment: "Coin View Graph: graph title showing current price"
            )

            enum Error {
                static let title = NSLocalizedString(
                    "Oops! Something went wrong!",
                    comment: "Coin View Graph: Error title"
                )
                static let description = NSLocalizedString(
                    "There seems to be a problem connecting, please try again",
                    comment: "Coin View Graph: Error description"
                )
                static let retry = NSLocalizedString(
                    "Retry",
                    comment: "Coin View Graph: Retry on failure CTA"
                )
            }

            enum TimePeriod {
                static let day = NSLocalizedString(
                    "1D",
                    comment: "Coin View: day time period"
                )
                static let week = NSLocalizedString(
                    "1W",
                    comment: "Coin View: week time period"
                )
                static let month = NSLocalizedString(
                    "1M",
                    comment: "Coin View: month time period"
                )
                static let year = NSLocalizedString(
                    "1Y",
                    comment: "Coin View: year time period"
                )
                static let all = NSLocalizedString(
                    "ALL",
                    comment: "Coin View: all time period"
                )
            }
        }
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureAccountPickerUI
@testable import PlatformKit
@testable import PlatformKitMock
@testable import PlatformUIKit
import RxSwift
import SnapshotTesting
import SwiftUI
import XCTest

class AccountPickerRowViewTests: XCTestCase {

    var isShowingMultiBadge: Bool = false

    let environment = AccountPickerRowEnvironment(
        mainQueue: .main,
        updateSingleAccount: { _ in nil },
        updateAccountGroup: { _ in nil }
    )

    let accountGroupIdentifier = UUID()
    let singleAccountIdentifier = UUID()

    lazy var fiatBalances: [AnyHashable: String] = [
        accountGroupIdentifier: "$2,302.39",
        singleAccountIdentifier: "$2,302.39"
    ]

    lazy var currencyCodes: [AnyHashable: String] = [
        accountGroupIdentifier: "USD"
    ]

    lazy var cryptoBalances: [AnyHashable: String] = [
        accountGroupIdentifier: "0.21204887 BTC",
        singleAccountIdentifier: "0.21204887 BTC"
    ]

    lazy var accountGroup = AccountPickerRow.AccountGroup(
        id: accountGroupIdentifier,
        title: "All Wallets",
        description: "Total Balance"
    )

    lazy var singleAccount = AccountPickerRow.SingleAccount(
        id: singleAccountIdentifier,
        title: "BTC Trading Wallet",
        description: "Bitcoin"
    )

    lazy var linkedBankAccountModel = AccountPickerRow.LinkedBankAccount(
        id: self.linkedBankAccount.identifier,
        title: "Title",
        description: "Description"
    )

    // swiftlint:disable:next force_try
    let linkedBankData = try! LinkedBankData(
        response: LinkedBankResponse(
            json: [
                "id": "id",
                "currency": "GBP",
                "partner": "YAPILY",
                "bankAccountType": "SAVINGS",
                "name": "Name",
                "accountName": "Account Name",
                "accountNumber": "123456",
                "routingNumber": "123456",
                "agentRef": "040004",
                "isBankAccount": false,
                "isBankTransferAccount": true,
                "state": "PENDING",
                "attributes": [
                    "entity": "Safeconnect(UK)"
                ]
            ]
        )
    )!

    lazy var linkedBankAccount = LinkedBankAccount(
        label: "LinkedBankAccount",
        accountNumber: "0",
        accountId: "0",
        accountType: .checking,
        currency: .USD,
        paymentType: .bankAccount,
        partner: .yapily,
        data: linkedBankData
    )

    let paymentMethodFunds = PaymentMethodAccount(
        paymentMethodType: .account(
            FundData(
                balance: .init(
                    currency: .fiat(.GBP),
                    available: .init(amount: 2500000, currency: .fiat(.GBP)),
                    withdrawable: .init(amount: 2500000, currency: .fiat(.GBP)),
                    pending: .zero(currency: .GBP)
                ),
                max: .init(amount: 100000000, currency: .GBP)
            )
        ),
        paymentMethod: .init(
            type: .funds(.fiat(.GBP)),
            max: .init(amount: 1000000, currency: .GBP),
            min: .init(amount: 500, currency: .GBP),
            isEligible: true,
            isVisible: true
        ),
        priceService: PriceServiceMock()
    )

    let paymentMethodCard = PaymentMethodAccount(
        paymentMethodType: .card(
            CardData(
                ownerName: "John Smith",
                number: "4000 0000 0000 0000",
                expirationDate: "12/30",
                cvv: "000"
            )!
        ),
        paymentMethod: .init(
            type: .card([.visa]),
            max: .init(amount: 120000, currency: .USD),
            min: .init(amount: 500, currency: .USD),
            isEligible: true,
            isVisible: true
        ),
        priceService: PriceServiceMock()
    )

    private func paymentMethodRowModel(for account: PaymentMethodAccount) -> AccountPickerRow.PaymentMethod {
        AccountPickerRow.PaymentMethod(
            id: account.identifier,
            title: account.label,
            description: account.paymentMethodType.balance.displayString,
            badgeView: account.logoResource.image,
            badgeBackground: Color(account.logoBackgroundColor)
        )
    }

    @ViewBuilder private func view(row: AccountPickerRow) -> some View {
        AccountPickerRowView(
            store: Store(
                initialState: row,
                reducer: accountPickerRowReducer,
                environment: environment
            ),
            badgeView: { identifier in
                switch identifier {
                case self.singleAccount.id:
                    let model: BadgeImageViewModel = .default(
                        image: CryptoCurrency.coin(.bitcoin).logoResource,
                        cornerRadius: .round,
                        accessibilityIdSuffix: ""
                    )
                    model.marginOffsetRelay.accept(0)
                    let view = BadgeImageViewRepresentable(viewModel: model, size: 32)
                    return AnyView(view)
                case self.accountGroup.id:
                    let model: BadgeImageViewModel = .primary(
                        image: .local(name: "icon-wallet", bundle: .platformUIKit),
                        cornerRadius: .round,
                        accessibilityIdSuffix: "walletBalance"
                    )
                    model.marginOffsetRelay.accept(0)
                    let view = BadgeImageViewRepresentable(viewModel: model, size: 32)
                    return AnyView(view)
                case self.linkedBankAccountModel.id:
                    let model: BadgeImageViewModel = .default(
                        image: .local(name: "icon-bank", bundle: .platformUIKit),
                        cornerRadius: .round,
                        accessibilityIdSuffix: ""
                    )
                    let view = BadgeImageViewRepresentable(viewModel: model, size: 32)
                    return AnyView(view)
                default:
                    return AnyView(EmptyView())
                }
            },
            iconView: { _ in
                let model: BadgeImageViewModel = .template(
                    image: .local(name: "ic-private-account", bundle: .platformUIKit),
                    templateColor: CryptoCurrency.coin(.bitcoin).brandUIColor,
                    backgroundColor: .white,
                    cornerRadius: .round,
                    accessibilityIdSuffix: ""
                )
                model.marginOffsetRelay.accept(1)
                let view = BadgeImageViewRepresentable(viewModel: model, size: 16)
                return AnyView(view)
            },
            multiBadgeView: { identity in
                guard self.isShowingMultiBadge else { return AnyView(EmptyView()) }

                switch identity {
                case self.linkedBankAccount.identifier:
                    let badges = SingleAccountBadgeFactory(withdrawalService: MockWithdrawalServiceAPI())
                        .badge(account: self.linkedBankAccount, action: .withdraw)
                        .map {
                            MultiBadgeViewModel(
                                layoutMargins: LinkedBankAccountCellPresenter.multiBadgeInsets,
                                height: 24.0,
                                badges: $0
                            )
                        }
                        .asDriver(onErrorJustReturn: .init())
                    let view = MultiBadgeViewRepresentable(viewModel: badges)
                    return AnyView(view)
                case self.singleAccount.id:
                    let model = MultiBadgeViewModel(
                        layoutMargins: UIEdgeInsets(
                            top: 8,
                            left: 72,
                            bottom: 16,
                            right: 24
                        ),
                        height: 24,
                        badges: [
                            DefaultBadgeAssetPresenter.makeLowFeesBadge(),
                            DefaultBadgeAssetPresenter.makeFasterBadge()
                        ]
                    )
                    let view = MultiBadgeViewRepresentable(viewModel: .just(model))
                    return AnyView(view)
                default:
                    return AnyView(EmptyView())
                }
            },
            fiatBalances: fiatBalances,
            cryptoBalances: cryptoBalances,
            currencyCodes: currencyCodes
        )
        .fixedSize()
    }

    func testAccountGroup() {
        let accountGroupRow = AccountPickerRow.accountGroup(
            accountGroup
        )

        assertSnapshot(matching: view(row: accountGroupRow), as: .image)
    }

    func testAccountGroupLoading() {
        fiatBalances = [:]
        currencyCodes = [:]

        let accountGroupRow = AccountPickerRow.accountGroup(
            accountGroup
        )

        assertSnapshot(matching: view(row: accountGroupRow), as: .image)
    }

    func testSingleAccount() {
        let singleAccountRow = AccountPickerRow.singleAccount(
            singleAccount
        )

        assertSnapshot(matching: view(row: singleAccountRow), as: .image)

        isShowingMultiBadge = true

        assertSnapshot(matching: view(row: singleAccountRow), as: .image)
    }

    func testSingleAccountLoading() {
        fiatBalances = [:]
        cryptoBalances = [:]

        let singleAccountRow = AccountPickerRow.singleAccount(
            singleAccount
        )

        assertSnapshot(matching: view(row: singleAccountRow), as: .image)
    }

    func testButton() {
        let buttonRow = AccountPickerRow.button(
            .init(
                id: UUID(),
                text: "+ Add New"
            )
        )

        assertSnapshot(matching: view(row: buttonRow), as: .image)
    }

    func testLinkedAccount() {
        let linkedAccountRow = AccountPickerRow.linkedBankAccount(
            linkedBankAccountModel
        )

        assertSnapshot(matching: view(row: linkedAccountRow), as: .image)

        isShowingMultiBadge = true

        assertSnapshot(matching: view(row: linkedAccountRow), as: .image)
    }

    func testPaymentMethod_funds() {
        let linkedAccountRow = AccountPickerRow.paymentMethodAccount(
            paymentMethodRowModel(for: paymentMethodFunds)
        )
        assertSnapshot(matching: view(row: linkedAccountRow), as: .image)
    }

    func testPaymentMethod_card() {
        let linkedAccountRow = AccountPickerRow.paymentMethodAccount(
            paymentMethodRowModel(for: paymentMethodCard)
        )
        assertSnapshot(matching: view(row: linkedAccountRow), as: .image)
    }
}

struct MockWithdrawalServiceAPI: WithdrawalServiceAPI {

    func withdrawFeeAndLimit(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<WithdrawalFeeAndLimit> {
        .just(.init(
            maxLimit: .zero(currency: currency),
            minLimit: .zero(currency: currency),
            fee: .zero(currency: currency)
        ))
    }

    func withdrawal(
        for checkout: WithdrawalCheckoutData
    ) -> Single<Result<FiatValue, Error>> {
        fatalError("Not implemented")
    }

    func withdrawalFee(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        fatalError("Not implemented")
    }

    func withdrawalMinAmount(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        fatalError("Not implemented")
    }
}

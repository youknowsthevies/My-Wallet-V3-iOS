// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureOpenBankingDomain
import Foundation
import UIComponentsKit

extension ApproveState.UI {

    static func model(
        for data: OpenBanking.Data,
        in environment: OpenBankingEnvironment
    ) -> ApproveState.UI {

        let expiry = Calendar.current.date(byAdding: DateComponents(day: 90), to: Date())
            .map(DateFormatter.long.string(from:)) ?? Localization.Approve.Payment.in90Days

        let bankAccount = data.account
        switch data.action {
        case .link(let institution):
            return .init(
                title: bankAccount.attributes.entity,
                tasks: [
                    termsAndConditions(
                        entity: bankAccount.attributes.entity,
                        bankName: institution.name,
                        expiry: expiry
                    )
                    .padding()
                ]
            )

        case .confirm(let order):
            guard let currency = bankAccount.currency,
                  let amount = environment.fiatCurrencyFormatter.displayString(
                      amountMinor: order.inputQuantity,
                      currency: currency
                  )
            else {
                return .init(title: Localization.Error.title, tasks: [])
            }
            return payment(
                of: amount,
                expires: expiry,
                from: bankAccount
            )
        case .deposit(let amountMinor, _):
            guard let currency = bankAccount.currency,
                  let amount = environment.fiatCurrencyFormatter.displayString(
                      amountMinor: amountMinor,
                      currency: currency
                  )
            else {
                return .init(title: Localization.Error.title, tasks: [])
            }
            return payment(
                of: amount,
                expires: expiry,
                from: bankAccount
            )
        }
    }

    private static func payment(
        of amount: String,
        expires expiry: String,
        from bankAccount: OpenBanking.BankAccount
    ) -> ApproveState.UI {
        let details = bankAccount.details
        guard let bankName = details?.bankName,
              let sortCode = details?.sortCode,
              let accountNumber = details?.accountNumber
        else {
            return .init(title: Localization.Error.title, tasks: [])
        }

        let header = Task.group(
            Task.label(Localization.Approve.Payment.approveYourPayment)
                .typography(.title3),
            Task.spacer(4.vmin),
            Task.group(
                Task.divider(),
                Task.row(Localization.Approve.Payment.paymentTotal, value: amount)
                    .padding([.top, .bottom], 8.pt),
                Task.divider()
            ),
            Task.spacer(4.vmin)
        )

        let information = Task.section(
            header: Localization.Approve.Payment.paymentInformation,
            expandable: true,
            tasks: [
                Task.row(Localization.Approve.Payment.bankName, value: "\(bankName)"),
                Task.row(Localization.Approve.Payment.sortCode, value: "\(sortCode)"),
                Task.row(Localization.Approve.Payment.accountNumber, value: "\(accountNumber)")
            ]
        )

        return .init(
            title: bankAccount.attributes.entity,
            tasks: [
                Task.group(
                    header,
                    information
                )
                .padding(),
                Task.spacer(4.vmin),
                termsAndConditions(
                    entity: bankAccount.attributes.entity,
                    bankName: bankAccount.details?.bankName ?? Localization.Approve.Payment.bank,
                    expiry: expiry
                )
                .padding()
            ]
        )
    }

    static func termsAndConditions(
        entity: String,
        bankName: String,
        expiry: String
    ) -> Task {
        .group(
            .section(
                header: Localization.Approve.TermsAndConditions.dataSharing,
                expandable: true,
                tasks: [
                    .label(Localization.Approve.TermsAndConditions.dataSharingBody.interpolating(entity))
                ]
            ),
            .section(
                header: Localization.Approve.TermsAndConditions.secureConnection,
                expandable: true,
                tasks: [
                    .label(Localization.Approve.TermsAndConditions.secureConnectionBody)
                ]
            ),
            .section(
                header: Localization.Approve.TermsAndConditions.FCAAuthorisation,
                expandable: true,
                tasks: [
                    .label(
                        Localization.Approve.TermsAndConditions.FCAAuthorisationBody1.interpolating(entity, entity)
                    ),
                    .label(
                        Localization.Approve.TermsAndConditions.FCAAuthorisationBody2.interpolating(bankName, entity)
                    )
                ]
            ),
            .section(
                header: Localization.Approve.TermsAndConditions.aboutTheAccess,
                expandable: true,
                tasks: [
                    .label(Localization.Approve.TermsAndConditions.aboutTheAccessBody.interpolating(entity, expiry))
                ]
            )
        )
        .typography(.paragraph1)
        .foreground(.textDetail)
    }
}

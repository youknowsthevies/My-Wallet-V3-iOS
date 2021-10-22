// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import OpenBanking
import UIComponentsKit

extension ApproveState.UI {

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    static func model(
        _ bankAccount: OpenBanking.BankAccount,
        for action: BankState.Action,
        in environment: OpenBankingEnvironment
    ) -> ApproveState.UI {

        let _90days = DateComponents(day: 90)
        let expiry = Calendar.current.date(byAdding: _90days, to: Date())
            .map(dateFormatter.string(from:)) ?? R.Approve.Payment.in90Days

        switch action {
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

        case .pay(let amountMinor, _):
            let details = bankAccount.details
            guard let bankName = details?.bankName,
                  let sortCode = details?.sortCode,
                  let accountNumber = details?.accountNumber,
                  let currency = bankAccount.currency,
                  let amount = environment.fiatCurrencyFormatter.displayString(
                      amountMinor: amountMinor,
                      currency: currency
                  )
            else {
                return .init(title: R.Error.title, tasks: [])
            }

            let header = Task.group(
                Task.label(R.Approve.Payment.approveYourPayment)
                    .typography(.title3),
                Task.spacer(4.vmin),
                Task.group(
                    Task.divider(),
                    Task.row(R.Approve.Payment.paymentTotal, value: amount)
                        .padding([.top, .bottom], 8.pt),
                    Task.divider()
                ),
                Task.spacer(4.vmin)
            )

            let information = Task.section(
                header: R.Approve.Payment.paymentInformation,
                expandable: true,
                tasks: [
                    Task.row(R.Approve.Payment.bankName, value: "\(bankName)"),
                    Task.row(R.Approve.Payment.sortCode, value: "\(sortCode)"),
                    Task.row(R.Approve.Payment.accountNumber, value: "\(accountNumber)")
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
                        bankName: bankAccount.details?.bankName ?? R.Approve.Payment.bank,
                        expiry: expiry
                    )
                    .padding()
                ]
            )
        }
    }

    static func termsAndConditions(
        entity: String,
        bankName: String,
        expiry: String
    ) -> Task {
        .group(
            .section(
                header: R.Approve.TermsAndConditions.dataSharing,
                expandable: true,
                tasks: [
                    .label(R.Approve.TermsAndConditions.dataSharingBody.interpolating(entity))
                ]
            ),
            .section(
                header: R.Approve.TermsAndConditions.secureConnection,
                expandable: true,
                tasks: [
                    .label(R.Approve.TermsAndConditions.secureConnectionBody)
                ]
            ),
            .section(
                header: R.Approve.TermsAndConditions.FCAAuthorisation,
                expandable: true,
                tasks: [
                    .label(R.Approve.TermsAndConditions.FCAAuthorisationBody1.interpolating(entity, entity)),
                    .label(R.Approve.TermsAndConditions.FCAAuthorisationBody2.interpolating(bankName, entity))
                ]
            ),
            .section(
                header: R.Approve.TermsAndConditions.aboutTheAccess,
                expandable: true,
                tasks: [
                    .label(R.Approve.TermsAndConditions.aboutTheAccessBody.interpolating(entity, expiry))
                ]
            )
        )
        .typography(.paragraph1)
        .foreground(.textDetail)
    }
}

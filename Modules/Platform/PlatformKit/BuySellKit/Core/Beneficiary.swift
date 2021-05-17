// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct Beneficiary {
    public enum AccountType: Equatable {
        case funds
        case linkedBank
    }
    public let type: AccountType
    public let currency: FiatCurrency
    public let name: String
    public let identifier: String
    public let account: String
    public let limit: FiatValue?

    init?(response: BeneficiaryResponse, limit: FiatValue?) {
        self.type = .funds
        self.identifier = response.id
        self.name = response.name
        var address = response.address
        address.removeAll { $0 == "*" }
        self.account = address
        self.limit = limit
        guard let currency = FiatCurrency(code: response.currency) else {
            return nil
        }
        self.currency = currency
    }

    init(linkedBankData: LinkedBankData) {
        self.identifier = linkedBankData.identifier
        self.currency = linkedBankData.currency
        self.type = .linkedBank
        let bankName = linkedBankData.account?.bankName ?? ""
        let accountType = linkedBankData.account?.type.title ?? ""
        let accountNumber = linkedBankData.account?.number ?? ""
        self.name = "\(bankName)"
        self.account = "\(accountType) \(accountNumber)"
        self.limit = nil
    }
}

extension Beneficiary: Equatable {
    public static func == (lhs: Beneficiary, rhs: Beneficiary) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

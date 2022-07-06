// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct PaymentAccount {
    public struct Response: Decodable {
        struct Agent: Decodable {
            let account: String?
            let accountType: String?
            let address: String?
            let code: String?
            let country: String?
            let name: String?
            let recipient: String?
            let routingNumber: String?
            let label: String?
            let holderDocument: String?
            let bankName: String?

            init(
                account: String?,
                accountType: String? = nil,
                address: String?,
                code: String?,
                country: String?,
                name: String?,
                recipient: String?,
                routingNumber: String?,
                label: String? = nil,
                holderDocument: String? = nil,
                bankName: String? = nil
            ) {
                self.account = account
                self.accountType = accountType
                self.address = address
                self.code = code
                self.country = country
                self.name = name
                self.recipient = recipient
                self.routingNumber = routingNumber
                self.label = label
                self.holderDocument = holderDocument
                self.bankName = bankName
            }
        }

        let id: String
        let address: String
        let agent: Agent
        let currency: CurrencyType
        let state: PaymentAccountProperty.State
        let partner: String?

        enum CodingKeys: String, CodingKey {
            case currency
            case id
            case agent
            case state
            case address
            case partner
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let value = try values.decode(String.self, forKey: .currency)
            currency = try CurrencyType(code: value)
            id = try values.decode(String.self, forKey: .id)
            address = try values.decode(String.self, forKey: .address)
            agent = try values.decode(Agent.self, forKey: .agent)
            state = try values.decode(PaymentAccountProperty.State.self, forKey: .state)
            partner = try values.decodeIfPresent(String.self, forKey: .partner)
        }

        init(
            id: String,
            address: String,
            agent: Agent,
            currency: CurrencyType,
            state: PaymentAccountProperty.State,
            partner: String? = nil
        ) {
            self.id = id
            self.address = address
            self.agent = agent
            self.currency = currency
            self.state = state
            self.partner = partner
        }

        public var account: PaymentAccount {
            .init(response: self)
        }
    }

    public struct Agent {
        public let account: String?
        public let accountType: String?
        public let address: String?
        public let code: String?
        public let country: String?
        public let name: String?
        public let recipient: String?
        public let routingNumber: String?
        public let label: String?
        public let holderDocument: String?
        public let bankName: String?

        init(agent: Response.Agent) {
            account = agent.account
            accountType = agent.accountType
            address = agent.address
            code = agent.code
            country = agent.country
            name = agent.name
            recipient = agent.recipient
            routingNumber = agent.routingNumber
            label = agent.label
            holderDocument = agent.holderDocument
            bankName = agent.bankName
        }
    }

    public let id: String
    public let address: String
    public let agent: Agent
    public let currency: CurrencyType
    public let state: PaymentAccountProperty.State
    public let partner: String?

    init(response: Response) {
        id = response.id
        address = response.address
        agent = .init(agent: response.agent)
        currency = response.currency
        state = response.state
        partner = response.partner
    }
}

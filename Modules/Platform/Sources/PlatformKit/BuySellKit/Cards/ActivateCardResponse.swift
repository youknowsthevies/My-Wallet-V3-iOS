// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct ActivateCardResponse: Decodable {

    public enum Partner {
        public struct EveryPayData: Decodable {
            let apiUsername: String
            let mobileToken: String
            let paymentLink: String
            let paymentState: String
        }

        case everypay(EveryPayData)
        case cardAcquirer(CardAcquirer)
        case unknown

        var isKnown: Bool {
            switch self {
            case .unknown:
                return false
            default:
                return true
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case everypay
        case cardProvider
    }

    public struct CardAcquirer: Decodable {
        let cardAcquirerName: CardPayload.Partner
        let cardAcquirerAccountCode: String
        let apiUserID: String?
        let apiToken: String?
        let paymentLink: String?
        let paymentState: OrderPayload.Response.Attributes.PaymentState
        let paymentReference: String?
        let orderReference: String?
        let clientSecret: String?
        let publishableKey: String?

        public init(
            cardAcquirerName: CardPayload.Partner,
            cardAcquirerAccountCode: String,
            apiUserID: String?,
            apiToken: String?,
            paymentLink: String?,
            paymentState: String,
            paymentReference: String?,
            orderReference: String?,
            clientSecret: String?,
            publishableKey: String?
        ) {
            self.cardAcquirerName = cardAcquirerName
            self.cardAcquirerAccountCode = cardAcquirerAccountCode
            self.apiUserID = apiUserID
            self.apiToken = apiToken
            self.paymentLink = paymentLink
            self.paymentState = .init(rawValue: paymentState) ?? .unknown
            self.paymentReference = paymentReference
            self.orderReference = orderReference
            self.clientSecret = clientSecret
            self.publishableKey = publishableKey
        }
    }

    let partner: Partner

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let acquirer = try values.decodeIfPresent(CardAcquirer.self, forKey: .cardProvider)

        if let data = try values.decodeIfPresent(Partner.EveryPayData.self, forKey: .everypay) {
            partner = .everypay(data)
        } else if let acquirer = acquirer {
            partner = .cardAcquirer(acquirer)
        } else {
            partner = .unknown
        }
    }
}

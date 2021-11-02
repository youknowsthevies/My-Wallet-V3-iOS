// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import ToolKit

final class InterestActivityItemEventService: InterestActivityItemEventServiceAPI {

    // MARK: - Private Properties

    private let client: InterestActivityItemEventClientAPI

    // MARK: - Init

    init(client: InterestActivityItemEventClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - InterestActivityItemEventServiceAPI

    func fetchInterestActivityItemEventsForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<[InterestActivityItemEvent], InterestActivityServiceError> {
        client
            .fetchInterestActivityItemEventsForCryptoCurrency(
                cryptoCurrency
            )
            .mapError(InterestActivityServiceError.networkError)
            .map(\.items)
            .map { items in
                items.map { response in
                    InterestActivityItemEvent(
                        response,
                        currency: cryptoCurrency
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}

extension InterestActivityItemEvent {
    init(
        _ response: InterestActivityItemEventResponse,
        currency: CryptoCurrency
    ) {
        self.init(
            value: .create(minor: response.amountMinor, currency: currency) ?? .zero(currency: currency),
            cryptoCurrency: currency,
            identifier: response.identifier,
            insertedAt: DateFormatter.iso8601Format.date(from: response.insertedAt) ?? Date(),
            state: InterestActivityItemEvent.interestStateFromResponseState(response.state),
            type: InterestActivityItemEvent.transactionTypeFromString(response.type)
        )
    }

    private static func interestStateFromResponseState(
        _ state: InterestActivityItemEventResponse.State
    ) -> InterestActivityItemEventState {
        switch state {
        case .cleared:
            return .cleared
        case .failed:
            return .failed
        case .rejected:
            return .rejected
        case .processing:
            return .processing
        case .complete,
             .created:
            return .complete
        case .pending:
            return .pending
        case .manualReview:
            return .manualReview
        case .refunded:
            return .refunded
        case .unknown:
            return .unknown
        }
    }

    private static func transactionTypeFromString(
        _ value: String
    ) -> InterestTransactionType {
        switch value {
        case "DEPOSIT":
            return .transfer
        case "WITHDRAW":
            return .withdraw
        case "INTEREST_OUTGOING":
            return .interestEarned
        default:
            return .unknown
        }
    }
}

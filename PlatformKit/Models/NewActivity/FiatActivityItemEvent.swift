//
//  FiatActivityItemEvent.swift
//  PlatformKit
//
//  Created by Alex McGregor on 7/29/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct FiatActivityItemEvent: Decodable, Tokenized {
    
    enum FiatActivityItemEventError: Error {
        case decodingError
    }
    
    public var token: String {
        identifier
    }
    
    public let identifier: String
    public let status: EventStatus
    public let date: Date
    public let fiatValue: FiatValue
    public let type: EventType
    
    public enum EventStatus: String {
        case complete = "COMPLETE"
        case created = "CREATED"
        case pending = "PENDING"
        case unidentified = "UNIDENTIFIED"
        case failed = "FAILED"
        case fraudReview = "FRAUD_REVIEW"
        case cleared = "CLEARED"
        case rejected = "REJECTED"
        case manualReview = "MANUAL_REVIEW"
        case refunded = "REFUNDED"
    }
    
    public enum EventType: String {
        case deposit = "DEPOSIT"
        case withdrawal = "WITHDRAWAL"
        case unknown = "UNKNOWN"
    }
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case status = "state"
        case date = "insertedAt"
        case type
        case amount
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let eventDate = try values.decode(String.self, forKey: .date)
        let formatter = DateFormatter.sessionDateFormat
        let legacyFormatter = DateFormatter.iso8601Format
        
        /// There seems to be some inconsistancies with the date formatter here.
        if let value = formatter.date(from: eventDate) {
            date = value
        } else if let value = legacyFormatter.date(from: eventDate) {
            date = value
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .date,
                in: values,
                debugDescription: "Date string does not match format expected by formatter."
            )
        }
        
        identifier = try values.decode(String.self, forKey: .identifier)
        let statusValue = try values.decode(String.self, forKey: .status)
        status = EventStatus(rawValue: statusValue) ?? .unidentified
        let fiatValueContainer = try values.decode(SymbolValue.self, forKey: .amount)
        guard let fiatCurrency = FiatCurrency(code: fiatValueContainer.symbol) else {
            throw FiatActivityItemEventError.decodingError
        }
        
        fiatValue = FiatValue.create(amountString: fiatValueContainer.value, currency: fiatCurrency)
        let eventValue = try values.decode(String.self, forKey: .type)
        type = EventType(rawValue: eventValue) ?? .unknown
    }
}

extension FiatActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension FiatActivityItemEvent: Equatable {
    public static func == (lhs: FiatActivityItemEvent, rhs: FiatActivityItemEvent) -> Bool {
            lhs.identifier == rhs.identifier &&
            lhs.status == rhs.status &&
            lhs.date == rhs.date &&
            lhs.fiatValue == rhs.fiatValue
    }
}

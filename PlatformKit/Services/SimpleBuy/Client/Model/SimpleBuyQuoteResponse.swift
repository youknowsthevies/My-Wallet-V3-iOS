//
//  SimpleBuyQuoteResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SimpleBuyQuoteResponse: Decodable {
    let time: String
}

public struct SimpleBuyQuote {
    
    // MARK: - Types
    
    enum SetupError: Error {
        case dateFormatting
    }
    
    // MARK: - Properties
    
    public let time: Date
    
    private let dateFormatter = DateFormatter.sessionDateFormat
    
    // MARK: - Setup
    
    init(response: SimpleBuyQuoteResponse) throws {
        guard let time = dateFormatter.date(from: response.time) else {
            throw SetupError.dateFormatting
        }
        self.time = time
    }
}

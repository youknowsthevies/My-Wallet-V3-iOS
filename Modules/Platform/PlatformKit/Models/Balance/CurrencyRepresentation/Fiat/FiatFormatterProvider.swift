//
//  FiatFormatterProvider.swift
//  PlatformKit
//
//  Created by Jack Pooley on 20/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class FiatFormatterProvider {

    static let shared = FiatFormatterProvider()

    private var formatterMap = [String: NumberFormatter]()
    private let queue = DispatchQueue(label: "FiatFormatterProvider.queue")

    /// Returns `NumberFormatter`. This method executes on a dedicated queue.
    func formatter(locale: Locale, fiatValue: FiatValue, maxFractionDigits: Int) -> NumberFormatter {
        var formatter: NumberFormatter!
        queue.sync { [unowned self] in
            let mapKey = key(locale: locale, fiatValue: fiatValue)
            if let matchingFormatter = formatterMap[mapKey] {
                matchingFormatter.maximumFractionDigits = maxFractionDigits
                formatter = matchingFormatter
            } else {
                formatter = NumberFormatter(
                    locale: locale,
                    currencyCode: fiatValue.currency.code,
                    maxFractionDigits: maxFractionDigits
                )
                self.formatterMap[mapKey] = formatter
            }
            
        }
        return formatter
    }

    private func key(locale: Locale, fiatValue: FiatValue) -> String {
        "\(locale.identifier)_\(fiatValue.currency.code)"
    }
}

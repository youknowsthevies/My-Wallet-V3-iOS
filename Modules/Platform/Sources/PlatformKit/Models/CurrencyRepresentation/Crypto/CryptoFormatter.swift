// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A precision level for formatting a `CryptoValue` into a `String`.
public enum CryptoPrecision {

    /// The currency's display precision.
    case short

    /// The currency's full precision.
    case long
}

public final class CryptoFormatterProvider {

    /// A singleton value.
    public static let shared = CryptoFormatterProvider()

    // MARK: - Private Properties

    private var formatters = [String: CryptoFormatter]()

    /// Dispatch queue used for thread safe access to `formatters`.
    private let queue = DispatchQueue(label: "CryptoFormatterProvider.queue.\(UUID().uuidString)")

    // MARK: - Public Methods

    /// Returns a `CryptoFormatter`.
    ///
    /// Provides caching for the existing crypto formatters, with thread safe access.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - cryptoCurrency:    A crypto currency.
    ///   - minFractionDigits: The minimum number of digits after the decimal separator.
    public func formatter(
        locale: Locale,
        cryptoCurrency: CryptoCurrency,
        minFractionDigits: Int = 1
    ) -> CryptoFormatter {
        queue.sync { [unowned self] in
            let key = key(locale: locale, cryptoCurrency: cryptoCurrency, minFractionDigits: minFractionDigits)
            if let formatter = self.formatters[key] {
                return formatter
            } else {
                let formatter = CryptoFormatter(
                    locale: locale,
                    cryptoCurrency: cryptoCurrency,
                    minFractionDigits: minFractionDigits
                )
                self.formatters[key] = formatter

                return formatter
            }
        }
    }

    // MARK: - Private Methods

    /// Creates a caching key.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - fiatCurrency:      A crypto currency.
    ///   - minFractionDigits: The minimum number of digits after the decimal separator.
    private func key(locale: Locale, cryptoCurrency: CryptoCurrency, minFractionDigits: Int) -> String {
        "\(locale.identifier)_\(cryptoCurrency.displayCode)_\(minFractionDigits)"
    }
}

public final class CryptoFormatter {

    // MARK: - Private Properties

    /// The number formatter using the currency's `displayableDecimalPlaces`.
    private let shortFormatter: NumberFormatter

    /// The number formatter using the currency's `decimalPlaces`.
    private let longFormatter: NumberFormatter

    /// The associated crypto currency.
    private let cryptoCurrency: CryptoCurrency

    // MARK: - Setup

    /// Creates a crypto formatter.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - cryptoCurrency:    A crypto currency
    ///   - minFractionDigits: The minimum number of digits after the decimal separator.
    public init(locale: Locale, cryptoCurrency: CryptoCurrency, minFractionDigits: Int) {
        shortFormatter = NumberFormatter.cryptoFormatter(
            locale: locale,
            minFractionDigits: minFractionDigits,
            maxFractionDigits: cryptoCurrency.displayPrecision
        )
        longFormatter = NumberFormatter.cryptoFormatter(
            locale: locale,
            minFractionDigits: minFractionDigits,
            maxFractionDigits: cryptoCurrency.precision
        )
        self.cryptoCurrency = cryptoCurrency
    }

    // MARK: - Public Methods

    /// Returns a string containing the formatted crypto value, optionally including the symbol.
    ///
    /// - Parameters:
    ///   - value:         A crypto value.
    ///   - precision:     A precision level.
    ///   - includeSymbol: Whether the symbol should be included.
    public func format(
        value: CryptoValue,
        withPrecision precision: CryptoPrecision = .short,
        includeSymbol: Bool = false
    ) -> String {
        let formatter = (precision == .short) ? shortFormatter : longFormatter
        var formattedString = formatter.string(from: NSDecimalNumber(decimal: value.displayMajorValue)) ?? "\(value.displayMajorValue)"
        if includeSymbol {
            formattedString += " " + value.displayCode
        }
        return formattedString
    }
}

extension NumberFormatter {

    /// Creates a crypto number formatter.
    ///
    /// - Parameters:
    ///   - locale:            A locale.
    ///   - minFractionDigits: The minimum number of digits after the decimal separator.
    ///   - maxFractionDigits: The maximum number of digits after the decimal separator.
    static func cryptoFormatter(locale: Locale, minFractionDigits: Int, maxFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.roundingMode = .down
        return formatter
    }
}

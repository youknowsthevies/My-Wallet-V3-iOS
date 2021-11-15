import Foundation

extension LocalizationConstants {
    public enum BuyButton {}
}

extension LocalizationConstants.BuyButton {
    public static let buyCrypto = NSLocalizedString("Buy Crypto", comment: "Buy generic from Buy Button")
    public static func buy(cryptoName: String) -> String {
        String(
            format: NSLocalizedString("Buy %@", comment: "Buy specific asset from Buy Button"),
            cryptoName
        )
    }
}

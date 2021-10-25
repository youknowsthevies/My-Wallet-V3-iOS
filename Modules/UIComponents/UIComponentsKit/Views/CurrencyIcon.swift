// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct CurrencyIcon: View {
    public enum Image: Hashable {
        case remote(String)
        case image(SwiftUI.Image)
        case local(name: String, bundle: Bundle)
        case template(name: String, bundle: Bundle, foregroundColor: Color)
        case symbol(String)

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .remote(let url):
                hasher.combine(url)
            case .image:
                hasher.combine(UUID())
            case .local(name: let name, bundle: _):
                hasher.combine(name)
            case .symbol(let symbol):
                hasher.combine(symbol)
            case .template(name: let name, bundle: _, foregroundColor: _):
                hasher.combine(name)
            }
        }
    }

    private let icon: CurrencyIcon.Image

    // Return a symbol ie, "$" from code like "USD"
    private func currencySymbol(for code: String) -> String {
        let locale = NSLocale(localeIdentifier: "en-US")

        if code == "TRY" {
            return "₺"
        }

        let symbol = locale.displayName(forKey: .currencySymbol, value: code) ?? code
        return symbol.trimmingCharacters(in: .symbols.inverted)
    }

    public init(icon: CurrencyIcon.Image) {
        self.icon = icon
    }

    public var body: some View {
        switch icon {
        case .remote(let url):
            if let url = URL(string: url) {
                ImageResourceView(
                    url: url,
                    placeholder: Color.viewPrimaryBackground
                )
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }
        case .template(let name, let bundle, let foregroundColor):
            SwiftUI.Image(name, bundle: bundle)
                .renderingMode(.template)
                .foregroundColor(foregroundColor)
                .frame(width: 32, height: 32)
                .clipShape(Circle())

        case .image(let image):
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 32)
        case .local(let name, let bundle):
            SwiftUI.Image(name, bundle: bundle)
                .frame(width: 32, height: 32)
                .clipShape(Circle())

        case .symbol(let symbol):
            Rectangle()
                .fill(Color.backgroundFiat)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(currencySymbol(for: symbol))
                        // TODO: Adjust this font
                        .font(.init(weight: .semibold, size: 24.0))
                        .foregroundColor(Color.white)
                        .frame(width: 32, height: 32)
                )
        }
    }
}

struct TokenIcon_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyIcon(icon: .image(Image.Logo.blockchain))
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct Typography: Hashable, Codable {
    public let name: String
    public var size: Length
    public var style: TextStyle
    public var design: Design = .default
    public var weight: FontWeight = .bold
}

// https://www.figma.com/file/dvXlzvYoDEulsmwkE8iO0i/02---Assets-%7C-Typography?node-id=0%3A1
extension Typography {

    public static let display: Typography = .init(
        name: "Display",
        size: 40.pt,
        style: .largeTitle,
        weight: .semibold
    )

    public static let title1: Typography = .init(
        name: "Title 1",
        size: 32.pt,
        style: .title,
        weight: .semibold
    )

    public static let title2: Typography = .init(
        name: "Title 2",
        size: 24.pt,
        style: .title2,
        weight: .semibold
    )

    public static let title3: Typography = .init(
        name: "Title 3",
        size: 20.pt,
        style: .title3,
        weight: .semibold
    )

    public static let subheading: Typography = .init(
        name: "Subheading",
        size: 20.pt,
        style: .subheadline,
        weight: .medium
    )

    public static let bodyMono: Typography = .init(
        name: "Body Mono",
        size: 16.pt,
        style: .body,
        design: .monospaced,
        weight: .medium
    )

    public static let body1: Typography = .init(
        name: "Body 1",
        size: 16.pt,
        style: .body,
        weight: .medium
    )

    public static let body2: Typography = .init(
        name: "Body 2",
        size: 16.pt,
        style: .body,
        weight: .semibold
    )

    public static let paragraphMono: Typography = .init(
        name: "Paragraph Mono",
        size: 16.pt,
        style: .body,
        design: .monospaced,
        weight: .medium
    )

    public static let paragraph1: Typography = .init(
        name: "Paragraph 1",
        size: 14.pt,
        style: .body,
        weight: .medium
    )

    public static let paragraph2: Typography = .init(
        name: "Paragraph 2",
        size: 14.pt,
        style: .body,
        weight: .semibold
    )

    public static let caption1: Typography = .init(
        name: "Caption 1",
        size: 12.pt,
        style: .caption,
        weight: .medium
    )

    public static let caption2: Typography = .init(
        name: "Caption 2",
        size: 12.pt,
        style: .caption,
        weight: .semibold
    )

    public static let overline: Typography = .init(
        name: "Overline",
        size: 12.pt,
        style: .caption,
        weight: .bold
    )
}

extension View {

    public func typography(_ typography: Typography) -> some View {
        modifier(typography)
    }

    @ViewBuilder public func typography(_ typography: Typography?) -> some View {
        if let typography = typography {
            modifier(typography)
        } else {
            self
        }
    }
}

extension Typography {

    public func bold() -> Typography {
        weight(.bold)
    }

    public func semibold() -> Typography {
        weight(.semibold)
    }

    public func medium() -> Typography {
        weight(.medium)
    }

    public func regular() -> Typography {
        weight(.regular)
    }

    fileprivate func weight(_ weight: FontWeight) -> Typography {
        var copy = self
        copy.weight = weight
        return copy
    }
}

// swiftlint:disable switch_case_on_newline

extension Typography: ViewModifier {

    var fontName: String {
        switch weight {
        case .regular: return "Inter-Regular"
        case .medium: return "Inter-Medium"
        case .semibold: return "Inter-SemiBold"
        case .bold: return "Inter-Bold"
        }
    }

    var font: Font {
        UIFont.loadCustomFonts()
        let size = size.in(UIScreen.main.bounds)
        switch design {
        case .default, .serif:
            return Font.custom(fontName, size: size, relativeTo: style.ui)
        case .monospaced:
            guard let descriptor = UIFont(name: fontName, size: size)?.fontDescriptor else {
                return Font.system(size: size, weight: .medium, design: design.ui)
            }
            let monospaced = descriptor.addingAttributes(
                [
                    .featureSettings: [
                        [
                            UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                            UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
                        ]
                    ]
                ]
            )
            return Font(UIFont(descriptor: monospaced, size: size) as CTFont)
        }
    }

    public func body(content: Content) -> some View {
        content.font(font)
    }
}

extension Typography: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String { name }
    public var debugDescription: String {
        "\(name) \(size): \(style) \(design) \(weight)"
    }
}

extension Typography {

    public enum TextStyle: String, Codable, Hashable {

        case largeTitle
        case title
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption
        case caption2

        public var ui: Font.TextStyle {
            switch self {
            case .largeTitle: return .largeTitle
            case .title: return .title
            case .title2: return .title2
            case .title3: return .title3
            case .headline: return .headline
            case .subheadline: return .subheadline
            case .body: return .body
            case .callout: return .callout
            case .footnote: return .footnote
            case .caption: return .caption
            case .caption2: return .caption2
            }
        }
    }

    public enum Design: String, Codable, Hashable {

        case `default`
        case serif
        case monospaced

        public var ui: Font.Design {
            switch self {
            case .default: return .default
            case .serif: return .serif
            case .monospaced: return .monospaced
            }
        }
    }
}

#if DEBUG
struct Typography_Previews: PreviewProvider {

    static let allTypography: [Typography] = [
        .display,
        .title1,
        .title2,
        .title3,
        .subheading,
        .bodyMono,
        .body1,
        .body2,
        .paragraphMono,
        .paragraph1,
        .paragraph2,
        .caption1,
        .caption2,
        .overline
    ]

    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(allTypography, id: \.self) { typography in
                    Text(typography.name)
                        .typography(typography)
                    Text("\(typography.weight.rawValue) \(typography.size.description)")
                        .typography(.caption1.weight(typography.weight))
                    Text("The quick brown fox jumps over the lazy dog")
                        .typography(typography)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    Divider()
                }
            }
            .padding()
        }
    }
}
#endif

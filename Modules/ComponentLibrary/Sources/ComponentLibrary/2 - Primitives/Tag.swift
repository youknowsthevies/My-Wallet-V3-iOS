// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// Contained text used for informational data such as dates or warnings.
///
/// # Figma
///
/// [Tag](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=212%3A5974)
public struct Tag: View {
    private let text: String
    private let variant: Variant

    /// Create a tag view
    /// - Parameters:
    ///   - text: Text displayed in the tag
    ///   - variant: Color variant. See `extension Tag.Variant` below for options.
    public init(text: String, variant: Variant = .default) {
        self.text = text
        self.variant = variant
    }

    public var body: some View {
        Text(text)
            .typography(.caption2)
            .foregroundColor(variant.textColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(variant.backgroundColor)
            )
    }

    /// Style variant for Tag
    public struct Variant {
        fileprivate let backgroundColor: Color
        fileprivate let textColor: Color
    }
}

extension Tag.Variant {
    public static let `default` = Tag.Variant(
        backgroundColor: .init(light: .semantic.light, dark: .palette.dark600),
        textColor: .init(light: .semantic.title, dark: .semantic.title)
    )

    // infoalt
    public static let infoAlt = Tag.Variant(
        backgroundColor: .init(light: .palette.blue000, dark: .palette.dark600),
        textColor: .init(light: .semantic.primary, dark: .semantic.primary)
    )

    // success
    public static let success = Tag.Variant(
        backgroundColor: .init(light: .palette.green100, dark: .semantic.success),
        textColor: .init(light: .semantic.success, dark: .palette.dark900)
    )

    // warning
    public static let warning = Tag.Variant(
        backgroundColor: .init(light: .palette.orange100, dark: .semantic.warning),
        textColor: .init(light: .palette.orange600, dark: .palette.dark900)
    )

    // error
    public static let error = Tag.Variant(
        backgroundColor: .init(light: .palette.red100, dark: .semantic.error),
        textColor: .init(light: .semantic.error, dark: .palette.dark900)
    )
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Tag(text: "Informational")

            Tag(text: "Informational")
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Default")

        VStack {
            Tag(text: "Info Alt", variant: .infoAlt)

            Tag(text: "Info Alt", variant: .infoAlt)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("InfoAlt")

        VStack {
            Tag(text: "Success", variant: .success)

            Tag(text: "Success", variant: .success)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Success")

        VStack {
            Tag(text: "Warning", variant: .warning)

            Tag(text: "Warning", variant: .warning)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Warning")

        VStack {
            Tag(text: "Error", variant: .error)

            Tag(text: "Error", variant: .error)
                .colorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Error")
    }
}

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct TextStyle: ViewModifier {
    
    public enum FontStyle {
        case title
        case heading
        case subheading
        case body
        case formField
    }
    
    public let fontStyle: FontStyle
    
    public func body(content: Content) -> some View {
        let textColor: Color
        let fontWeight: FontWeight
        let fontSize: CGFloat
        let lineSpacing: CGFloat
        
        switch fontStyle {
        case .title:
            textColor = .textTitle
            fontWeight = .semibold
            fontSize = LayoutConstants.Text.FontSize.title
            lineSpacing = LayoutConstants.Text.LineSpacing.title
        case .heading:
            textColor = .textHeading
            fontWeight = .semibold
            fontSize = LayoutConstants.Text.FontSize.heading
            lineSpacing = LayoutConstants.Text.LineSpacing.heading
        case .subheading:
            textColor = .textSubheading
            fontWeight = .medium
            fontSize = LayoutConstants.Text.FontSize.subheading
            lineSpacing = LayoutConstants.Text.LineSpacing.subheading
        case .body:
            textColor = .textBody
            fontWeight = .medium
            fontSize = LayoutConstants.Text.FontSize.body
            lineSpacing = LayoutConstants.Text.LineSpacing.body
        case .formField:
            textColor = .formField
            fontWeight = .regular
            fontSize = LayoutConstants.Text.FontSize.formField
            lineSpacing = LayoutConstants.Text.LineSpacing.formField
        }
        return content
            .font(Font(weight: fontWeight, size: fontSize))
            .foregroundColor(textColor)
            .lineSpacing(lineSpacing) // to mimic line height in the designs
            .padding(.vertical, lineSpacing / 2) // to mimic line height on single line
    }
}

extension TextStyle {
    
    public static let title = TextStyle(fontStyle: .title)
    public static let heading = TextStyle(fontStyle: .heading)
    public static let subheading = TextStyle(fontStyle: .subheading)
    public static let body = TextStyle(fontStyle: .body)
    public static let formField = TextStyle(fontStyle: .formField)
}

extension View {
    
    public func textStyle(_ style: TextStyle) -> some View {
        self.modifier(style)
    }
}

#if DEBUG
struct TextStyle_Previews: PreviewProvider {
    
    static let shortSentence = "Almost before we knew it, we had left the ground."
    // swiftlint:disable line_length
    static let mediumSentence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec condimentum id lacus vitae lacinia. Morbi accumsan lorem eu mauris rhoncus facilisis. Integer ut consectetur massa."
    // swiftlint:disable line_length
    static let longSentence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec condimentum id lacus vitae lacinia. Morbi accumsan lorem eu mauris rhoncus facilisis. Integer ut consectetur massa. Mauris vulputate nisi vel elementum rutrum. Donec lobortis lectus sed posuere euismod. Nulla vitae justo nisl. Nam nec urna arcu. Aliquam imperdiet sed enim sed tincidunt. In vitae est quis massa venenatis sagittis nec ac metus."
    
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(shortSentence)
                .textStyle(.title)
            Text(shortSentence)
                .textStyle(.heading)
            Text(mediumSentence)
                .textStyle(.subheading)
            Text(longSentence)
                .textStyle(.body)
        }
        .padding()
    }
}
#endif

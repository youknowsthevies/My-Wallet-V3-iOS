// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct TextStyle: ViewModifier {
    
    public enum FontStyle {
        case title
        case heading
        case subheading
        case body
    }
    
    public let fontStyle: FontStyle
    
    public func body(content: Content) -> some View {
        switch fontStyle {
        case .title:
            return content
                .font(Font(weight: .semibold, size: LayoutConstants.Text.FontSize.title))
                .foregroundColor(.textTitle)
                .lineSpacing(LayoutConstants.Text.LineSpacing.title)
        case .heading:
            return content
                .font(Font(weight: .semibold, size: LayoutConstants.Text.FontSize.heading))
                .foregroundColor(.textHeading)
                .lineSpacing(LayoutConstants.Text.LineSpacing.heading)
        case .subheading:
            return content
                .font(Font(weight: .medium, size: LayoutConstants.Text.FontSize.subheading))
                .foregroundColor(.textSubheading)
                .lineSpacing(LayoutConstants.Text.LineSpacing.subheading)
        case .body:
            return content
                .font(Font(weight: .medium, size: LayoutConstants.Text.FontSize.body))
                .foregroundColor(.textBody)
                .lineSpacing(LayoutConstants.Text.LineSpacing.body)
        }
    }
}

extension TextStyle {
    
    public static let title = TextStyle(fontStyle: .title)
    public static let heading = TextStyle(fontStyle: .heading)
    public static let subheading = TextStyle(fontStyle: .subheading)
    public static let body = TextStyle(fontStyle: .body)
}

extension View {
    
    public func textStyle(_ style: TextStyle) -> some View {
        self.modifier(style)
    }
}

#if DEBUG
struct TextStyle_Previews: PreviewProvider {
    
    static let shortSentence = "Almost before we knew it, we had left the ground."
    static let mediumSentence = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec condimentum id lacus vitae lacinia. Morbi accumsan lorem eu mauris rhoncus facilisis. Integer ut consectetur massa."
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

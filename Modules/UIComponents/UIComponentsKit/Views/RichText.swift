// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

/// A view that is able to render styled text.
/// This view currently supports only **bold** text.
public struct RichText: View {
    
    fileprivate struct Element {
        struct Style: OptionSet {
            let rawValue: Int
            
            static let plain = Style(rawValue: 1 << 0)
            static let bold = Style(rawValue: 1 << 1)
            static let italic = Style(rawValue: 1 << 2)
        }
        
        let content: String
        let style: Style
        
        var textView: Text {
            var view = Text(content)
            if style.contains(.bold) {
                view = view.bold()
            }
            if style.contains(.italic) {
                view = view.italic()
            }
            return view
        }
    }
    
    private let elements: [Element]
    
    init(_ content: String) {
        elements = content.elements
    }
    
    public var body: some View {
        elements
            .map(\.textView)
            .reduce(Text(""), +)
    }
}

extension String {
    
    struct Markup {
        static let marks: Set<Character> = ["*", "_"]
    }
    
    fileprivate func parseStyle(
        from fromIndex: String.Index,
        to toIndex: String.Index,
        stylesQueue: [RichText.Element.Style]
    ) -> RichText.Element.Style {
        guard toIndex < endIndex else {
            return stylesQueue.last ?? .plain
        }
        let isNextCharacterSameMark = fromIndex < toIndex && self[fromIndex] == self[toIndex]
        let foundStyle: RichText.Element.Style = isNextCharacterSameMark ? .bold : .italic
        return stylesQueue.count > 1 ? [stylesQueue.first!, foundStyle] : foundStyle
    }
    
    fileprivate var elements: [RichText.Element] {
        var results: [RichText.Element] = [], stylesQueue: [RichText.Element.Style] = []
        var substringStart = startIndex, current = startIndex
        
        func appendSubstringToResults(popStyle: Bool) {
            // append results of characters from substringStart up to, but not including, current
            let style: RichText.Element.Style
            if popStyle {
                style = stylesQueue.popLast() ?? .plain
            } else {
                style = stylesQueue.last ?? .plain
            }
            let substring = String(self[substringStart ..< current])
            results.append(.init(content: substring, style: style))
        }
        
        while current < endIndex {
            if Markup.marks.contains(self[current]) {
                let isNextCharacterSameMark = current < index(before: endIndex) && self[current] == self[index(after: current)]
                let foundStyle = parseStyle(from: current, to: index(after: current), stylesQueue: stylesQueue)
                let isOpeningMark = stylesQueue.last != foundStyle
                if isOpeningMark {
                    // first record any substring before the mark
                    appendSubstringToResults(popStyle: false)
                    if stylesQueue.isEmpty {
                        // then append the new style
                        stylesQueue.append(foundStyle)
                    } else {
                        // this is a composed style
                        stylesQueue.append([stylesQueue.last!, foundStyle])
                    }
                } else {
                    appendSubstringToResults(popStyle: true)
                }
                
                // move pointers forward
                current = index(current, offsetBy: isNextCharacterSameMark ? 2 : 1)
                substringStart = current
            } else {
                current = index(after: current)
            }
        }
        appendSubstringToResults(popStyle: true)
        return results
    }
}

#if DEBUG
struct RichText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 16) {
            RichText("Almost before we knew it, we had left the ground.")
            RichText("*Almost before we knew it, we had left the ground.*")
            RichText("**Almost before we knew it, we had left the ground.**")
            RichText("Almost *before* we knew **it**, we had left the ground.")
            RichText("Almost _before **we** knew it_, we had left the ground.")
            RichText("Almost __before *we* knew it__, we had left the ground.")
        }
        .padding()
    }
}
#endif

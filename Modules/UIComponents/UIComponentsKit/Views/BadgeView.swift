// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension LayoutConstants {
    
    fileprivate struct Badge {
        static let contentInsets = EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
        static let cornerRadious = CGFloat(8)
        
        private init() {
            // to avoid initializing the struct by accident
        }
    }
}

public struct BadgeView: View {
    
    public enum Style {
        case info
        case error
        case warning
        case success
    }
    
    public let title: String
    public let style: Style
    
    public init(title: String, style: Style) {
        self.title = title
        self.style = style
    }
    
    public var body: some View {
        ZStack {
            Text(title)
                .foregroundColor(style.textColor)
                .textStyle(.body)
        }
        .padding(LayoutConstants.Badge.contentInsets)
        .background(style.backgroundColor)
        .cornerRadius(LayoutConstants.Badge.cornerRadious)
    }
}

extension BadgeView.Style {

    var backgroundColor: Color {
        let color: Color
        switch self {
        case .info:
            color = .badgeBackgroundInfo
        case .error:
            color = .badgeBackgroundError
        case .warning:
            color = .badgeBackgroundWarning
        case .success:
            color = .badgeBackgroundSuccess
        }
        return color
    }

    var textColor: Color {
        let color: Color
        switch self {
        case .info:
            color = .badgeTextInfo
        case .error:
            color = .badgeTextError
        case .warning:
            color = .badgeTextWarning
        case .success:
            color = .badgeTextSuccess
        }
        return color
    }
}

#if DEBUG
struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            BadgeView(title: "Lorem Ipsum", style: .info)
            BadgeView(title: "Lorem Ipsum", style: .error)
            BadgeView(title: "Lorem Ipsum", style: .warning)
            BadgeView(title: "Lorem Ipsum", style: .success)
        }
    }
}
#endif

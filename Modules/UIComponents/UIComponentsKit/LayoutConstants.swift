import SwiftUI

public struct LayoutConstants {
    
    public static let buttonCornerRadious: CGFloat = 8
    public static let buttonMinHeight: CGFloat = 48
    public static let formGroupSpacing: CGFloat = 8
}

extension LayoutConstants {
    
    struct Text {
        
        struct FontSize {
            static let title: CGFloat = 20
            static let heading: CGFloat = 16
            static let subheading: CGFloat = 14
            static let body: CGFloat = 14
        }
        
        struct LineSpacing {
            static let title: CGFloat = 6
            static let heading: CGFloat = 4
            static let subheading: CGFloat = 4
            static let body: CGFloat = 4
        }
    }
}

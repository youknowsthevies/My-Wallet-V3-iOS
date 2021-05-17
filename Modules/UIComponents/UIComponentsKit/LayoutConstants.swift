import SwiftUI

public struct LayoutConstants {

    public static let buttonCornerRadious: CGFloat = 8
    public static let buttonMinHeight: CGFloat = 48
}

extension LayoutConstants {

    public struct VerticalSpacing {
        public static let betweenContentGroups: CGFloat = 16
        public static let withinButtonsGroup: CGFloat = 16
        public static let withinFormGroup: CGFloat = 4
    }
}

extension LayoutConstants {

    struct Text {

        struct FontSize {
            static let title: CGFloat = 20
            static let heading: CGFloat = 16
            static let subheading: CGFloat = 14
            static let body: CGFloat = 14
            static let formField: CGFloat = 16
        }

        struct LineHeight {
            static let title: CGFloat = 30
            static let heading: CGFloat = 24
            static let subheading: CGFloat = 20
            static let body: CGFloat = 20
            static let formField: CGFloat = 24
        }

        struct LineSpacing {
            static let title: CGFloat = LineHeight.title - FontSize.title
            static let heading: CGFloat = LineHeight.heading - FontSize.heading
            static let subheading: CGFloat = LineHeight.subheading - FontSize.subheading
            static let body: CGFloat = LineHeight.body - FontSize.body
            static let formField: CGFloat = LineHeight.formField - FontSize.formField
        }
    }
}

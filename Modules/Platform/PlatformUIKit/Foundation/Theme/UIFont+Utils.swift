// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

public enum FontWeight {
    case regular
    case medium
    case semibold
    case bold
}

extension UIFont {

    private enum InterType: String {
        case regular = "Inter-Regular"
        case medium = "Inter-Medium"
        case semibold = "Inter-SemiBold"
        case bold = "Inter-Bold"

        static func of(_ weight: FontWeight) -> InterType {
            switch weight {
            case .regular:
                return .regular
            case .medium:
                return .medium
            case .bold:
                return .bold
            case .semibold:
                return .semibold
            }
        }
    }

    public static func main(_ weight: FontWeight, _ size: CGFloat) -> UIFont {
        UIFont(name: InterType.of(weight).rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

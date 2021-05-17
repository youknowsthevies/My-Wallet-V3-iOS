// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public enum FontWeight {
    case regular
    case medium
    case semibold
    case bold
}

extension Font {
    
    init(weight: FontWeight, size: CGFloat) {
        self.init(UIFont.main(weight, size))
    }
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
        DispatchQueue.once(block: UIFont.loadCustomFonts)
        return UIFont(name: InterType.of(weight).rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

extension UIFont {
    
    static func loadCustomFonts() {
        registerFont(fileName: "\(InterType.regular.rawValue).ttf")
        registerFont(fileName: "\(InterType.medium.rawValue).ttf")
        registerFont(fileName: "\(InterType.semibold.rawValue).ttf")
        registerFont(fileName: "\(InterType.bold.rawValue).ttf")
    }
    
    static func registerFont(fileName: String, bundle: Bundle = Bundle.current) {
        let pathForResourceString = bundle.path(forResource: fileName, ofType: nil)
        if let fontData = NSData(contentsOfFile: pathForResourceString!), let dataProvider = CGDataProvider.init(data: fontData) {
            let fontRef = CGFont.init(dataProvider)
            var errorRef: Unmanaged<CFError>?
            if CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false {
                print("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
            }
        } else {
            print("Failed to register font - bundle identifier invalid.")
        }
    }
}

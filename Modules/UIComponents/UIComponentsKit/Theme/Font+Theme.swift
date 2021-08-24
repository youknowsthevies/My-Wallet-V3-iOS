// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public enum FontWeight {
    case regular
    case medium
    case semibold
    case bold
}

extension Font {

    public init(weight: FontWeight, size: CGFloat) {
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
        registerFont(fileName: InterType.regular.rawValue)
        registerFont(fileName: InterType.medium.rawValue)
        registerFont(fileName: InterType.semibold.rawValue)
        registerFont(fileName: InterType.bold.rawValue)
    }

    static func registerFont(fileName: String, bundle: Bundle = Bundle.safeModuleBundle) {
        guard let fontURL = bundle.url(forResource: fileName, withExtension: "ttf") else {
            print("No font named \(fileName).ttf was found in the module bundle")
            return
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
        print(error ?? "Successfully registered font: \(fileName)")
    }
}

extension Bundle {
    /// If unit tests are running, returns main Bundle.
    static var safeModuleBundle: Bundle {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return Bundle.main
        }
        return Bundle.module
    }
}

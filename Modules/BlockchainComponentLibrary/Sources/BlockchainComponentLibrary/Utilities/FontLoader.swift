// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CoreText
import Foundation

func loadCustomFonts() {
    DispatchQueue.once {
        Typography.FontResource.allCases
            .map(\.rawValue)
            .forEach { registerFont(fileName: $0) }
    }
}

func registerFont(fileName: String, bundle: Bundle = Bundle.componentLibrary) {
    guard let fontURL = bundle.url(forResource: fileName, withExtension: "ttf") else {
        print("No font named \(fileName).ttf was found in the module bundle")
        return
    }

    var error: Unmanaged<CFError>?
    CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
    if error == nil {
        print("Successfully registered font: \(fileName)")
    }
}

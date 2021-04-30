import SwiftUI

extension Color {
    
    fileprivate init(paletteColor: PaletteColor) {
        self.init(paletteColor.rawValue.capitalized, bundle: .current)
    }
    
    // MARK: Borders
    public static let borderPrimary = Color(paletteColor: .grey100)
    
    // MARK: PrimaryButton
    public static let buttonPrimaryBackground = Color(paletteColor: .blue600)
    public static let buttonPrimaryText = Color(paletteColor: .white)
    
    // MARK: SecondaryButton
    public static let buttonSecondaryBackground = Color(paletteColor: .white)
    public static let buttonSecondaryText = Color(paletteColor: .blue600)
    
    // MARK: Text
    public static let textTitle = Color(paletteColor: .grey900)
    public static let textHeading = Color(paletteColor: .grey900)
    public static let textSubheading = Color(paletteColor: .grey600)
    public static let textBody = Color(paletteColor: .grey900)
}

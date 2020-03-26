//
//  Accessibility+SettingsComponents.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Accessibility.Identifier {
    public struct Settings {
        private static let prefix = "Settings."
        public struct SettingsCell {
            private static let prefix = "\(Settings.prefix)SettingsCell."
            public static let titleLabelFormat = "\(prefix)titleLabel."
            public static let badgeView = "\(prefix)badgeView."
        }
        
        public enum SwitchView {
            private static let prefix = "\(Settings.prefix)SwitchView."
            public static let SMSSwitchView = "\(prefix)SMSSwitchView"
            public static let BioSwitchView = "\(prefix)BioSwitchView"
            public static let swipeToReceive = "\(prefix)swipeToReceiveSwitchView"
            public static let twoFactorSwitchView = "\(prefix)twoFactorSwitchView"
        }
        
        public enum ChangePassword {
            private static let prefix = "ChangePasswordScreen."
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let currentPasswordTextField = "\(prefix)currentPasswordTextField"
            public static let newPasswordTextField = "\(prefix)newPasswordTextField"
            public static let confirmPasswordTextField = "\(prefix)confirmPasswordTextField"
            public static let changePasswordButton = "\(prefix)changePasswordButton"
        }
        
        public enum UpdateEmail {
            private static let prefix = "UpdateEmailScreen."
            public static let titleLabel = "\(prefix)titleLabel"
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let emailTextField = "\(prefix)emailTextField"
            public static let updateEmailButton = "\(prefix)updateEmailButton"
            public static let resendEmailButton = "\(prefix)resendEmailButton"
        }
        
        public enum UpdateMobile {
            private static let prefix = "UpdateMobileScreen."
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let disable2FALabel = "\(prefix)disable2FALabel"
            public static let textField = "\(prefix)textField"
            public static let continueButton = "\(prefix)continueButton"
            public static let updateButton = "\(prefix)updateButton"
        }
        
        public enum MobileCodeEntry {
            private static let prefix = "MobileCodeEntryScreen."
            public static let descriptionLabel = "\(prefix)descriptionLabel"
            public static let codeEntryField = "\(prefix)codeEntryField"
            public static let changeNumberButton = "\(prefix)changeNumberButton"
            public static let resendCodeButton = "\(prefix)resendCodeButton"
            public static let confirmButton = "\(prefix)confirmButton"
        }
        
        public enum WebLogin {
            private static let prefix = "WebLoginScreen."
            public static let securityAlertLabel = "\(prefix)securityAlertLabel"
            public static let securityAlertTopLabel = "\(prefix)securityAlertTopLabel"
            public static let securityAlertBottomLabel = "\(prefix)securityAlertBottomLabel"
            public static let showQRCodeButton = "\(prefix)securityAlertBottomLabel"
        }
        
        public enum About {
            private static let prefix = "AboutFooterView."
            public static let versionLabel = "\(prefix)versionLabel"
            public static let copyrightLabel = "\(prefix)copyrightLabel"
        }
    }
}

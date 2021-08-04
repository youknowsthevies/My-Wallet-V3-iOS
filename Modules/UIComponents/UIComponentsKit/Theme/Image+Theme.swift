// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension Image {
    public enum Logo {
        public static let blockchain = Image("logo_large")
    }

    public enum ButtonIcon {
        public static let qrCode = Image("qr-code-icon")
    }

    public enum CircleIcon {
        public static let verifyDevice = Image("icon_verify_device")
        public static let resetAccount = Image("icon_reset_account")
        public static let lostFundWarning = Image("icon_lost_fund_warning")
    }
}

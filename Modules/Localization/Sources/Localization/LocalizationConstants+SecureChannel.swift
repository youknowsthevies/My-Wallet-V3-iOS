// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum SecureChannel {}
}

extension LocalizationConstants.SecureChannel {
    public enum QRCode {
        public static let header = NSLocalizedString(
            "Scan Your QR Code",
            comment: "Secure Channel - QR Code Scanner - header"
        )
        public static let subtitle = NSLocalizedString(
            "To use your Blockchain.com Wallet on the web, go to login.blockchain.com on your computer.",
            comment: "Secure Channel - QR Code Scanner - subtitle"
        )
    }

    public enum ConfirmationSheet {
        public enum Authorized {
            public static let title = NSLocalizedString(
                "Authorized Device Detected",
                comment: "Secure Channel - Confirmation Sheet - Authorized - title"
            )
            public static let subtitle = NSLocalizedString(
                "We noticed a login attempt from an authorized device.",
                comment: "Secure Channel - Confirmation Sheet - Authorized - subtitle"
            )
        }

        public enum New {
            public static let title = NSLocalizedString(
                "Log In Request From Web",
                comment: "Secure Channel - Confirmation Sheet - New Device - title"
            )
            public static let subtitle = NSLocalizedString(
                "We noticed a log in attempt from a device you don't usually use.",
                comment: "Secure Channel - Confirmation Sheet - New Device - subtitle"
            )
        }

        public enum Fields {
            public static let location = NSLocalizedString(
                "Location",
                comment: "Secure Channel - Confirmation Sheet - Field - Location"
            )
            public static let ipAddress = NSLocalizedString(
                "IP Address",
                comment: "Secure Channel - Confirmation Sheet - Field - IP Address"
            )
            public static let browser = NSLocalizedString(
                "Browser",
                comment: "Secure Channel - Confirmation Sheet - Field - Browser User Agent"
            )
            public static let date = NSLocalizedString(
                "Date",
                comment: "Secure Channel - Confirmation Sheet - Field - Date"
            )
            public static let lastSeen = NSLocalizedString(
                "Last seen",
                comment: "Secure Channel - Confirmation Sheet - Field - Last seen"
            )
            public static let never = NSLocalizedString(
                "Never",
                comment: "Secure Channel - Confirmation Sheet - Field - Last seen - Never"
            )
        }

        public enum CTA {
            public static let deny = NSLocalizedString(
                "Deny",
                comment: "Secure Channel - Confirmation Sheet - CTA"
            )
            public static let approve = NSLocalizedString(
                "Approve",
                comment: "Secure Channel - Confirmation Sheet - CTA"
            )
        }

        public enum Text {
            public static let warning = NSLocalizedString(
                "If this was you, approve the device below. If you do not recognize this device, deny & block the device now.",
                comment: "Secure Channel - Confirmation Sheet - Warning"
            )
        }
    }

    public enum Notification {
        public enum Authorized {
            public static let title = NSLocalizedString(
                "QR Code Log In",
                comment: "Secure Channel - Notification - Authorized - title"
            )
            public static let subtitle = NSLocalizedString(
                "Open your mobile Blockchain.com Wallet now to securely login your desktop Wallet.",
                comment: "Secure Channel - Notification - Authorized - subtitle"
            )
        }

        public enum New {
            public static let title = NSLocalizedString(
                "New Login Attempt",
                comment: "Secure Channel - Notification - New Device - title"
            )
            public static let subtitle = NSLocalizedString(
                "A new device is attempting to access your Blockchain.com Wallet. Approve or Deny now.",
                comment: "Secure Channel - Notification - New Device - subtitle"
            )
        }
    }

    public enum ResultSheet {
        public enum Approved {
            public static let title = NSLocalizedString(
                "Device Approved",
                comment: "Secure Channel - Result Sheet - Approved - title"
            )
            public static let subtitle = NSLocalizedString(
                "Logging you in on the web now.",
                comment: "Secure Channel - Result Sheet - Approved - subtitle"
            )
        }

        public enum Denied {
            public static let title = NSLocalizedString(
                "Device Denied",
                comment: "Secure Channel - Result Sheet - Denied - title"
            )
            public static let subtitle = NSLocalizedString(
                "Your wallet is safe. We have blocked this device from logging into your wallet.",
                comment: "Secure Channel - Result Sheet - Denied - subtitle"
            )
        }

        public enum Error {
            public static let title = NSLocalizedString(
                "Error",
                comment: "Secure Channel - Result Sheet - Error - title"
            )
            public static let subtitle = NSLocalizedString(
                "An error occurred, try again later.",
                comment: "Secure Channel - Result Sheet - Error - subtitle"
            )
        }

        public enum CTA {
            public static let ok = NSLocalizedString(
                "OK",
                comment: "Secure Channel - Result Sheet - CTA - OK"
            )
        }
    }

    public enum Alert {
        public static let title = NSLocalizedString(
            "QR Code Login",
            comment: "Secure Channel - Alert title"
        )
        public static let network = NSLocalizedString(
            "There was a network error logging in. Please try again.",
            comment: "Secure Channel - Network error in requests"
        )
        public static let ipMismatch = NSLocalizedString(
            "For security reasons, you must be on the same WiFi as the device you are authorizing the log in for.",
            comment: "Secure Channel - IP mismatch error"
        )
        public static let originIP = NSLocalizedString(
            "Origin IP",
            comment: "Secure Channel - Origin IP"
        )
        public static let deviceIP = NSLocalizedString(
            "Device IP",
            comment: "Secure Channel - Device IP"
        )
        public static let connectionExpired = NSLocalizedString(
            "Your login request has expired. Please regenerate the QR code and try again.",
            comment: "Secure Channel - Connection expired error"
        )
        public static let generic = NSLocalizedString(
            "There was an error logging in. Please try again.",
            comment: "Secure Channel - Generic login error"
        )
        public static let loginRequired = NSLocalizedString(
            "You need to authenticate to be able to respond to the login request.",
            comment: "Secure Channel - Login Required"
        )
    }
}

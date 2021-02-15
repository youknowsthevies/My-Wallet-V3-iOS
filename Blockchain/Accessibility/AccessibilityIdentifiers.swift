//
//  AccessibilityIdentifiers.swift
//  Blockchain
//
//  Created by Jack on 03/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AccessibilityIdentifiers: NSObject {

    struct PinScreen {
        static let prefix = "PinScreen."
    
        static let pinSecureViewTitle = "\(prefix)titleLabel"
        static let pinIndicatorFormat = "\(prefix)pinIndicator-"
        
        static let errorLabel = "\(prefix)errorLabel"
        
        static let versionLabel = "\(prefix)versionLabel"
        static let swipeLabel = "\(prefix)swipeLabel"
    }
    
    struct Address {
        static let prefix = "AddressScreen."
        
        static let assetNameLabel = "\(prefix)assetNameLabel"
        static let assetImageView = "\(prefix)assetImageView"
        
        static let addressLabel = "\(prefix)addressLabel"
        static let qrImageView = "\(prefix)addressQRImage"
        static let copyButton = "\(prefix)copyButton"
        static let shareButton = "\(prefix)shareButton"
        static let pageControl = "\(prefix)pageControl"
    }

    enum TabViewContainerScreen {
        static let activity = "TabViewContainerScreen.activity"
        static let swap = "TabViewContainerScreen.swap"
        static let home = "TabViewContainerScreen.home"
        static let send = "TabViewContainerScreen.send"
        static let request = "TabViewContainerScreen.request"
    }

    // MARK: - Navigation

    enum Navigation {
        private static let prefix = "NavigationBar."
        static let backButton = "\(prefix)backButton"
        static let closeButton = "\(prefix)closeButton"
        static let titleLabel = "\(prefix)titleLabel"

        enum Button {
            private static let prefix = "\(Navigation.prefix)Button."

            static let qrCode = "\(prefix)qrCode"
            static let dismiss = "\(prefix)dismiss"
            static let menu = "\(prefix)menu"
            static let help = "\(prefix)help"
            static let back = "\(prefix)back"
            static let error = "\(prefix)error"
            static let activityIndicator = "\(prefix)activityIndicator"
        }
    }
    
    // MARK: - Asset Selection
    
    struct AssetSelection {
        private static let prefix = "AssetSelection."
        
        static let toggleButton = "\(prefix)toggleButton"
        static let assetPrefix = "\(prefix)"
    }
    
    // MARK: - Send
    
    struct SendScreen {
        private static let prefix = "SendScreen."
        
        static let sourceAccountTitleLabel = "\(prefix)sourceAccountTitleLabel"
        static let sourceAccountValueLabel = "\(prefix)sourceAccountValueLabel"
        
        static let destinationAddressTitleLabel = "\(prefix)destinationAddressTitleLabel"
        static let destinationAddressTextField = "\(prefix)destinationAddressTextField"
        static let destinationAddressIndicatorLabel = "\(prefix)destinationAddressIndicatorLabel"
        
        static let feesTitleLabel = "\(prefix)feesTitleLabel"
        static let feesValueLabel = "\(prefix)feesValueLabel"
        
        static let cryptoTitleLabel = "\(prefix)cryptoTitleLabel"
        static let cryptoAmountTextField = "\(prefix)cryptoAmountTextField"
        
        static let fiatTitleLabel = "\(prefix)fiatTitleLabel"
        static let fiatAmountTextField = "\(prefix)fiatAmountTextField"
        
        static let maxAvailableLabel = "\(prefix)maxAvailableLabel"

        static let exchangeAddressButton = "\(prefix)exchangeAddressButton"
        static let addressesButton = "\(prefix)addressesButton"
        
        static let errorLabel = "\(prefix)errorLabel"
        
        static let continueButton = "\(prefix)continueButton"
        
        struct Stellar {
            static let memoLabel = "\(prefix)memoLabel"
            static let memoSelectionTypeButton = "\(prefix)memoSelectionTypeButton"
            static let memoTextField = "\(prefix)memoTextField"
            static let memoIDTextField = "\(prefix)memoIDTextField"
            static let moreInfoButton = "\(prefix)moreInfoButton"
            static let sendingToExchangeLabel = "\(prefix)sendingToAnExchangeLabel"
            static let addAMemoLabel = "\(prefix)addAMemoLabel"
        }
    }

    @objc(AccessibilityIdentifiers_ConfirmSend) class ConfirmSend: NSObject {
        private static let prefix = "ConfirmSend."
        
        @objc static let fiatAmountTitleLabel = "\(prefix)fiatAmountTitleLabel"
        @objc static let descriptionTextField = "\(prefix)descriptionTextField"
    }
    
    // MARK: - Amount (Fiat / Crypto)

    @objc(AccessibilityIdentifiers_TotalAmount) class TotalAmount: NSObject {
        private static let prefix = "TotalAmount."

        @objc static let fiatAmountLabel = "\(prefix)fiatAmountLabel"
        @objc static let cryptoAmountLabel = "\(prefix)cryptoAmountLabel"
    }
    
    // MARK: - General
    
    @objc(AccessibilityIdentifiers_General) class General: NSObject {
        private static let prefix = "General."
        @objc static let mainCTAButton = "\(prefix)mainCTAButton"
    }
    
    // MARK: - Number Keypad
    
    class NumberKeypadView {
        static let numberButton = "NumberKeypadView.numberButton"
        static let decimalButton = "NumberKeypadView.decimalButton"
        static let backspace = "NumberKeypadView.backspace"
    }
}

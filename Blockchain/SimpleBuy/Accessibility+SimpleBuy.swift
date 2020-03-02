//
//  Accessibility+SimpleBuy.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

extension Accessibility.Identifier {
    
    enum SimpleBuy {
        enum IntroScreen {
            static let descriptionLabel = "descriptionLabel"
        }
        
        enum Checkout {
            private static let prefix = "Checkout."
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let disclaimerLabel = "\(prefix)disclaimerLabel"
        }
        
        enum TransferDetails {
            private static let prefix = "TransferDetails."
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let disclaimerLabel = "\(prefix)disclaimerLabel"
        }
        
        enum Cancellation {
            private static let prefix = "Cancellation."
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let yesButton = "\(prefix)yesButton"
            static let noButton = "\(prefix)noButton"
        }
    }
}

extension Accessibility.Identifier {
    
    enum LineItem {
        private static let prefix = "LineItem."
        static let titleLabel = "\(prefix)titleLabel"
        static let descriptionLabel = "\(prefix)descriptionLabel"
        static let disclaimerLabel = "\(prefix)disclaimerLabel"
    }
}

extension Accessibility.Identifier.SimpleBuy {
    enum KYCScreen {
        static let titleLabel = "titleLabel"
        static let subtitleLabel = "subtitleLabel"
        static let goToWalletButton = "goToWalletButton"
    }
}

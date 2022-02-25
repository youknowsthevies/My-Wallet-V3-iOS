// Copyright © Blockchain Luxembourg S.A. All rights reserved.

enum AccessibilityIdentifiers {

    // MARK: - How it Works Sceren

    enum HowItWorks {
        static let prefix = "HowItWorksScreen."
        static let headerTitle = "\(prefix)headerTitle"
        static let headerDescription = "\(prefix)headerDescription"
        static let introductionList = "\(prefix)instructionList"
        static let smallButton = "\(prefix)smallButton"
        static let instructionText = "\(prefix)instructionText"
        static let ctaButton = "\(prefix)ctaButton"
    }

    // MARK: - Benefits Screen

    enum Benefits {
        static let prefix = "CryptoDomainBenefitsScreen."
        static let headerTitle = "\(prefix)headerTitle"
        static let headerDescription = "\(prefix)headerDescription"
        static let benefitsList = "\(prefix)benefitsList"
        static let ctaButton = "\(prefix)ctaButton"
    }

    // MARK: - Search Domain Screen

    enum SearchDomain {
        static let prefix = "SearchDomainScreen."
        static let searchBar = "\(prefix)searchBar"
        static let alertCard = "\(prefix)alertCard"
        static let domainList = "\(prefix)domainList"
        static let domainListRow = "\(prefix)domainListRow"
        static let cartButton = "\(prefix)cartButton"
    }

    // MARK: - Domain Checkout Screen

    enum DomainCheckout {
        static let prefix = "DomainCheckoutScreen."
        static let selectedDomainList = "\(prefix)selectedDomainList"
        static let termsSwitch = "\(prefix)termsSwitch"
        static let termsText = "\(prefix)termsText"
        static let ctaButton = "\(prefix)ctaButton"
        static let emptyStateIcon = "\(prefix)emptyStateIcon"
        static let emptyStateTitle = "\(prefix)emptyStateTitle"
        static let emptyStateDescription = "\(prefix)emptyStateDescription"
        static let browseButton = "\(prefix)browseButton"
    }

    enum RemoveDomainBottomSheet {
        static let prefix = "RemoveDomainBottomSheet."
        static let removeIcon = "\(prefix)removeIcon"
        static let removeTitle = "\(prefix)removeTitle"
        static let removeButton = "\(prefix)removeButton"
        static let nevermindButton = "\(prefix)nevermindButton"
    }

    enum BuyDomainBottomSheet {
        static let prefix = "BuyDomainBottomSheet."
        static let buyTitle = "\(prefix)buyTitle"
        static let buyDescription = "\(prefix)buyTitle"
        static let buyButton = "\(prefix)buyButton"
        static let goBackButton = "\(prefix)goBackButton"
    }

    // MARK: - Checkout Confirmation Screen

    enum CheckoutConfirmation {
        static let prefix = "DomainCheckoutConfirmationScreen."
        static let icon = "\(prefix)icon"
        static let title = "\(prefix)title"
        static let description = "\(prefix)description"
        static let learnMoreButton = "\(prefix)learnMoreButton"
        static let okayButton = "\(prefix)okayButton"
    }
}

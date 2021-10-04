// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum NabuErrorCode: Int, Codable, Equatable {

    // Unknown code
    case unknown = 0

    // Generic HTTP errors
    case internalServerError = 1
    case notFound = 2
    case badMethod = 3
    case conflict = 4

    // generic user input errors
    case missingBody = 5
    case missingParam = 6
    case badParamValue = 7

    // authentication errors
    case invalidCredentials = 8
    case wrongPassword = 9
    case wrong2fa = 10
    case bad2fa = 11
    case unknownUser = 12
    case invalidRole = 13
    case alreadyLoggedIn = 14
    case invalidStatus = 15

    // currency ratio errors
    case notSupportedCurrencyPair = 16
    case unknownCurrencyPair = 17
    case unknownCurrency = 18
    case currencyIsNotFiat = 19
    case tooSmallVolume = 26
    case tooBigVolume = 27
    case resultCurrencyRatioTooSmall = 28

    // conversion errors
    case providedVolumeIsNotDouble = 20
    case unknownConversionType = 21

    // kyc errors
    case userNotActive = 22
    case pendingKycReview = 23
    case kycAlreadyCompleted = 24
    case maxKycAttempts = 25
    case invalidCountryCode = 29

    // user-onboarding errors
    case invalidJwtToken = 30
    case expiredJwtToken = 31
    case mobileRegisteredAlready = 32
    case userRegisteredAlready = 33
    case missingApiToken = 34
    case couldNotInsertUser = 35
    case userRestored = 36

    // user trading error
    case genericTradingError = 37
    case albertExecutionError = 38
    case userHasNoCountry = 39
    case userNotFound = 40
    case orderBelowMinLimit = 41
    case wrongDepositAmount = 42
    case orderAboveMaxLimit = 43
    case ratesApiError = 44
    case dailyLimitExceeded = 45
    case weeklyLimitExceeded = 46
    case annualLimitExceeded = 47
    case notCryptoToCryptoCurrencyPair = 48
    case invalidCountryStateCode = 49
    case blockedPhone = 50
    case pendingOrdersLimitReached = 53
    case tradingDisabled = 51
    case mobileTooLong = 52

    /// Campaign Related Errors - These errors are specific
    /// to users opting into an air drop campaign. Currently they're
    /// used when a user deep links into the application from a campaign
    /// related link.
    case invalidCampaign = 54
    case invalidCampaignUser = 55
    case campaignUserAlreadyRegistered = 56
    case campaignExpired = 57
    case invalidCampaignInfo = 58
    case campaignWithdrawalFailed = 59
    case tradeForceExecuteError = 60
    case campaignInfoAlreadyUsed = 61

    case linkAccountError = 66
    case userAlreadyLinked = 660
    case linkExpired = 661

    case verificationExpired = 63
    case verificationFailed = 64
    case emailVerificationInProgress = 65
    case userHasNoUsername = 67
    case noAvailableUsername = 680
    case userNotAllowedToGetCredentials = 70
    case enablementFailed = 69

    // Payments related
    case depositCheckError = 72
    case couldNotInsertBeneficiary = 74
    case beneficiaryAlreadyExists = 75
    case beneficiaryNotFound = 76
    case paymentsNotSupported = 77
    case productNotSpecified = 78
    case notAuthorizedForFiat = 79
    case missingCryptoAddress = 87
    case missingBeneficiary = 88
    case invalidWithdrawalAmount = 90
    case exchangeRateFetchFailure = 91
    case minimumWithdrawalAmount = 92
    case invalidCryptoAddress = 93
    case invalidCryptoCurrency = 94
    case tierTooLow = 98
    case invalidAddress = 99
    case invalidPostcode = 158
    case notAuthorizedForGBP = 97
    case notAuthorizedForTry = 100
    case maxPaymentCards = 101
    case maxPaymentBankAccounts = 143
    case notAuthorizedForRub = 144
    case maxAuthAttemptsReached = 145

    /// Buy-Sell Error Code
    case withdrawalForbidden = 130
    case insufficientBalance = 131
    case orderInProgress = 132
    case simpleBuyExpirationError = 133
    case simpleBuyForceExecutionError = 134
    case invalidPaymentMethod = 135
    case noRatesAvailable = 136
    case eddQuestionairePending = 146
    /// Custodial Withdrawal Error Code
    case withdrawalLocked = 152

    /// Custodial related
    case invalidDestinationAddress = 148
    case invalidFiatCurrency = 149
    case orderDirectionDisabled = 151
    case addressGenerationFailure = 153
    case notFoundCustodialQuote = 155
    case userNotEligibleForSwap = 156
    case orderAmountNegative = 157

    case invalidKYCForSavings = 140
    case currencyNotSupported = 141
    case productNotSupported = 142
    case missingRangeParameter = 147
    case featureNotAvailable = 154

    case documentDataRequired = 160
}

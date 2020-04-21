//
//  AnalyticsEvents+Blockchain.swift
//  Blockchain
//
//  Created by Daniel Huri on 03/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

/// Analytics events classified by flow as described in the following Google Sheet:
/// https://docs.google.com/spreadsheets/d/1oJCRld_KrabJ9WyDKgMEnYYn5w79qUEhfOxnB6XQs9Q/edit?ts=5d6fb6a6#gid=0
/// To add an event please follow the the steps:
/// 1. Add the event under the relevant flow. If the flow does not exist, create a new one.
/// 2. Verify the validation test passes
/// 3. Add parameters if needed
/// 4. Copy the geenrated scripts here
/// 5. Implement the event using `AnalyticsEventRecording`
extension AnalyticsEvents {
    
    private struct Parameter {
        static let asset = "asset"
        static let currency = "currency"
    }
    
    // MARK: - Exchange
    
    enum Exchange: AnalyticsEvent {
        case exchangeConnectNowTapped
        case exchangeLearnMoreTapped
        case exchangeAnnouncementTapped
        
        var name: String {
            switch self {
            // User taps on "Connect Now" in the Exchange splash screen
            case .exchangeConnectNowTapped:
                return "exchange_connect_now_tapped"
            // User taps on "Learn More" in the Exchange splash screen
            case .exchangeLearnMoreTapped:
                return "exchange_learn_more_tapped"
            // Users taps on the CTA in the Exchange announcement
            case .exchangeAnnouncementTapped:
                return "exchange_announcement_tapped"
            }
        }
    }
    
    // MARK: - Login / Signup
    
    enum Onboarding: AnalyticsEvent {
        case walletCreation
        case walletCreationError
        case walletManualLogin
        case walletAutoPairingError
        case walletAutoPairing
        case walletDashboard
        case loginSecondPasswordViewed
        
        var name: String {
            switch self {
            // User creates Wallet
            case .walletCreation:
                return "wallet_creation"
            // Error is received while creating a wallet
            case .walletCreationError:
                return "wallet_creation_error"
            // User logs in manually to the Wallet
            case .walletManualLogin:
                return "wallet_manual_login"
            // User receives an error during scan (auto pairing)
            case .walletAutoPairingError:
                return "wallet_auto_pairing_error"
            // User logs in automatically to the Wallet
            case .walletAutoPairing:
                return "wallet_auto_pairing"
            // User sees the dashboard
            case .walletDashboard:
                return "wallet_dashboard"
            // User sees second password
            case .loginSecondPasswordViewed:
                return "login_second_password_viewed"
            }
        }
    }
    
    // MARK: - SideMenu
    
    enum SideMenu: AnalyticsEvent {
        case sideNavAccountsAndAddresses
        case sideNavBackup
        case sideNavSimpleBuy
        case sideNavLogout
        case sideNavSettings
        case sideNavSupport
        case sideNavUpgrade
        case sideNavWebLogin
        case sideNavAirdropCenter
        case sideNavLockbox
        case sideNavExchange
        
        var name: String {
            switch self {
            // Menu - accounts and addresses clicked
            case .sideNavAccountsAndAddresses:
                return "side_nav_accounts_and_addresses"
            // Menu - backup clicked
            case .sideNavBackup:
                return "side_nav_backup"
            // Menu - simple-buy clicked
            case .sideNavSimpleBuy:
                return "side_nav_simple_buy"
            // Menu - logout clicked
            case .sideNavLogout:
                return "side_nav_logout"
            // Menu - settings clicked
            case .sideNavSettings:
                return "side_nav_settings"
            // Menu - support clicked
            case .sideNavSupport:
                return "side_nav_support"
            // Menu - upgrade clicked
            case .sideNavUpgrade:
                return "side_nav_upgrade"
            // Menu - web login clicked
            case .sideNavWebLogin:
                return "side_nav_web_login"
            // Menu - airdrop center clicked
            case .sideNavAirdropCenter:
                return "side_nav_airdrop_center"
            // Menu - lockbox clicked
            case .sideNavLockbox:
                return "side_nav_lockbox"
            // Menu - exchange clicked
            case .sideNavExchange:
                return "side_nav_exchange"
            }
        }
    }
        
    // MARK: - Wallet Intro Flow
    
    enum WalletIntro: AnalyticsEvent {
        case walletIntroOffered
        case walletIntroPortfolioViewed
        case walletIntroSendViewed
        case walletIntroRequestViewed
        case walletIntroSwapViewed
        case walletIntroBuysellViewed
        
        var name: String {
            switch self {
            // Intro - User shown card to begin Wallet Intro
            case .walletIntroOffered:
                return "wallet_intro_offered"
            // Intro - User views "View your portfolio" card
            case .walletIntroPortfolioViewed:
                return "wallet_intro_portfolio_viewed"
            // Intro - User views "Send" card
            case .walletIntroSendViewed:
                return "wallet_intro_send_viewed"
            // Intro - User views "Request" card
            case .walletIntroRequestViewed:
                return "wallet_intro_request_viewed"
            // Intro - User views "Swap" card
            case .walletIntroSwapViewed:
                return "wallet_intro_swap_viewed"
            // Intro - User views "Buy and Sell" card
            case .walletIntroBuysellViewed:
                return "wallet_intro_buysell_viewed"
            }
        }
        
        var params: [String : String]? {
            return nil
        }
    }
    
    // MARK: - Bitpay

    enum Bitpay: AnalyticsEvent {
        case bitpayPaymentSuccess
        case bitpayPaymentFailure(error: Error?)
        case bitpayPaymentExpired
        case bitpayUrlScanned(asset: CryptoCurrency)
        case bitpayUrlPasted(asset: CryptoCurrency)
        case bitpayUrlDeeplink(asset: CryptoCurrency)

        var name: String {
            switch self {
            // User successfully pays a Bitpay payment request
            case .bitpayPaymentSuccess:
                return "bitpay_payment_success"
            // User fails to pay a Bitpay payment request
            case .bitpayPaymentFailure:
                return "bitpay_payment_failure"
            // User's payment request expired
            case .bitpayPaymentExpired:
                return "bitpay_payment_expired"
            // User scans a Bitpay QR code
            case .bitpayUrlScanned:
                return "bitpay_url_scanned"
            // User pastes a bitpay URL in the address field
            case .bitpayUrlPasted:
                return "bitpay_url_pasted"
            // User deep links into the app after tapping a Bitpay URL
            case .bitpayUrlDeeplink:
                return "bitpay_url_deeplink"
            }
        }

        var params: [String : String]? {
            switch self {
            case .bitpayUrlDeeplink(asset: let asset),
                 .bitpayUrlScanned(asset: let asset),
                 .bitpayUrlPasted(asset: let asset):
                return ["currency": asset.code]
            case .bitpayPaymentExpired,
                 .bitpayPaymentSuccess:
                return nil
            case .bitpayPaymentFailure(error: let error):
                guard let error = error else { return nil }
                return ["error": error.localizedDescription]
            }
        }
    }
    
    // MARK: - Send flow
    
    enum Send: AnalyticsEvent {
        case sendTabItemClick
        case sendFormConfirmClick(asset: CryptoCurrency)
        case sendFormConfirmSuccess(asset: CryptoCurrency)
        case sendFormConfirmFailure(asset: CryptoCurrency)
        case sendFormShowErrorAlert(asset: CryptoCurrency)
        case sendFormErrorAppear(asset: CryptoCurrency)
        case sendFormErrorClick(asset: CryptoCurrency)
        case sendFormUseBalanceClick(asset: CryptoCurrency)
        case sendFormExchangeButtonClick(asset: CryptoCurrency)
        case sendFormQrButtonClick(asset: CryptoCurrency)
        case sendSummaryConfirmClick(asset: CryptoCurrency)
        case sendSummaryConfirmSuccess(asset: CryptoCurrency)
        case sendSummaryConfirmFailure(asset: CryptoCurrency)
        case sendBitpayPaymentFailure(asset: CryptoCurrency)
        case sendBitpayPaymentSuccess(asset: CryptoCurrency)
        
        var name: String {
            switch self {
            // Send - tab item click
            case .sendTabItemClick:
                return "send_tab_item_click"
            // Send - form send click
            case .sendFormConfirmClick:
                return "send_form_confirm_click"
            // Send - form send success
            case .sendFormConfirmSuccess:
                return "send_form_confirm_success"
            // Send - form send failure
            case .sendFormConfirmFailure:
                return "send_form_confirm_failure"
            // Send - form show error alert
            case .sendFormShowErrorAlert:
                return "send_form_show_error_alert"
            // Send - form send error appears (⚠️)
            case .sendFormErrorAppear:
                return "send_form_error_appear"
            // Send - form send error click (⚠️)
            case .sendFormErrorClick:
                return "send_form_error_click"
            // Send - use spendable balance click
            case .sendFormUseBalanceClick:
                return "send_form_use_balance_click"
            // Send - Exchange button click
            case .sendFormExchangeButtonClick:
                return "send_form_exchange_button_click"
            // Send - QR button click
            case .sendFormQrButtonClick:
                return "send_form_qr_button_click"
            // Send - summary send click
            case .sendSummaryConfirmClick:
                return "send_summary_confirm_click"
            // Send - summary send success
            case .sendSummaryConfirmSuccess:
                return "send_summary_confirm_success"
            // Send - summary send failure
            case .sendSummaryConfirmFailure:
                return "send_summary_confirm_failure"
            // Send - bitpay send failure
            case .sendBitpayPaymentFailure:
                return "send_bitpay_payment_failure"
            // Send - bitpay send success
            case .sendBitpayPaymentSuccess:
                return "send_bitpay_payment_success"
            }
        }
        
        var params: [String : String]? {
            let assetParamName = Parameter.asset
            switch self {
            case .sendTabItemClick:
                return nil
            case .sendFormConfirmClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormConfirmSuccess(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormConfirmFailure(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormErrorAppear(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormErrorClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormUseBalanceClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormShowErrorAlert(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormExchangeButtonClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendFormQrButtonClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendSummaryConfirmClick(asset: let asset):
                return [assetParamName: asset.code]
            case .sendSummaryConfirmSuccess(asset: let asset):
                return [assetParamName: asset.code]
            case .sendSummaryConfirmFailure(asset: let asset):
                return [assetParamName: asset.code]
            case .sendBitpayPaymentFailure(asset: let asset):
                return [assetParamName: asset.code]
            case .sendBitpayPaymentSuccess(asset: let asset):
                return [assetParamName: asset.code]
            }
        }
    }
    
    // MARK: - Swap flow
    
    enum Swap: AnalyticsEvent {
        case swapTabItemClick
        case swapIntroStartButtonClick
        case swapFormConfirmClick
        case swapFormConfirmSuccess
        case swapFormConfirmError(message: String)
        case swapFormConfirmErrorAppear
        case swapFormConfirmErrorClick(error: ExchangeError)
        case swapSummaryConfirmClick
        case swapSummaryConfirmFailure
        case swapSummaryConfirmSuccess
        case swapReversePairClick
        case swapLeftAssetClick
        case swapRightAssetClick
        case swapExchangeChangeReceived
        case swapInputValueChanged(crypto: String, fiat: String, fiatAmount: String)
        case swapViewHistoryButtonClick
        case swapHistoryOrderClick
        case swapHistoryOrderIdCopied
        
        var name: String {
            switch self {
            // Swap - tab item click
            case .swapTabItemClick:
                return "swap_tab_item_click"
            // Swap - intro start button clicked
            case .swapIntroStartButtonClick:
                return "swap_intro_start_button_click"
            // Swap - confirm amount click
            case .swapFormConfirmClick:
                return "swap_form_confirm_click"
            // Swap - confirm amount success
            case .swapFormConfirmSuccess:
                return "swap_form_confirm_success"
            // Swap - confirm amount error
            case .swapFormConfirmError:
                return "swap_form_confirm_error"
            // Swap - error appears (⚠️)
            case .swapFormConfirmErrorAppear:
                return "swap_form_confirm_error_appear"
            // Swap - error click (⚠️)
            case .swapFormConfirmErrorClick:
                return "swap_form_confirm_error_click"
            // Swap - summary final confirmation click confirm
            case .swapSummaryConfirmClick:
                return "swap_summary_confirm_click"
            // Swap - summary final confirmation failure
            case .swapSummaryConfirmFailure:
                return "swap_summary_confirm_failure"
            // Swap - summary final confirmation success
            case .swapSummaryConfirmSuccess:
                return "swap_summary_confirm_success"
            // Swap - reverse pair button clicked
            case .swapReversePairClick:
                return "swap_reverse_pair_click"
            // Swap - left asset button clicked
            case .swapLeftAssetClick:
                return "swap_left_asset_click"
            // Swap - right asset button clicked
            case .swapRightAssetClick:
                return "swap_right_asset_click"
            // Swap - exchange receive change
            case .swapExchangeChangeReceived:
                return "swap_exchange_change_received"
            // Swap - input swap value
            case .swapInputValueChanged:
                return "swap_input_value_changed"
            // Swap - history button clicked
            case .swapViewHistoryButtonClick:
                return "swap_view_history_button_click"
            // Swap - history specific order clicked
            case .swapHistoryOrderClick:
                return "swap_history_order_click"
            // Swap - history order id coptied
            case .swapHistoryOrderIdCopied:
                return "swap_history_order_id_copied"
            }
        }
        
        var params: [String : String]? {
            switch self {
            case .swapFormConfirmError(message: let message):
                return ["message": message]
            default:
                return nil
            }
        }
    }
        
    // MARK: - Transactions flow
    
    enum Transactions: AnalyticsEvent {
        case transactionsTabItemClick
        case transactionsListItemClick(asset: CryptoCurrency)
        case transactionsItemShareClick(asset: CryptoCurrency)
        case transactionsItemWebViewClick(asset: CryptoCurrency)
        
        var name: String {
            switch self {
            // Transactions - tab item click
            case .transactionsTabItemClick:
                return "transactions_tab_item_click"
            // Transactions - transaction item clicked
            case .transactionsListItemClick:
                return "transactions_list_item_click"
            // Transaction - share button clicked
            case .transactionsItemShareClick:
                return "transactions_item_share_click"
            // Transaction - view on web clicked
            case .transactionsItemWebViewClick:
                return "transactions_item_web_view_click"
            }
        }
        
        var params: [String : String]? {
            switch self {
            // Transactions - transaction item clicked
            case .transactionsListItemClick(asset: let asset):
                return [Parameter.asset: asset.code]
            // Transaction - share button clicked
            case .transactionsItemShareClick(asset: let asset):
                return [Parameter.asset: asset.code]
            // Transaction - view on web clicked
            case .transactionsItemWebViewClick(asset: let asset):
                return [Parameter.asset: asset.code]
            default:
                return nil
            }
        }
    }
    
    // MARK: - KYC flow
    
    enum KYC: AnalyticsEvent {
        case kycVerifyEmailButtonClick
        case kycCountrySelected
        case kycPersonalDetailSet(fieldName: String)
        case kycAddressDetailSet
        case kycVerifyIdStartButtonClick
        case kycVeriffInfoSubmitted
        case kycUnlockSilverClick
        case kycUnlockGoldClick
        case kycPhoneUpdateButtonClick
        case kycEmailUpdateButtonClick
        
        var name: String {
            switch self {
            // KYC - send verification email button click
            case .kycVerifyEmailButtonClick:
                return "kyc_verify_email_button_click"
            // KYC - country selected
            case .kycCountrySelected:
                return "kyc_country_selected"
            // KYC - personal detail changed
            case .kycPersonalDetailSet:
                return "kyc_personal_detail_set"
            // KYC - address changed
            case .kycAddressDetailSet:
                return "kyc_address_detail_set"
            // KYC - verify identity start button click
            case .kycVerifyIdStartButtonClick:
                return "kyc_verify_id_start_button_click"
            // KYC - info veriff info submitted
            case .kycVeriffInfoSubmitted:
                return "kyc_veriff_info_submitted"
            // KYC - unlock tier 1 (silver) clicked
            case .kycUnlockSilverClick:
                return "kyc_unlock_silver_click"
            // KYC - unlock tier 1 (silver) clicked
            case .kycUnlockGoldClick:
                return "kyc_unlock_gold_click"
            // KYC - phone number update button click
            case .kycPhoneUpdateButtonClick:
                return "kyc_phone_update_button_click"
            // KYC - email update button click
            case .kycEmailUpdateButtonClick:
                return "kyc_email_update_button_click"
            }
        }
        
        var params: [String : String]? {
            return nil
        }
    }
    
    // MARK: - Settings flow
    
    enum Settings: AnalyticsEvent {
        case settingsEmailClicked
        case settingsPhoneClicked
        case settingsWebWalletLoginClick
        case settingsSwapLimitClicked
        case settingsSwipeToReceiveSwitch(value: Bool)
        case settingsWalletIdCopyClick
        case settingsWalletIdCopied
        case settingsEmailNotifSwitch(value: Bool)
        case settingsPasswordClick
        case settingsTwoFaClick
        case settingsRecoveryPhraseClick
        case settingsChangePinClick
        case settingsBiometryAuthSwitch(value: Bool)
        case settingsLanguageSelected(language: String)
        case settingsPinSelected
        case settingsPasswordSelected
        case settingsCurrencySelected(currency: String)
        
        var name: String {
            switch self {
            // Settings - email clicked
            case .settingsEmailClicked:
                return "settings_email_clicked"
            // Settings - phone clicked
            case .settingsPhoneClicked:
                return "settings_phone_clicked"
            // Settings - login to web wallet clicked
            case .settingsWebWalletLoginClick:
                return "settings_web_wallet_login_click"
            // Settings - swap limit clicked
            case .settingsSwapLimitClicked:
                return "settings_swap_limit_clicked"
            // Settings - swipe to receive switch clicked
            case .settingsSwipeToReceiveSwitch:
                return "settings_swipe_to_receive_switch"
            // Settings - wallet id copy clicked
            case .settingsWalletIdCopyClick:
                return "settings_wallet_id_copy_click"
            // Settings - wallet id copied
            case .settingsWalletIdCopied:
                return "settings_wallet_id_copied"
            // Settings - email notifications switch clicked
            case .settingsEmailNotifSwitch:
                return "settings_email_notif_switch"
            // Settings - change password clicked
            case .settingsPasswordClick:
                return "settings_password_click"
            // Settings - two factor auth clicked
            case .settingsTwoFaClick:
                return "settings_two_fa_click"
            // Settings - recovery phrase clicked
            case .settingsRecoveryPhraseClick:
                return "settings_recovery_phrase_click"
            // Settings - change PIN clicked
            case .settingsChangePinClick:
                return "settings_change_pin_click"
            // Settings - biometry auth switch
            case .settingsBiometryAuthSwitch:
                return "settings_biometry_auth_switch"
            // Settings - change language
            case .settingsLanguageSelected:
                return "settings_language_selected"
            // Settings - PIN changed
            case .settingsPinSelected:
                return "settings_pin_selected"
            // Settings - change password
            case .settingsPasswordSelected:
                return "settings_password_selected"
            // Settings - change currency
            case .settingsCurrencySelected:
                return "settings_currency_selected"
            }
        }
        
        var params: [String : String]? {
            return nil
        }
    }
    
    enum Permission: AnalyticsEvent {
        case permissionPreCameraApprove
        case permissionPreCameraDecline
        case permissionSysCameraApprove
        case permissionSysCameraDecline
        case permissionPreMicApprove
        case permissionPreMicDecline
        case permissionSysMicApprove
        case permissionSysMicDecline
        case permissionSysNotifRequest
        case permissionSysNotifApprove
        case permissionSysNotifDecline
        
        var name: String {
            switch self {
            // Permission - camera preliminary approve
            case .permissionPreCameraApprove:
                return "permission_pre_camera_approve"
            // Permission - camera preliminary decline
            case .permissionPreCameraDecline:
                return "permission_pre_camera_decline"
            // Permission - camera system approve
            case .permissionSysCameraApprove:
                return "permission_sys_camera_approve"
            // Permission - camera system decline
            case .permissionSysCameraDecline:
                return "permission_sys_camera_decline"
            // Permission - mic preliminary approve
            case .permissionPreMicApprove:
                return "permission_pre_mic_approve"
            // Permission - mic preliminary decline
            case .permissionPreMicDecline:
                return "permission_pre_mic_decline"
            // Permission - mic system approve
            case .permissionSysMicApprove:
                return "permission_sys_mic_approve"
            // Permission - mic system decline
            case .permissionSysMicDecline:
                return "permission_sys_mic_decline"
            // Permission - remote notification system request
            case .permissionSysNotifRequest:
                return "permission_sys_notif_request"
            // Permission - remote notification system approve
            case .permissionSysNotifApprove:
                return "permission_sys_notif_approve"
            // Permission - remote notification system decline
            case .permissionSysNotifDecline:
                return "permission_sys_notif_decline"
            }
        }
    }
    
    // MARK: - Asset Selector
    
    enum AssetSelection: AnalyticsEvent {
        case assetSelectorOpen(asset: CryptoCurrency)
        case assetSelectorClose(asset: CryptoCurrency)
        
        var name: String {
            switch self {
            // Asset Selector - asset selector opened
            case .assetSelectorOpen:
                return "asset_selector_open"
            // Asset Selector - asset selector closed
            case .assetSelectorClose:
                return "asset_selector_close"
            }
        }
        
        var params: [String : String]? {
            switch self {
            case .assetSelectorOpen(asset: let asset):
                return [Parameter.asset: asset.code]
            case .assetSelectorClose(asset: let asset):
                return [Parameter.asset: asset.code]
            }
        }
    }
    
    enum SimpleBuy: AnalyticsEvent {
        case sbWantToBuyScreenShown
        case sbWantToBuyButtonClicked
        case sbWantToBuyButtonSkip
        case sbWantToBuyScreenError
        case sbBuyFormShown
        case sbBuyFormConfirmClick(currencyCode: String, amount: String)
        case sbBuyFormConfirmSuccess
        case sbBuyFormCryptoChanged(asset: CryptoCurrency)
        case sbBuyFormMinFailure
        case sbBuyFormMinClicked
        case sbBuyFormMaxFailure
        case sbBuyFormMaxClicked
        case sbBuyFormFiatChanged(currencyCode: String)
        case sbBuyFormConfirmFailure
        case sbKycStart
        case sbKycVerifying
        case sbKycManualReview
        case sbKycPending
        case sbPostKycNotEligible
        case sbCheckoutShown
        case sbCheckoutConfirm
        case sbCheckoutCancel
        case sbCheckoutCancelPrompt
        case sbCheckoutCancelConfirmed
        case sbCheckoutCancelGoBack
        case sbBankDetailsShown(currencyCode: String)
        case sbBankDetailsCopied(bankName: String)
        case sbBankDetailsFinished
        case sbPendingModalShown(currencyCode: String)
        case sbPendingModalCancelClick
        case sbPendingBannerShown
        case sbPendingViewBankDetails
        case sbCancelOrderPrompt
        case sbCancelOrderConfirmed
        case sbCancelOrderGoBack
        case sbCancelOrderError
        case sbCustodyWalletCardShown
        case sbCustodyWalletCardClicked
        case sbBackupWalletCardShown
        case sbBackupWalletCardClicked
        case sbTradingWalletClicked(asset: CryptoCurrency)
        case sbTradingWalletSend(asset: CryptoCurrency)
        case sbWithdrawalScreenShown(asset: CryptoCurrency)
        case sbWithdrawalScreenClicked(asset: CryptoCurrency)
        case sbWithdrawalScreenSuccess
        case sbWithdrawalScreenFailure
        case sbPaymentMethodShown
        case sbPaymentMethodSelected(selection: String)
        case sbAddCardCardClicked
        case sbAddCardScreenShown
        case sbCardInfoSet
        case sbBillingAddressSet
        case sbThreeDSecureComplete
        case sbRemoveCard
        case sbCurrencySelectScreen
        case sbCurrencySelected(currencyCode: String)
        case sbCurrencyUnsupported
        case sbUnsupportedChangeCurrency
        case sbUnsupportedViewHome
        
        var name: String {
            switch self {
            // Simple buy - I want to buy crypto screen shown (4.0)
            case .sbWantToBuyScreenShown:
                return "sb_want_to_buy_screen_shown"
            // Simple buy - I want to buy crypto button clicked
            case .sbWantToBuyButtonClicked:
                return "sb_want_to_buy_button_clicked"
            // Simple buy - Skip I already have crypto button clicked
            case .sbWantToBuyButtonSkip:
                return "sb_want_to_buy_button_skip"
            // Simple buy - I want to buy crypto error (4.1)
            case .sbWantToBuyScreenError:
                return "sb_want_to_buy_screen_error"
            // Simple buy - buy form shown (5.0)
            case .sbBuyFormShown:
                return "sb_buy_form_shown"
            // Simple buy - confirm amount clicked (5.0)
            case .sbBuyFormConfirmClick:
                return "sb_buy_form_confirm_click"
            // Simple buy - confirm amount success (5.0) *
            case .sbBuyFormConfirmSuccess:
                return "sb_buy_form_confirm_success"
            // Simple buy - crypto changed (5.1)
            case .sbBuyFormCryptoChanged:
                return "sb_buy_form_crypto_changed"
            // Simple buy - confirm amount min error (5.2)*
            case .sbBuyFormMinFailure:
                return "sb_buy_form_min_failure"
            // Simple buy - buy mininum clicked (5.2)
            case .sbBuyFormMinClicked:
                return "sb_buy_form_min_clicked"
            // Simple buy - confirm amount max error (5.3)*
            case .sbBuyFormMaxFailure:
                return "sb_buy_form_max_failure"
            // Simple buy - buy maximum clicked (5.3)
            case .sbBuyFormMaxClicked:
                return "sb_buy_form_max_clicked"
            // Simple buy - fiat changed (5.4)
            case .sbBuyFormFiatChanged:
                return "sb_buy_form_fiat_changed"
            // Simple buy - confirm amount failed (5.5)*
            case .sbBuyFormConfirmFailure:
                return "sb_buy_form_confirm_failure"
            // Simple buy - start gold flow (6.0)
            case .sbKycStart:
                return "sb_kyc_start"
            // Simple buy - kyc verifying (6.1)
            case .sbKycVerifying:
                return "sb_kyc_verifying"
            // Simple buy - kyc manual review (6.2)
            case .sbKycManualReview:
                return "sb_kyc_manual_review"
            // Simple buy - kyc pending review (6.3)
            case .sbKycPending:
                return "sb_kyc_pending"
            // Simple buy - post kyc not eligible (6.4)
            case .sbPostKycNotEligible:
                return "sb_post_kyc_not_eligible"
            // Simple buy - checkout summary shown (7.0)
            case .sbCheckoutShown:
                return "sb_checkout_shown"
            // Simple buy - checkout summary confirmed (7.0)
            case .sbCheckoutConfirm:
                return "sb_checkout_confirm"
            // Simple buy - checkout summary press cancel (7.0)
            case .sbCheckoutCancel:
                return "sb_checkout_cancel"
            // Simple buy - checkout cancellation prompt shown (7.1)
            case .sbCheckoutCancelPrompt:
                return "sb_checkout_cancel_prompt"
            // Simple buy - checkout cancellation confirmed (7.1)
            case .sbCheckoutCancelConfirmed:
                return "sb_checkout_cancel_confirmed"
            // Simple buy - checkout cancellation go back (7.1)
            case .sbCheckoutCancelGoBack:
                return "sb_checkout_cancel_go_back"
            // Simple buy - bank details shown (7.2, 7.3)
            case .sbBankDetailsShown:
                return "sb_bank_details_shown"
            // Simple buy - bank details copied (7.2, 7.3 & 8.2)
            case .sbBankDetailsCopied:
                return "sb_bank_details_copied"
            // Simple buy - bank details finished (7.2, 7.3 & 8.2)
            case .sbBankDetailsFinished:
                return "sb_bank_details_finished"
            // Simple buy - pending transfer modal shown (8.2)
            case .sbPendingModalShown:
                return "sb_pending_modal_shown"
            // Simple buy - pending transfer, cancel button clicked (8.2)
            case .sbPendingModalCancelClick:
                return "sb_pending_modal_cancel_click"
            // Simple buy - pending transfer, banner shown (8.0)
            case .sbPendingBannerShown:
                return "sb_pending_banner_shown"
            // Simple buy - pending transfer, view bank transfer details clicked (8.0)
            case .sbPendingViewBankDetails:
                return "sb_pending_view_bank_details"
            // Simple buy - checkout cancellation prompt (tbc, under 8.2)
            case .sbCancelOrderPrompt:
                return "sb_cancel_order_prompt"
            // Simple buy - checkout cancellation confirmed (tbc, under 8.2)
            case .sbCancelOrderConfirmed:
                return "sb_cancel_order_confirmed"
            // Simple buy - checkout cancellation go back (tbc, under 8.2)
            case .sbCancelOrderGoBack:
                return "sb_cancel_order_go_back"
            // Simple buy - checkout cancel error (tbc, under 8.2)
            case .sbCancelOrderError:
                return "sb_cancel_order_error"
            // Simple buy - your custody wallet card shown (9.1)
            case .sbCustodyWalletCardShown:
                return "sb_custody_wallet_card_shown"
            // Simple buy - your custody wallet card clicked (9.1)
            case .sbCustodyWalletCardClicked:
                return "sb_custody_wallet_card_clicked"
            // Simple buy - back up your wallet (10.1)
            case .sbBackupWalletCardShown:
                return "sb_backup_wallet_card_shown"
            // Simple buy - back up your wallet clicked (10.1)
            case .sbBackupWalletCardClicked:
                return "sb_backup_wallet_card_clicked"
            // Simple buy - trading wallet currency clicked (10.4)
            case .sbTradingWalletClicked:
                return "sb_trading_wallet_clicked"
            // Simple buy - trading wallet currency send (10.4)
            case .sbTradingWalletSend:
                return "sb_trading_wallet_send"
            // Simple buy - withdraw screen shown (11.0)
            case .sbWithdrawalScreenShown:
                return "sb_withdrawal_screen_shown"
            // Simple buy - withdraw screen clicked (11.0)
            case .sbWithdrawalScreenClicked:
                return "sb_withdrawal_screen_clicked"
            // Simple buy - withdraw screen success (11.1)
            case .sbWithdrawalScreenSuccess:
                return "sb_withdrawal_screen_success"
            // Simple buy - withdraw screen faillure (11.2)
            case .sbWithdrawalScreenFailure:
                return "sb_withdrawal_screen_failure"
            // Simple buy - side nav Buy button
            case .sbPaymentMethodShown:
                return "sb_payment_method_shown"
            // Simple buy - payment method selected (2.1)
            case .sbPaymentMethodSelected:
                return "sb_payment_method_selected"
            // Simple buy - payment method add new from dashboard (2.2)
            case .sbAddCardCardClicked:
                return "sb_add_card_card_clicked"
            // Simple buy - add card (3.0)
            case .sbAddCardScreenShown:
                return "sb_add_card_screen_shown"
            // Simple buy - Card Info Set (3.1)
            case .sbCardInfoSet:
                return "sb_card_info_set"
            // Simple buy - Billing Address Set (3.3)
            case .sbBillingAddressSet:
                return "sb_billing_address_set"
            // Simple buy - 3DS Complete (3.4)
            case .sbThreeDSecureComplete:
                return "sb_three_d_secure_complete"
            // Simple Buy - Remove Card (5.1)
            case .sbRemoveCard:
                return "sb_remove_card"
            // Simple Buy - Select your currency (card shown, 0.1 Fiat)
            case .sbCurrencySelectScreen:
                return "sb_currency_select_screen"
            // Simple Buy - Currency selected (clicked on currency, 0.1)
            case .sbCurrencySelected:
                return "sb_currency_selected"
            // Simple Buy - Currency Not Supported (screen shown, 0.2)
            case .sbCurrencyUnsupported:
                return "sb_currency_unsupported"
            // Simple Buy - Change Currency (button clicked, 0.2)
            case .sbUnsupportedChangeCurrency:
                return "sb_unsupported_change_currency"
            // Simple Buy - View Home (button clicked, 0.2)
            case .sbUnsupportedViewHome:
                return "sb_unsupported_view_home"
            }
        }
        
        var params: [String : String]? {
            switch self {
            case .sbBankDetailsShown(currencyCode: let currencyCode),
                 .sbPendingModalShown(currencyCode: let currencyCode),
                 .sbBuyFormFiatChanged(currencyCode: let currencyCode),
                 .sbPaymentMethodSelected(selection: let currencyCode),
                 .sbCurrencySelected(currencyCode: let currencyCode):
                return ["currency": currencyCode]
            case .sbTradingWalletSend(asset: let currency),
                 .sbTradingWalletClicked(asset: let currency),
                 .sbWithdrawalScreenShown(asset: let currency),
                 .sbWithdrawalScreenClicked(asset: let currency):
                return ["asset": currency.rawValue]
            case .sbBuyFormConfirmClick(currencyCode: let currencyCode, amount: let amount):
                return ["currency": currencyCode,
                        "amount": amount]
            case .sbBankDetailsCopied(bankName: let bankName):
                return ["bank field name": bankName]
            default:
                return nil
            }
        }
    }
}

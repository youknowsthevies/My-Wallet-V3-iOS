//
//  SendViewController.m
//  Blockchain
//
//  Created by Ben Reeves on 17/03/2012.
//  Copyright (c) 2012 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SendBitcoinViewController.h"
#import "Wallet.h"
#import "BCAddressSelectionView.h"
#import "UIViewController+AutoDismiss.h"
#import "LocalizationConstants.h"
#import "UIView+ChangeFrameAttribute.h"
#import "TransferAllFundsBuilder.h"
#import "BCFeeSelectionView.h"
#import "BCConfirmPaymentViewModel.h"
#import "Blockchain-Swift.h"
#import "NSNumberFormatter+Currencies.h"

@import BitcoinKit;
@import BitcoinCashKit;

typedef NS_ENUM(NSUInteger, SendTransactionType) {
    SendTransactionTypeRegular = 100,
    SendTransactionTypeSweep = 200,
    SendTransactionTypeSweepAndConfirm = 300,
};

typedef NS_ENUM(NSUInteger, RejectionType) {
    RejectionTypeDecline,
    RejectionTypeCancel
};

@interface SendBitcoinViewController () <UITextFieldDelegate, TransferAllFundsDelegate, FeeSelectionDelegate, ConfirmPaymentViewDelegate>

@property (nonatomic, assign) SendTransactionType transactionType;

@property (nonatomic, assign, readwrite) DestinationAddressSource addressSource;

@property (nonatomic, assign) uint64_t recommendedForcedFee;
@property (nonatomic, assign) uint64_t feeFromTransactionProposal;
@property (nonatomic, assign) uint64_t lastDisplayedFee;
@property (nonatomic, assign) uint64_t dust;
@property (nonatomic, assign) uint64_t txSize;

@property (nonatomic, assign) uint64_t amountFromURLHandler;

@property (nonatomic, assign) uint64_t upperRecommendedLimit;
@property (nonatomic, assign) uint64_t lowerRecommendedLimit;
@property (nonatomic, assign) uint64_t estimatedTransactionSize;

@property (nonatomic, assign) FeeType feeType;
@property (nonatomic, copy) NSDictionary *fees;

@property (nonatomic, copy) NSString *noteToSet;

@property (nonatomic, assign) BOOL isReloading;
@property (nonatomic, assign) BOOL shouldReloadFeeAmountLabel;

@property (nonatomic, copy) void (^getTransactionFeeSuccess)(void);
@property (nonatomic, copy) void (^getDynamicFeeError)(void);
@property (nonatomic, copy) void (^onViewDidLoad)(void);

@property (nonatomic, strong) TransferAllFundsBuilder *transferAllPaymentBuilder;

@property (nonatomic, strong) SendExchangeAddressStatePresenter *exchangeAddressPresenter;
@property (nonatomic, strong) BridgeBitpayService *bitpayService;
@property (nonatomic, strong) BridgeAnalyticsRecorder *analyticsRecorder;

@property (nonatomic, strong) ExchangeAddressViewModel *exchangeAddressViewModel;

@property (nonatomic, strong) BridgeDeepLinkQRCodeRouter *deepLinkQRCodeRouter;

@property (nonatomic, assign) BOOL isBitpayPayPro;

@property (nonatomic, assign) BOOL displayingLocalSymbol;

@property (nonatomic, assign) uint64_t amountInSatoshi;
@property (nonatomic, assign) uint64_t availableAmount;

@property (nonatomic, assign) BOOL displayingLocalSymbolSend;

@property (nonatomic, copy) NSString *addressFromURLHandler;

@property (nonatomic, copy) NSString *fromAddress;
@property (nonatomic, copy) NSString *toAddress;
@property (nonatomic, assign) int fromAccount;
@property (nonatomic, assign) int toAccount;
@property (nonatomic, assign) BOOL sendFromAddress;
@property (nonatomic, assign) BOOL sendToAddress;

@property (nonatomic, assign) BOOL isSending;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

#pragma mark - BitPay

@property (nonatomic, copy) NSDate *bitpayExpiration;
@property (nonatomic, copy) NSString *bitpayMerchant;
@property (nonatomic, strong) BCLine *lineBelowBitpayLabel;
@property (nonatomic, strong) NSTimer *bitpayTimer;
@property (nonatomic, strong) UIImageView *bitpayLogo;
@property (nonatomic, strong) UILabel *bitpayLabel;
@property (nonatomic, strong) UILabel *bitpayTimeRemainingText;

#pragma mark - UIView

@property (nonatomic, strong) BCConfirmPaymentView *confirmPaymentView;
@property (nonatomic, strong) UILabel *destinationAddressIndicatorLabel;
@property (nonatomic, strong) UILabel *feeTypeLabel;
@property (nonatomic, strong) UILabel *feeDescriptionLabel;
@property (nonatomic, strong) UILabel *feeAmountLabel;
@property (nonatomic, strong) UILabel *feeWarningLabel;
@property (nonatomic, strong) UIButton *exchangeAddressButton;

#pragma mark - IBOutlet

@property (nonatomic, strong) IBOutlet BCLine *lineBelowAmountFields;
@property (nonatomic, strong) IBOutlet BCLine *lineBelowFeeField;
@property (nonatomic, strong) IBOutlet BCLine *lineBelowFromField;
@property (nonatomic, strong) IBOutlet BCLine *lineBelowToField;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *continueButtonTopConstraint;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *sendProgressActivityIndicator;
@property (nonatomic, strong) IBOutlet UIButton *addressBookButton;
@property (nonatomic, strong) IBOutlet UIButton *continuePaymentAccessoryButton;
@property (nonatomic, strong) IBOutlet UIButton *continuePaymentButton;
@property (nonatomic, strong) IBOutlet UIButton *feeOptionsButton;
@property (nonatomic, strong) IBOutlet UIButton *fundsAvailableButton;
@property (nonatomic, strong) IBOutlet UIButton *selectFromButton;
@property (nonatomic, strong) IBOutlet UIButton *sendProgressCancelButton;
@property (nonatomic, strong) IBOutlet UILabel *btcLabel;
@property (nonatomic, strong) IBOutlet UILabel *feeLabel;
@property (nonatomic, strong) IBOutlet UILabel *fiatLabel;
@property (nonatomic, strong) IBOutlet UILabel *fromLabel;
@property (nonatomic, strong) IBOutlet UILabel *labelAddressLabel;
@property (nonatomic, strong) IBOutlet UILabel *sendProgressModalText;
@property (nonatomic, strong) IBOutlet UILabel *toLabel;
@property (nonatomic, strong) IBOutlet UITextField *btcAmountField;
@property (nonatomic, strong) IBOutlet UITextField *feeField;
@property (nonatomic, strong) IBOutlet UITextField *fiatAmountField;
@property (nonatomic, strong) IBOutlet UITextField *labelAddressTextField;
@property (nonatomic, strong) IBOutlet UITextField *selectAddressTextField;
@property (nonatomic, strong) IBOutlet UITextField *toField;
@property (nonatomic, strong) IBOutlet UIView *amountKeyboardAccessoryView;
@property (nonatomic, strong) IBOutlet UIView *bottomContainerView;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *feeTappableView;
@property (nonatomic, strong) IBOutlet UIView *labelAddressView;
@property (nonatomic, strong) IBOutlet UIView *sendProgressModal;

@end


@implementation SendBitcoinViewController

#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.sendProgressModalText.text = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    UIEdgeInsets safeAreaInsets = window.rootViewController.view.safeAreaInsets;
    CGFloat availableHeight = window.bounds.size.height;
    CGFloat assetSelectorHeight = 36;
    CGFloat navBarHeight = [ConstantsObjcBridge defaultNavigationBarHeight];
    CGFloat tabBarHeight = 49;

    CGFloat topConstant = availableHeight - safeAreaInsets.top - navBarHeight - assetSelectorHeight - tabBarHeight - safeAreaInsets.bottom;
    _continueButtonTopConstraint.constant = topConstant - BUTTON_HEIGHT - 20;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.deepLinkQRCodeRouter = [[BridgeDeepLinkQRCodeRouter alloc] init];
    
    self.exchangeAddressPresenter = [[SendExchangeAddressStatePresenter alloc] initWithAssetType:self.assetType];
    
    self.bitpayService = [[BridgeBitpayService alloc] init];
    self.analyticsRecorder = [[BridgeAnalyticsRecorder alloc] init];

    self.view.frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:YES assetSelector:YES];

    [self.containerView changeWidth:self.view.frame.size.width];

    [self.selectAddressTextField changeWidth:self.view.frame.size.width - self.fromLabel.frame.size.width - 15 - 13 - self.selectFromButton.frame.size.width];
    [self.selectFromButton changeXPosition:self.view.frame.size.width - self.selectFromButton.frame.size.width];

    [self.addressBookButton changeXPosition:self.view.frame.size.width - self.addressBookButton.frame.size.width];

    CGFloat exchangeAddressButtonWidth = 50.0f;
    UIButton *exchangeAddressButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - self.addressBookButton.bounds.size.width - exchangeAddressButtonWidth, self.addressBookButton.frame.origin.y, exchangeAddressButtonWidth, self.addressBookButton.bounds.size.height)];
    [exchangeAddressButton setImage:[UIImage imageNamed:@"exchange-icon-small"] forState:UIControlStateNormal];
    [exchangeAddressButton addTarget:self action:@selector(exchangeAddressButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    exchangeAddressButton.hidden = true;
    [self.view addSubview:exchangeAddressButton];
    self.exchangeAddressButton = exchangeAddressButton;
    [self.exchangeAddressButton changeXPosition:self.view.bounds.size.width - self.addressBookButton.frame.size.width - self.exchangeAddressButton.bounds.size.width];

    self.bitpayLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.lineBelowFeeField.superview.frame.origin.y + self.lineBelowFeeField.superview.frame.size.height + 2, self.view.frame.size.width, 64)];
    [self.view addSubview:self.bitpayLabel];
    self.bitpayLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    self.bitpayLabel.adjustsFontSizeToFitWidth = YES;
    self.bitpayLabel.textColor = UIColor.gray5;
    self.bitpayLabel.hidden = YES;
    
    self.bitpayTimeRemainingText = [[UILabel alloc] initWithFrame:CGRectMake(15, self.lineBelowFeeField.superview.frame.origin.y + self.lineBelowFeeField.superview.frame.size.height + 2, self.view.frame.size.width, 21)];
    [self.view addSubview:self.bitpayTimeRemainingText];
    self.bitpayTimeRemainingText.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_SMALL];
    self.bitpayTimeRemainingText.adjustsFontSizeToFitWidth = YES;
    self.bitpayTimeRemainingText.textColor = UIColor.gray3;
    self.bitpayTimeRemainingText.hidden = YES;
    
    self.bitpayLogo = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 83, self.lineBelowFeeField.superview.frame.origin.y + self.lineBelowFeeField.superview.frame.size.height + 23, 68, 24)];
    self.bitpayLogo.image = [UIImage imageNamed:@"bitpay-logo"];
    [self.view addSubview:self.bitpayLogo];
    self.bitpayLogo.hidden = YES;
    
    self.lineBelowBitpayLabel = [[BCLine alloc] initWithFrame:CGRectMake(16, self.lineBelowFeeField.superview.frame.origin.y + self.lineBelowFeeField.superview.frame.size.height + 64, self.view.frame.size.width, 1)];
    self.lineBelowBitpayLabel.backgroundColor = UIColor.gray1;
    self.lineBelowBitpayLabel.hidden = YES;
    [self.view addSubview:self.lineBelowBitpayLabel];

    
    [self.toField changeWidth:self.view.frame.size.width - self.toLabel.frame.size.width - self.addressBookButton.frame.size.width - self.exchangeAddressButton.bounds.size.width - 16];
    
    self.destinationAddressIndicatorLabel = [[UILabel alloc] initWithFrame:self.toField.frame];
    self.destinationAddressIndicatorLabel.font = self.selectAddressTextField.font;
    self.destinationAddressIndicatorLabel.textColor = self.selectAddressTextField.textColor;
    NSString *symbol = [AssetTypeLegacyHelper displayCodeFor:self.assetType];
    self.destinationAddressIndicatorLabel.text = [NSString stringWithFormat:[LocalizationConstantsObjcBridge sendAssetExchangeDestination], symbol];
    self.destinationAddressIndicatorLabel.hidden = true;
    [self.view addSubview:self.destinationAddressIndicatorLabel];
    
    CGFloat amountFieldWidth = (self.view.frame.size.width - self.btcLabel.frame.origin.x - self.btcLabel.frame.size.width - self.fiatLabel.frame.size.width - 15 - 13 - 8 - 13)/2;
    self.btcAmountField.frame = CGRectMake(self.btcAmountField.frame.origin.x, self.btcAmountField.frame.origin.y, amountFieldWidth, self.btcAmountField.frame.size.height);
    self.fiatLabel.frame = CGRectMake(self.btcAmountField.frame.origin.x + self.btcAmountField.frame.size.width + 8, self.fiatLabel.frame.origin.y, self.fiatLabel.frame.size.width, self.fiatLabel.frame.size.height);
    self.fiatAmountField.frame = CGRectMake(self.fiatLabel.frame.origin.x + self.fiatLabel.frame.size.width + 13, self.fiatAmountField.frame.origin.y, amountFieldWidth, self.fiatAmountField.frame.size.height);
    
    self.btcAmountField.inputAccessoryView = self.amountKeyboardAccessoryView;
    self.fiatAmountField.inputAccessoryView = self.amountKeyboardAccessoryView;
    self.toField.inputAccessoryView = self.amountKeyboardAccessoryView;
    self.feeField.inputAccessoryView = self.amountKeyboardAccessoryView;
    
    self.fromLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    self.selectAddressTextField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.destinationAddressIndicatorLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.toLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    self.toField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.btcLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    self.btcAmountField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.fiatLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    self.fiatAmountField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.feeLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL];
    self.feeField.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    
    [self setupFeeLabels];

    [self setupFeeWarningLabelFrameSmall];

    [self.feeOptionsButton changeXPosition:self.view.frame.size.width - self.feeOptionsButton.frame.size.width];

    self.feeDescriptionLabel.frame = CGRectMake(self.feeField.frame.origin.x, self.feeField.center.y, self.btcAmountField.frame.size.width*2/3, 20);
    self.feeDescriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.feeTypeLabel.frame = CGRectMake(self.feeField.frame.origin.x, self.feeField.center.y - 20, self.btcAmountField.frame.size.width*2/3, 20);
    CGFloat amountLabelOriginX = self.feeTypeLabel.frame.origin.x + self.feeTypeLabel.frame.size.width;
    self.feeTypeLabel.adjustsFontSizeToFitWidth = YES;
    self.feeAmountLabel.frame = CGRectMake(amountLabelOriginX, self.feeField.center.y - 10, self.feeOptionsButton.frame.origin.x - amountLabelOriginX, 20);
    self.feeAmountLabel.adjustsFontSizeToFitWidth = YES;

    [self.feeField changeWidth:self.feeAmountLabel.frame.origin.x - (self.feeLabel.frame.origin.x + self.feeLabel.frame.size.width) - (self.feeField.frame.origin.x - (self.feeLabel.frame.origin.x + self.feeLabel.frame.size.width))];
    
    self.fundsAvailableButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    [self.fundsAvailableButton setTitleColor:UIColor.brandSecondary forState:UIControlStateNormal];
    self.fundsAvailableButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.feeField.delegate = self;
        
    self.toField.placeholder =  self.assetType == LegacyAssetTypeBitcoin ? BC_STRING_ENTER_BITCOIN_ADDRESS_OR_SELECT : BC_STRING_ENTER_BITCOIN_CASH_ADDRESS_OR_SELECT;
    self.feeField.placeholder = BC_STRING_SATOSHI_PER_BYTE_ABBREVIATED;
    self.btcAmountField.placeholder = [NSString stringWithFormat:BTC_PLACEHOLDER_DECIMAL_SEPARATOR_ARGUMENT, [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];
    self.fiatAmountField.placeholder = [NSString stringWithFormat:FIAT_PLACEHOLDER_DECIMAL_SEPARATOR_ARGUMENT, [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator]];

    self.toField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.toField setReturnKeyType:UIReturnKeyDone];
    
    CGFloat continueButtonOriginY = [self continuePaymentButtonOriginY];
    self.continuePaymentButton.frame = CGRectMake(0, continueButtonOriginY, self.view.frame.size.width - 40, BUTTON_HEIGHT);
    
    if (self.assetType == LegacyAssetTypeBitcoin) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(feeOptionsClicked:)];
        [self.feeTappableView addGestureRecognizer:tapGestureRecognizer];
    }

    [self setupNavigationBar];
    
    [self reload];
    
    if (self.onViewDidLoad) {
        self.onViewDidLoad();
        self.onViewDidLoad = nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadLocalAndBtcSymbolsFromLatestResponse)
                                                 name:@"fiat_currency_selected"
                                               object:nil];
}

- (void)setupNavigationBar {

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[[UIImage imageNamed:@"close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(leftBarButtonTapped)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[[UIImage imageNamed:@"qr-code-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(rightBarButtonTapped)];
}

- (void)leftBarButtonTapped {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)rightBarButtonTapped {
    [self QRCodeButtonClicked];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isReloading) {
        return;
    }
    
    self.availableAmount = [[WalletManager.sharedInstance.wallet getBalanceForAccount:self.fromAccount assetType:self.assetType] longLongValue];
}

- (void)setupFeeLabels
{
    self.feeDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.feeDescriptionLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.feeDescriptionLabel.textColor = UIColor.gray2;
    [self.bottomContainerView addSubview:self.feeDescriptionLabel];
    
    self.feeTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.feeTypeLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.feeTypeLabel.textColor = UIColor.gray5;
    [self.bottomContainerView addSubview:self.feeTypeLabel];
    
    self.feeAmountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.feeAmountLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_SMALL];
    self.feeAmountLabel.textColor = UIColor.gray5;
    [self.bottomContainerView addSubview:self.feeAmountLabel];
    
    self.feeWarningLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    // Use same font size for all screen sizes
    self.feeWarningLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_SMALL];
    self.feeWarningLabel.textColor = UIColor.error;
    self.feeWarningLabel.numberOfLines = 2;
    [self.bottomContainerView addSubview:self.feeWarningLabel];
}

- (void)resetPayment
{
    self.surgeIsOccurring = NO;
    self.dust = 0;

    [WalletManager.sharedInstance.wallet createNewPayment:self.assetType];
    [self resetFromAddress];

    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionPush];
    self.transactionType = SendTransactionTypeRegular;
}

- (void)resetFromAddress
{
    self.fromAddress = @"";
    if ([WalletManager.sharedInstance.wallet hasAccount]) {
        // Default setting: send from default account
        self.sendFromAddress = false;
        int defaultAccountIndex = [WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType];
        self.fromAccount = defaultAccountIndex;
        if (self.isReloading) return; // didSelectFromAccount will be called in reloadAfterMultiAddressResponse
        [self didSelectFromAccount:self.fromAccount assetType:self.assetType];
    }
    else {
        // Default setting: send from any address
        self.sendFromAddress = true;
        if (self.isReloading) return; // didSelectFromAddress will be called in reloadAfterMultiAddressResponse
        [self didSelectFromAddress:self.fromAddress];
    }
}

- (void)clearToAddressAndAmountFields
{
    self.toAddress = @"";
    self.toField.text = @"";
    self.amountInSatoshi = 0;
    self.btcAmountField.text = @"";
    self.fiatAmountField.text = @"";
    self.feeField.text = @"";
}

- (void)reload
{
    self.isReloading = YES;
    
    [self clearToAddressAndAmountFields];

    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"SendViewController: Wallet not initialized");
        return;
    }
    
    if (!WalletManager.sharedInstance.latestMultiAddressResponse) {
        DLog(@"SendViewController: No latest response");
        return;
    }
    
    [self resetPayment];
    
    // Default: send to address
    self.sendToAddress = true;
    
    [self hideSelectFromAndToButtonsIfAppropriate];
    
    [self populateFieldsFromURLHandlerIfAvailable];
    
    [self reloadFromAndToFields];
    
    [self reloadSymbols];
    
    [self updateFundsAvailable];
    
    [self enablePaymentButtons];
    
    [self setupFees];
    
    [self enableInputs];
    
    [self.bitpayTimer invalidate];
    
    self.bitpayLabel.hidden = YES;
    self.bitpayLogo.hidden = YES;
    self.bitpayTimeRemainingText.hidden = YES;
    self.lineBelowBitpayLabel.hidden = YES;
    
    self.sendProgressCancelButton.hidden = YES;
    
    [self enableAmountViews];
    [self enableToField];
    
    self.isSending = NO;
    self.isReloading = NO;

    self.isBitpayPayPro = NO;
    
    self.noteToSet = nil;
    
    __weak SendBitcoinViewController *weakSelf = self;
    
    self.exchangeAddressPresenter = [[SendExchangeAddressStatePresenter alloc] initWithAssetType:self.assetType];
    
    [self.exchangeAddressPresenter fetchAddressViewModelWithCompletion:^(ExchangeAddressViewModel * _Nonnull viewModel) {
        weakSelf.exchangeAddressViewModel = viewModel;
        weakSelf.exchangeAddressButton.hidden = viewModel.isExchangeLinked == NO;
    }];
}

- (void)reloadAfterMultiAddressResponse
{
    [self hideSelectFromAndToButtonsIfAppropriate];
    
    [self reloadLocalAndBtcSymbolsFromLatestResponse];
    
    if (self.sendFromAddress) {
        [self changePaymentFromAddress:self.fromAddress];
    } else {
        [self changePaymentFromAccount:self.fromAccount];
    }
    
    if (self.shouldReloadFeeAmountLabel) {
        self.shouldReloadFeeAmountLabel = NO;
        if (self.feeAmountLabel.text) {
            [self updateFeeAmountLabelText:self.lastDisplayedFee];
        }
    }
}

- (void)reloadFeeAmountLabel
{
    self.shouldReloadFeeAmountLabel = YES;
}

- (void)reloadSymbols
{
    [self reloadLocalAndBtcSymbolsFromLatestResponse];
    [self updateFundsAvailable];
}

- (void)hideSelectFromAndToButtonsIfAppropriate
{
    if ([WalletManager.sharedInstance.wallet getActiveAccountsCount:self.assetType] + [[WalletManager.sharedInstance.wallet activeLegacyAddresses:self.assetType] count] == 1) {
        [self.selectFromButton setHidden:YES];
        if ([WalletManager.sharedInstance.wallet addressBook].count == 0) {
            [self.addressBookButton setHidden:YES];
        } else {
            [self.addressBookButton setHidden:NO];
        }
    }
    else {
        [self.selectFromButton setHidden:NO];
        [self.addressBookButton setHidden:NO];
    }
}

- (void)populateFieldsFromURLHandlerIfAvailable
{
    if (self.addressFromURLHandler && self.toField != nil) {
        self.sendToAddress = true;
        self.toAddress = self.addressFromURLHandler;
        DLog(@"toAddress: %@", self.toAddress);
        
        self.toField.text = [WalletManager.sharedInstance.wallet labelForLegacyAddress:self.toAddress assetType:self.assetType];
        self.addressFromURLHandler = nil;
        
        self.amountInSatoshi = self.amountFromURLHandler;
        [self performSelector:@selector(doCurrencyConversion) withObject:nil afterDelay:0.1f];
        self.amountFromURLHandler = 0;
    }
}

- (void)reloadFromAndToFields
{
    [self reloadFromField];
    [self reloadToField];
}

- (void)reloadFromField
{
    if (self.sendFromAddress) {
        if (self.fromAddress.length == 0) {
            self.selectAddressTextField.text = BC_STRING_ANY_ADDRESS;
            self.availableAmount = [WalletManager.sharedInstance.wallet getTotalBalanceForSpendableActiveLegacyAddresses];
        }
        else {
            self.selectAddressTextField.text = [WalletManager.sharedInstance.wallet labelForLegacyAddress:self.fromAddress assetType:self.assetType];
            self.availableAmount = [[WalletManager.sharedInstance.wallet getLegacyAddressBalance:self.fromAddress assetType:self.assetType] longLongValue];
        }
    }
    else {
        self.selectAddressTextField.text = [WalletManager.sharedInstance.wallet getLabelForAccount:self.fromAccount assetType:self.assetType];
        self.availableAmount = [[WalletManager.sharedInstance.wallet getBalanceForAccount:self.fromAccount assetType:self.assetType] longLongValue];
    }
}

- (void)reloadToField
{
    if (self.sendToAddress) {
        self.toField.text = [WalletManager.sharedInstance.wallet labelForLegacyAddress:self.toAddress assetType:self.assetType];
        if ([WalletManager.sharedInstance.wallet isValidAddress:self.toAddress assetType:self.assetType]) {
            [self selectToAddress:self.toAddress];
        } else {
            self.toField.text = @"";
            self.toAddress = @"";
        }
    }
    else {
        self.toField.text = [WalletManager.sharedInstance.wallet getLabelForAccount:self.toAccount assetType:self.assetType];
        [self selectToAccount:self.toAccount];
    }
}

- (void)reloadLocalAndBtcSymbolsFromLatestResponse
{
    if (WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local) {
        self.fiatLabel.text = [BlockchainSettingsApp.shared fiatCurrencySymbol];
        self.btcLabel.text = self.assetType == LegacyAssetTypeBitcoin ? CURRENCY_SYMBOL_BTC : CURRENCY_SYMBOL_BCH;
    }
    
    if (BlockchainSettingsApp.shared.symbolLocal && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local && WalletManager.sharedInstance.latestMultiAddressResponse.symbol_local.conversion > 0) {
        self.displayingLocalSymbol = TRUE;
        self.displayingLocalSymbolSend = TRUE;
    } else {
        self.displayingLocalSymbol = FALSE;
        self.displayingLocalSymbolSend = FALSE;
    }
}

#pragma mark - Exchange address button

- (void)exchangeAddressButtonPressed {
    switch (self.addressSource) {
        case DestinationAddressSourceExchange:
            [self.exchangeAddressButton setImage:[UIImage imageNamed:@"exchange-icon-small"] forState:UIControlStateNormal];
            self.addressSource = DestinationAddressSourcePaste;
            self.toAddress = nil;
            self.toField.hidden = false;
            self.toField.text = nil;
            self.destinationAddressIndicatorLabel.hidden = true;
            break;
        default: // Any other state (doesn't matter which)
            [self reportExchangeButtonClick];
            /// The user tapped the Exchange button to send funds to the Exchange.
            /// We must confirm that 2FA is enabled otherwise we will not have a destination address
            if (self.exchangeAddressViewModel != nil && self.exchangeAddressViewModel.legacyAssetType == self.assetType) {
                if (self.exchangeAddressViewModel.address != nil) {
                    [self.exchangeAddressButton setImage:[UIImage imageNamed:@"cancel_icon"] forState:UIControlStateNormal];
                    self.addressSource = DestinationAddressSourceExchange;
                    self.toField.hidden = true;
                    [self selectToAddress:self.exchangeAddressViewModel.address];
                    self.destinationAddressIndicatorLabel.hidden = false;
                } else {
                    [AlertViewPresenter.shared standardErrorWithTitle:BC_STRING_ERROR message:[LocalizationConstantsObjcBridge twoFactorExchangeDisabled] in:self handler:nil];
                }
            }
            break;
    }
}

#pragma mark - Payment

- (IBAction)reallyDoPayment:(id)sender
{
    if (self.isBitpayPayPro) {
        
        NSString *bitpayInvoiceID = @"";
        NSString *entry = self.toField.text;
        NSURL *bitpayURLCandidate = [NSURL URLWithString:entry];
        if (bitpayURLCandidate != nil) {
            if ([self isBitpayURL:bitpayURLCandidate])
            {
                bitpayInvoiceID = [self invoiceIDFromBitPayURL:bitpayURLCandidate];
            }
        }
        
        if (bitpayInvoiceID.length == 0) {
            DLog(@"Expected an invoiceID.");
            [self handleSigningPaymentError:BC_STRING_ERROR];
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        if (self.assetType == LegacyAssetTypeBitcoinCash) {
            [WalletManager.sharedInstance.wallet signBitcoinCashPaymentWithSecondPassword:nil successBlock:^(NSString * _Nonnull transactionHex) {
                NSArray *hexAndWeight = [transactionHex componentsSeparatedByString:@","];
                NSString *hex = [hexAndWeight firstObject];
                NSString *weight = [hexAndWeight lastObject];
                [weakSelf verifyAndPostBitpayWithInvoiceID:bitpayInvoiceID transactionHex:hex transactionSize:weight];
            } error:^(NSString * _Nonnull errorMessage) {
                [weakSelf handleSigningPaymentError:errorMessage];
            }];
        }
        if (self.assetType == LegacyAssetTypeBitcoin) {
            [WalletManager.sharedInstance.wallet signBitcoinPaymentWithSecondPassword:nil successBlock:^(NSString * _Nonnull transactionHex) {
                NSArray *hexAndWeight = [transactionHex componentsSeparatedByString:@","];
                NSString *hex = [hexAndWeight firstObject];
                NSString *weight = [hexAndWeight lastObject];
                [weakSelf verifyAndPostBitpayWithInvoiceID:bitpayInvoiceID transactionHex:hex transactionSize:weight];
            } error:^(NSString * _Nonnull errorMessage) {
                [weakSelf handleSigningPaymentError:errorMessage];
            }];
        }
        return;
    }
    if (self.sendFromAddress && [WalletManager.sharedInstance.wallet isWatchOnlyLegacyAddress:self.fromAddress]) {
        return;
    }
    [self sendPaymentWithListener];
}

- (void)handleSigningPaymentError:(NSString *)errorMessage
{
    DLog(@"Send error: %@", errorMessage);
    [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:errorMessage in:self handler: nil];
    
    [self.sendProgressActivityIndicator stopAnimating];
    
    [self enablePaymentButtons];
    
    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
    
    [self reload];
    
    [WalletManager.sharedInstance.wallet getHistory];
}

- (void)verifyAndPostBitpayWithInvoiceID:(NSString *)invoiceID transactionHex:(NSString *)transactionHex transactionSize:(NSString *)size
{
    [self.bitpayService verifyAndPostSignedTransactionWithInvoiceID:invoiceID assetType:self.assetType transactionHex:transactionHex transactionSize:size completion:^(NSString * _Nullable memo, NSError * _Nullable error) {
        /// The transaction was successful
        if (memo != nil) {
            [WalletActionEventBus.sharedInstance publishObjWithAction:WalletActionSendCrypto extras:nil];
            UIAlertController *paymentSentAlert = [UIAlertController alertControllerWithTitle:[LocalizationConstantsObjcBridge success] message:BC_STRING_PAYMENT_SENT preferredStyle:UIAlertControllerStyleAlert];
            [paymentSentAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [[AppReviewPrompt sharedInstance] showIfNeeded];
            }]];
            
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:paymentSentAlert animated:YES completion:nil];
            
            [self.sendProgressActivityIndicator stopAnimating];
            
            [self enablePaymentButtons];
            
            // Fields are automatically reset by reload, called by MyWallet.wallet.getHistory() after a utx websocket message is received. However, we cannot rely on the websocket 100% of the time.
            if (self.assetType == LegacyAssetTypeBitcoin) {
                [WalletManager.sharedInstance.wallet performSelector:@selector(getHistoryIfNoTransactionMessage) withObject:nil afterDelay:DELAY_GET_HISTORY_BACKUP];
            } else {
                [WalletManager.sharedInstance.wallet performSelector:@selector(getBitcoinCashHistoryIfNoTransactionMessage) withObject:nil afterDelay:DELAY_GET_HISTORY_BACKUP];
            }
            
            // Close transaction modal, go to transactions view, scroll to top and animate new transaction
            [self.bitpayTimer invalidate];
            
            [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
            TabControllerManager *tabControllerManager = AppCoordinator.shared.tabControllerManager;
            // TODO: IOS-3395
            // This selects Activity screen. Then it was instructing transactionsBitcoinViewController to display the new transaction.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tabControllerManager showTransactions];
            });
            [self reload];
        }
        /// The transaction was not successful
        if (error != nil) {
            DLog(@"Send error: %@", error);
            [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:error.localizedDescription in:self handler: nil];
            
            [self.sendProgressActivityIndicator stopAnimating];
            
            [self enablePaymentButtons];
            
            [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
            
            [self reload];
            
            [WalletManager.sharedInstance.wallet getHistory];
        }
    }];
}

- (void)getInfoForTransferAllFundsToDefaultAccount
{
    [LoadingViewPresenter.shared showWith:BC_STRING_TRANSFER_ALL_PREPARING_TRANSFER];
    
    [WalletManager.sharedInstance.wallet getInfoForTransferAllFundsToAccount];
}

- (void)transferFundsToDefaultAccountFromAddress:(NSString *)address
{
    [self didSelectFromAddress:address];
    
    [self selectToAccount:[WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType]];
    
    [WalletManager.sharedInstance.wallet transferFundsToDefaultAccountFromAddress:address];
}

- (void)sendPaymentWithListener
{
    [self disablePaymentButtons];
    
    [self.sendProgressActivityIndicator startAnimating];
    
    self.sendProgressModalText.text = BC_STRING_SENDING_TRANSACTION;

    [[ModalPresenter sharedInstance] showModalWithContent:self.sendProgressModal closeType:ModalCloseTypeNone showHeader:true headerText:BC_STRING_SENDING_TRANSACTION onDismiss:nil onResume:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        TransactionProgressListeners *listener = [[TransactionProgressListeners alloc] init];
         
         listener.on_start = ^() {
         };
         
         listener.on_begin_signing = ^(NSString* intput) {
             self.sendProgressModalText.text = BC_STRING_SIGNING_INPUTS;
         };
         
         listener.on_sign_progress = ^(int input) {
             DLog(@"Signing input: %d", input);
             self.sendProgressModalText.text = [NSString stringWithFormat:BC_STRING_SIGNING_INPUT, input];
         };
         
         listener.on_finish_signing = ^(NSString* intput) {
             self.sendProgressModalText.text = BC_STRING_FINISHED_SIGNING_INPUTS;
         };
         
         listener.on_success = ^(NSString*secondPassword, NSString *transactionHash, NSString *transactionHex) {
             DLog(@"SendViewController: on_success");
             [WalletActionEventBus.sharedInstance publishObjWithAction:WalletActionSendCrypto extras:nil];

             [self reportSendSummaryConfirmSuccess];
             
             [self.sendProgressActivityIndicator stopAnimating];
             
             [self enablePaymentButtons];
             
             // Fields are automatically reset by reload, called by MyWallet.wallet.getHistory() after a utx websocket message is received. However, we cannot rely on the websocket 100% of the time.
             if (self.assetType == LegacyAssetTypeBitcoin) {
                 [WalletManager.sharedInstance.wallet performSelector:@selector(getHistoryIfNoTransactionMessage) withObject:nil afterDelay:DELAY_GET_HISTORY_BACKUP];
             } else {
                 [WalletManager.sharedInstance.wallet performSelector:@selector(getBitcoinCashHistoryIfNoTransactionMessage) withObject:nil afterDelay:DELAY_GET_HISTORY_BACKUP];
             }

             if (self.isBitpayPayPro) {
                 [self.bitpayTimer invalidate];
             }

             if (self.noteToSet) {
                 [WalletManager.sharedInstance.wallet saveNote:self.noteToSet forTransaction:transactionHash];
             }

             // Close transaction modal
             [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];

             UIAlertController *paymentSentAlert = [UIAlertController
                                                    alertControllerWithTitle:[LocalizationConstantsObjcBridge success]
                                                    message:BC_STRING_PAYMENT_SENT
                                                    preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction* okAction = [UIAlertAction
                                        actionWithTitle:BC_STRING_OK
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * _Nonnull action) {
                 [[AppReviewPrompt sharedInstance] showIfNeeded];
             }];
             [paymentSentAlert addAction:okAction];

             // Close Send modal
             [self dismissViewControllerAnimated:true completion:^{
                 TabControllerManager *tabControllerManager = AppCoordinator.shared.tabControllerManager;
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     // And switch to transactions list
                     [tabControllerManager showTransactions];
                     // And display sent alert.
                     [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:paymentSentAlert animated:YES completion:nil];
                 });
             }];
         };
         
         listener.on_error = ^(NSString* error, NSString* secondPassword) {
             DLog(@"Send error: %@", error);
                          
             [self reportSendSummaryConfirmFailure];
             
             if ([error isEqualToString:ERROR_UNDEFINED]) {
                 [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:BC_STRING_SEND_ERROR_NO_INTERNET_CONNECTION in:self handler: nil];
             } else if ([error isEqualToString:ERROR_FEE_TOO_LOW]) {
                 [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:BC_STRING_SEND_ERROR_FEE_TOO_LOW in:self handler: nil];
             } else if ([error isEqualToString:ERROR_FAILED_NETWORK_REQUEST]) {
                 [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:[LocalizationConstantsObjcBridge requestFailedCheckConnection] in:self handler: nil];
             } else if (error && error.length != 0)  {
                 [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:error in:self handler: nil];
             }
             
             [self.sendProgressActivityIndicator stopAnimating];
             
             [self enablePaymentButtons];
             
             [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
             
             [self reload];
             
             [WalletManager.sharedInstance.wallet getHistory];
         };
         
         NSString *amountString = [[NSNumber numberWithLongLong:self.amountInSatoshi] stringValue];
         
         DLog(@"Sending uint64_t %llu Satoshi (String value: %@)", self.amountInSatoshi, amountString);
         
         // Different ways of sending (from/to address or account
         if (self.sendFromAddress && self.sendToAddress) {
             DLog(@"From: %@", self.fromAddress);
             DLog(@"To: %@", self.toAddress);
         }
         else if (self.sendFromAddress && !self.sendToAddress) {
             DLog(@"From: %@", self.fromAddress);
             DLog(@"To account: %d", self.toAccount);
         }
         else if (!self.sendFromAddress && self.sendToAddress) {
             DLog(@"From account: %d", self.fromAccount);
             DLog(@"To: %@", self.toAddress);
         }
         else if (!self.sendFromAddress && !self.sendToAddress) {
             DLog(@"From account: %d", self.fromAccount);
             DLog(@"To account: %d", self.toAccount);
         }
         
         WalletManager.sharedInstance.wallet.didReceiveMessageForLastTransaction = NO;
         
         [self sendPaymentWithListener:listener secondPassword:nil];
    });
}

- (void)transferAllFundsToDefaultAccount
{
    __weak SendBitcoinViewController *weakSelf = self;
    
    self.transferAllPaymentBuilder.on_before_send = ^() {
        
        SendBitcoinViewController *strongSelf = weakSelf;
        
        [weakSelf hideKeyboard];
        
        [weakSelf disablePaymentButtons];
        
        [strongSelf.sendProgressActivityIndicator startAnimating];
        
        if (weakSelf.transferAllPaymentBuilder.transferAllAddressesInitialCount - [weakSelf.transferAllPaymentBuilder.transferAllAddressesToTransfer count] <= weakSelf.transferAllPaymentBuilder.transferAllAddressesInitialCount) {
            strongSelf.sendProgressModalText.text = [NSString stringWithFormat:BC_STRING_TRANSFER_ALL_FROM_ADDRESS_ARGUMENT_ARGUMENT, weakSelf.transferAllPaymentBuilder.transferAllAddressesInitialCount - [weakSelf.transferAllPaymentBuilder.transferAllAddressesToTransfer count] + 1, weakSelf.transferAllPaymentBuilder.transferAllAddressesInitialCount];
        }

        [[ModalPresenter sharedInstance] showModalWithContent:strongSelf.sendProgressModal closeType:ModalCloseTypeNone showHeader:true headerText:BC_STRING_SENDING_TRANSACTION onDismiss:^{
            [LoadingViewPresenter.shared setIsEnabled:TRUE];
        } onResume:^{
            [LoadingViewPresenter.shared setIsEnabled:TRUE];
        }];
        
        [UIView animateWithDuration:0.3f animations:^{
            UIButton *cancelButton = strongSelf.self.sendProgressCancelButton;
            strongSelf.self.sendProgressCancelButton.frame = CGRectMake(0, self.view.frame.size.height + DEFAULT_FOOTER_HEIGHT - cancelButton.frame.size.height, cancelButton.frame.size.width, cancelButton.frame.size.height);
        }];
        
        // Once the modal
        [LoadingViewPresenter.shared setIsEnabled:FALSE];
        weakSelf.isSending = YES;
    };
    
    self.transferAllPaymentBuilder.on_prepare_next_transfer = ^(NSArray *transferAllAddressesToTransfer) {
        weakSelf.fromAddress = transferAllAddressesToTransfer[0];
    };
    
    self.transferAllPaymentBuilder.on_success = ^(NSString *secondPassword) {
        
    };
    
    self.transferAllPaymentBuilder.on_error = ^(NSString *error, NSString *secondPassword) {
        
        SendBitcoinViewController *strongSelf = weakSelf;

        [[ModalPresenter sharedInstance] closeAllModals];

        [strongSelf.sendProgressActivityIndicator stopAnimating];
        
        [weakSelf enablePaymentButtons];
        
        [weakSelf reload];
    };

    [self.transferAllPaymentBuilder transferAllFundsToAccountWithSecondPassword:nil];
}

- (void)didFinishTransferFunds:(NSString *)summary
{
    NSString *message = [self.transferAllPaymentBuilder.transferAllAddressesTransferred count] > 0 ? [NSString stringWithFormat:@"%@\n\n%@", summary, BC_STRING_PAYMENT_ASK_TO_ARCHIVE_TRANSFERRED_ADDRESSES] : summary;
    
    UIAlertController *alertForPaymentsSent = [UIAlertController alertControllerWithTitle:BC_STRING_PAYMENTS_SENT message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if ([self.transferAllPaymentBuilder.transferAllAddressesTransferred count] > 0) {
        [alertForPaymentsSent addAction:[UIAlertAction actionWithTitle:BC_STRING_ARCHIVE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self archiveTransferredAddresses];
        }]];
        [alertForPaymentsSent addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];
    } else {
        [alertForPaymentsSent addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    }

    TabControllerManager *tabControllerManager = AppCoordinator.shared.tabControllerManager;
    [tabControllerManager.tabViewController presentViewController:alertForPaymentsSent animated:YES completion:nil];
    
    [self.sendProgressActivityIndicator stopAnimating];
    
    [self enablePaymentButtons];
    
    // Fields are automatically reset by reload, called by MyWallet.wallet.getHistory() after a utx websocket message is received. However, we cannot rely on the websocket 100% of the time.
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [WalletManager.sharedInstance.wallet performSelector:@selector(getHistoryIfNoTransactionMessage) withObject:nil afterDelay:DELAY_GET_HISTORY_BACKUP];
    } else {
        [WalletManager.sharedInstance.wallet performSelector:@selector(getBitcoinCashHistoryIfNoTransactionMessage) withObject:nil afterDelay:DELAY_GET_HISTORY_BACKUP];
    }
    
    // Close transaction modal, go to transactions view, scroll to top and animate new transaction
    [[ModalPresenter sharedInstance] closeAllModals];
    // TODO: IOS-3395
    // This selects Activity screen. Then it was instructing transactionsBitcoinViewController to display the new transaction.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tabControllerManager showTransactions];
    });
    
    [self reload];
}

- (void)sendDuringTransferAll:(NSString *)secondPassword
{
    [self.transferAllPaymentBuilder transferAllFundsToAccountWithSecondPassword:secondPassword];
}

- (void)didErrorDuringTransferAll:(NSString *)error secondPassword:(NSString *)secondPassword
{
    [[ModalPresenter sharedInstance] closeAllModals];
    [self reload];
    
    [self showErrorBeforeSending:error];
}

- (void)showSummary
{
    [self showSummaryForTransferAllWithCustomFromLabel:nil];
}

- (void)showSummaryForTransferAllWithCustomFromLabel:(NSString *)customFromLabel
{
    [self hideKeyboard];
    
    // Timeout so the keyboard is fully dismised - otherwise the second password modal keyboard shows the send screen kebyoard accessory
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([self transferAllMode]) {
            [[ModalPresenter sharedInstance].modalView.backButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
        }
        
        uint64_t amountTotal = self.amountInSatoshi + self.feeFromTransactionProposal + self.dust;
        uint64_t feeTotal = self.dust + self.feeFromTransactionProposal;
        
        NSString *fromAddressLabel = self.sendFromAddress ? [WalletManager.sharedInstance.wallet labelForLegacyAddress:self.fromAddress assetType:self.assetType] : [WalletManager.sharedInstance.wallet getLabelForAccount:self.fromAccount assetType:self.assetType];
        
        NSString *fromAddressString = self.sendFromAddress ? self.fromAddress : @"";
        
        if ([self.fromAddress isEqualToString:@""] && self.sendFromAddress) {
            fromAddressString = BC_STRING_ANY_ADDRESS;
        }
        
        // When a legacy wallet has no label, labelForLegacyAddress returns the address, so remove the string
        if ([fromAddressLabel isEqualToString:fromAddressString]) {
            fromAddressLabel = @"";
        }
        
        if (customFromLabel) {
            fromAddressString = customFromLabel;
        }
        
        NSString *toAddressLabel = self.sendToAddress ? [WalletManager.sharedInstance.wallet labelForLegacyAddress:self.toAddress assetType:self.assetType] : [WalletManager.sharedInstance.wallet getLabelForAccount:self.toAccount assetType:self.assetType];
        
        BOOL shouldRemoveToAddress = NO;
        
        NSString *toAddressString = self.sendToAddress ? (shouldRemoveToAddress ? @"" : self.toAddress) : @"";
        
        // When a legacy wallet has no label, labelForLegacyAddress returns the address, so remove the string
        if ([toAddressLabel isEqualToString:toAddressString]) {
            toAddressLabel = @"";
        }
        
        NSString *from = fromAddressLabel.length == 0 ? fromAddressString : fromAddressLabel;
        NSString *to = toAddressLabel.length == 0 ? toAddressString : toAddressLabel;
        
        BOOL surgePresent = self.surgeIsOccurring || [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_SURGE];
        
        BCConfirmPaymentViewModel *confirmPaymentViewModel;
        
        NSString *displayDestinationAddress;
        NSString *symbol;
        switch (self.addressSource) {
            case DestinationAddressSourceExchange:
                symbol = [AssetTypeLegacyHelper displayCodeFor: self.assetType];
                displayDestinationAddress = [NSString stringWithFormat:[LocalizationConstantsObjcBridge sendAssetExchangeDestination], symbol];
                break;
            case DestinationAddressSourceBitPay:
                displayDestinationAddress = [NSString stringWithFormat: @"BitPay[%@]", self.bitpayMerchant];
                break;
            default:
                displayDestinationAddress = to;
        }
        
        if (self.assetType == LegacyAssetTypeBitcoinCash) {
            confirmPaymentViewModel = [[BCConfirmPaymentViewModel alloc] initWithFrom:from
                                                            destinationDisplayAddress:displayDestinationAddress
                                                                destinationRawAddress:to
                                                                            bchAmount:self.amountInSatoshi
                                                                                  fee:feeTotal
                                                                                total:amountTotal
                                                                                surge:surgePresent];
        } else {
            confirmPaymentViewModel = [[BCConfirmPaymentViewModel alloc] initWithFrom:from
                                                            destinationDisplayAddress:displayDestinationAddress
                                                                destinationRawAddress:to
                                                                               amount:self.amountInSatoshi
                                                                                  fee:feeTotal
                                                                                total:amountTotal
                                                                                surge:surgePresent];
        }

        CGRect frame = self.view.frame;
        CGRect sendButtonFrame = self.continuePaymentButton.frame;
        self.confirmPaymentView = [[BCConfirmPaymentView alloc] initWithFrame:frame
                                                                    viewModel:confirmPaymentViewModel
                                                              sendButtonFrame:sendButtonFrame];
        
        self.confirmPaymentView.confirmDelegate = self;
        
        if (customFromLabel) {
            [self.confirmPaymentView.reallyDoPaymentButton addTarget:self action:@selector(transferAllFundsToDefaultAccount) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [self.confirmPaymentView.reallyDoPaymentButton addTarget:self action:@selector(reallyDoPayment:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.confirmPaymentView.reallyDoPaymentButton addTarget:self action:@selector(reportSendSummaryConfirmClick) forControlEvents:UIControlEventTouchUpInside];

        __weak typeof(self) weakSelf = self;
        void (^onDismiss)(void) = ^{
            [weakSelf enablePaymentButtons];
        };
        [[ModalPresenter sharedInstance] showModalWithContent:self.confirmPaymentView
                                                    closeType:ModalCloseTypeBack
                                                   showHeader:true
                                                   headerText:BC_STRING_CONFIRM_PAYMENT
                                                    onDismiss:onDismiss
                                                     onResume:nil];
        
        NSDecimalNumber *last = [NSDecimalNumber decimalNumberWithDecimal:[[NSDecimalNumber numberWithDouble:[[WalletManager.sharedInstance.wallet.btcRates objectForKey:DICTIONARY_KEY_USD][DICTIONARY_KEY_LAST] doubleValue]] decimalValue]];
        NSDecimalNumber *conversionToUSD = [[NSDecimalNumber decimalNumberWithDecimal:[[NSDecimalNumber numberWithDouble:SATOSHI] decimalValue]] decimalNumberByDividingBy:last];
        NSDecimalNumber *feeConvertedToUSD = [(NSDecimalNumber *)[NSDecimalNumber numberWithLongLong:feeTotal] decimalNumberByDividingBy:conversionToUSD];
        
        NSDecimalNumber *feeRatio = [[NSDecimalNumber decimalNumberWithDecimal:[[NSDecimalNumber numberWithLongLong:feeTotal] decimalValue] ] decimalNumberByDividingBy:(NSDecimalNumber *)[NSDecimalNumber numberWithLongLong:amountTotal]];
        NSDecimalNumber *normalFeeRatio = [NSDecimalNumber decimalNumberWithDecimal:[ONE_PERCENT_DECIMAL decimalValue]];
        
        if ([feeConvertedToUSD compare:[NSDecimalNumber decimalNumberWithDecimal:[FIFTY_CENTS_DECIMAL decimalValue]]] == NSOrderedDescending && self.txSize > TX_SIZE_ONE_KILOBYTE && [feeRatio compare:normalFeeRatio] == NSOrderedDescending) {
            UIAlertController *highFeeAlert = [UIAlertController alertControllerWithTitle:BC_STRING_HIGH_FEE_WARNING_TITLE message:BC_STRING_HIGH_FEE_WARNING_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
            [highFeeAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:highFeeAlert animated:YES completion:nil];
        }
    });
}

- (void)handleZeroSpendableAmount
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_NO_AVAILABLE_FUNDS message:BC_STRING_PLEASE_SELECT_DIFFERENT_ADDRESS preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [[NSNotificationCenter defaultCenter] addObserver:alert selector:@selector(autoDismiss) name:ConstantsObjcBridge.notificationKeyReloadToDismissViews object:nil];
    TabControllerManager *tabControllerManager = AppCoordinator.shared.tabControllerManager;
    [tabControllerManager.tabViewController presentViewController:alert animated:YES completion:nil];
    [self enablePaymentButtons];
}

- (IBAction)sendProgressCancelButtonClicked:(UIButton *)sender
{
    self.sendProgressModalText.text = BC_STRING_CANCELLING;
    self.transferAllPaymentBuilder.userCancelledNext = YES;
    [self performSelector:@selector(cancelAndReloadIfTransferFails) withObject:nil afterDelay:10.0];
}

- (void)cancelAndReloadIfTransferFails
{
    if (self.isSending && [self.sendProgressModalText.text isEqualToString:BC_STRING_CANCELLING]) {
        [self reload];
        [[ModalPresenter sharedInstance] closeAllModals];
    }
}

#pragma mark - UI Helpers

- (void)doCurrencyConversion
{
    [self doCurrencyConversionAfterMultiAddress:NO];
}

- (void)doCurrencyConversionAfterMultiAddress
{
    [self doCurrencyConversionAfterMultiAddress:YES];
}

- (void)doCurrencyConversionAfterMultiAddress:(BOOL)afterMultiAddress
{
    // If the amount entered exceeds amount available, change the color of the amount text
    if (self.amountInSatoshi > self.availableAmount || self.amountInSatoshi > BTC_LIMIT_IN_SATOSHI) {
        [self highlightInvalidAmounts];
        [self disablePaymentButtons];
    }
    else {
        [self removeHighlightFromAmounts];
        [self enablePaymentButtons];
        if (!afterMultiAddress) {
            [WalletManager.sharedInstance.wallet changePaymentAmount:[NSNumber numberWithLongLong:self.amountInSatoshi] assetType:self.assetType];
            [self updateSatoshiPerByteWithUpdateType:FeeUpdateTypeNoAction];
        }
    }
    
    if ([self.btcAmountField isFirstResponder]) {
        self.fiatAmountField.text = [self formatAmount:self.amountInSatoshi localCurrency:YES];
    }
    else if ([self.fiatAmountField isFirstResponder]) {
        self.btcAmountField.text = [self formatAmount:self.amountInSatoshi localCurrency:NO];
    }
    else {
        self.fiatAmountField.text = [self formatAmount:self.amountInSatoshi localCurrency:YES];
        self.btcAmountField.text = [self formatAmount:self.amountInSatoshi localCurrency:NO];
    }
    
    [self updateFundsAvailable];
}

- (void)highlightInvalidAmounts
{
    self.btcAmountField.textColor = UIColor.error;
    self.fiatAmountField.textColor = UIColor.error;
}

- (void)removeHighlightFromAmounts
{
    self.btcAmountField.textColor = UIColor.gray5;
    self.fiatAmountField.textColor = UIColor.gray5;
}

- (void)handleTimerTick:(NSTimer *)timer
{
    if (self.bitpayExpiration == nil) {
        [timer invalidate];
        [self cleanUpBitPayPayment];
        return;
    }
    NSTimeInterval interval = [self.bitpayExpiration timeIntervalSinceNow];
    int secondsInAnHour = 3600;
    int hours = interval / secondsInAnHour;
    int minutesInAnHour = 60;
    int minutes = (interval - hours * secondsInAnHour) / minutesInAnHour;
    int secondsInAMinute = 60;
    int seconds = interval - hours * secondsInAnHour - minutes * secondsInAMinute;
    
    NSString *hoursString = [NSString stringWithFormat:@"%02d", hours];
    NSString *minutesString = minutes > 9 ? [NSString stringWithFormat:@"%02d", minutes] : [NSString stringWithFormat:@"%d", minutes];
    NSString *secondsString = [NSString stringWithFormat:@"%02d", seconds];
    NSString *secondsFormattedString = seconds < 10 ? [[NSNumberFormatter localFormattedString:@"0"] stringByAppendingString:[NSNumberFormatter localFormattedString:secondsString]] : [NSNumberFormatter localFormattedString:secondsString];
    NSString *timeString = hours > 0 ? [NSString stringWithFormat:@"%@:%@:%@", [NSNumberFormatter localFormattedString:hoursString], [NSNumberFormatter localFormattedString:minutesString], secondsFormattedString] : [NSString stringWithFormat:@"%@:%@", [NSNumberFormatter localFormattedString:minutesString], secondsFormattedString];
    
    self.bitpayTimeRemainingText.text = [NSString stringWithFormat:BC_STRING_BITPAY_TIME_REMAINING, timeString];
    if (hours == 0 && minutes < 1) {
        self.bitpayTimeRemainingText.textColor = UIColor.error;
    } else if (hours == 0 && minutes < 5) {
        self.bitpayTimeRemainingText.textColor = UIColor.orangeColor;
    }
    
    if (hours + minutes <= 0 && seconds <= 2) {
        [self.analyticsRecorder recordWithEvent:[[BitpayPaymentExpired alloc] init]];
        [timer invalidate];
        [self showBitPayExpiredAlert];
    }
}

- (void)showBitPayExpiredAlert
{
    UIAlertController *expiredAlert = [UIAlertController alertControllerWithTitle:BC_STRING_BITPAY_INVOICE_EXPIRED_TITLE message:BC_STRING_BITPAY_INVOICE_EXPIRED_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
    [expiredAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        [self reload];
    }]];
    [self presentViewController:expiredAlert animated:YES completion:nil];
    [self cleanUpBitPayPayment];
}

- (void)cleanUpBitPayPayment
{
    [self clearToAddressAndAmountFields];
    [self enableInputs];
    [self.bitpayTimer invalidate];
    self.isBitpayPayPro = NO;
    [self updateFundsAvailable];
    self.feeType = FeeTypeRegular;
    [self updateFeeLabels];
    self.bitpayLabel.hidden = YES;
    self.bitpayLogo.hidden = YES;
    self.bitpayTimeRemainingText.hidden = YES;
    self.lineBelowBitpayLabel.hidden = YES;
}

- (void)enableInputs
{
    self.btcAmountField.enabled = YES;
    self.fiatAmountField.enabled = YES;
    self.toField.enabled = YES;
    self.feeField.enabled = YES;
    self.fundsAvailableButton.enabled = YES;
    [self.feeTappableView setUserInteractionEnabled:YES];
    self.fundsAvailableButton.hidden = NO;
    self.addressBookButton.enabled = YES;
    self.feeOptionsButton.enabled = YES;
}

- (void)disableInputs
{
    self.btcAmountField.enabled = NO;
    self.fiatAmountField.enabled = NO;
    self.toField.enabled = NO;
    self.feeField.enabled = NO;
    self.fundsAvailableButton.enabled = NO;
    [self.feeTappableView setUserInteractionEnabled:NO];
    self.fundsAvailableButton.hidden = true;
    self.addressBookButton.enabled = NO;
    self.feeOptionsButton.enabled = NO;
}

- (void)disablePaymentButtons
{
    self.continuePaymentButton.enabled = NO;
    [self.continuePaymentButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.continuePaymentButton setBackgroundColor:UIColor.keyPadButton];
    
    self.continuePaymentAccessoryButton.enabled = NO;
    [self.continuePaymentAccessoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.continuePaymentAccessoryButton setBackgroundColor:UIColor.keyPadButton];
}

- (void)enablePaymentButtons
{
    self.continuePaymentButton.enabled = YES;
    [self.continuePaymentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continuePaymentButton setBackgroundColor:UIColor.brandSecondary];
    
    [self.continuePaymentAccessoryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.continuePaymentAccessoryButton.enabled = YES;
    [self.continuePaymentAccessoryButton setBackgroundColor:UIColor.brandSecondary];
}

- (void)showInsufficientFunds
{
    [self highlightInvalidAmounts];
}

- (void)setAmountStringFromBitPayURL:(NSURL *)bitpayURL
{
    if ([self isBitpayURL:bitpayURL] && self.assetType == LegacyAssetTypeBitcoin)
    {
        NSString *bitpayInvoiceID = [self invoiceIDFromBitPayURL:bitpayURL];
        [self handleBitpayInvoiceID:bitpayInvoiceID event:[BitpayUrlPasted createWithLegacyAssetType:self.assetType]];
    }
}

- (void)setAmountStringFromUrlHandler:(NSString*)amountString withToAddress:(NSString*)addressString
{
    self.addressFromURLHandler = addressString;
    
    if ([NSNumberFormatter stringHasBitcoinValue:amountString]) {
        NSDecimalNumber *amountDecimalNumber = [NSDecimalNumber decimalNumberWithString:amountString];
        self.amountFromURLHandler = [[amountDecimalNumber decimalNumberByMultiplyingBy:(NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI]] longLongValue];
    } else {
        self.amountFromURLHandler = 0;
    }
    
    self.addressSource = DestinationAddressSourceURI;
}

- (void)hideKeyboardForced
{
    // When backgrounding the app quickly, the input accessory view can remain visible without a first responder, so force the keyboard to appear before dismissing it
    [self.fiatAmountField becomeFirstResponder];
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    [self.btcAmountField resignFirstResponder];
    [self.fiatAmountField resignFirstResponder];
    [self.toField resignFirstResponder];
    [self.feeField resignFirstResponder];
    
    [self.view removeGestureRecognizer:self.tapGesture];
    self.tapGesture = nil;
}

- (BOOL)isKeyboardVisible
{
    if ([self.btcAmountField isFirstResponder] || [self.fiatAmountField isFirstResponder] || [self.toField isFirstResponder] || [self.feeField isFirstResponder]) {
        return YES;
    }
    
    return NO;
}

- (void)showErrorBeforeSending:(NSString *)error
{
    if ([self isKeyboardVisible]) {
        [self hideKeyboard];
        dispatch_after(DELAY_KEYBOARD_DISMISSAL, dispatch_get_main_queue(), ^{
            [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:error in:self handler:nil];
        });
    } else {
        [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_ERROR message:error in:self handler:nil];
    }
}

- (void)setupFees
{
    self.feeType = FeeTypeRegular;

    [self arrangeViewsToFeeMode];
    
    [self reloadAfterMultiAddressResponse];
}

- (void)arrangeViewsToFeeMode
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.feeLabel.hidden = NO;
        self.feeOptionsButton.hidden = self.assetType == LegacyAssetTypeBitcoinCash;
        self.lineBelowFeeField.hidden = NO;

        self.feeAmountLabel.hidden = NO;
        self.feeDescriptionLabel.hidden = NO;
        self.feeTypeLabel.hidden = NO;
    }];

    [self updateFeeLabels];
}

- (void)updateSendBalance:(NSNumber *)balance fees:(NSDictionary *)fees
{
    self.fees = fees;
    
    uint64_t newBalance = [balance longLongValue] <= 0 ? 0 : [balance longLongValue];
    
    self.availableAmount = newBalance;
    
    if (self.feeType != FeeTypeRegular) {
        [self updateSatoshiPerByteWithUpdateType:FeeUpdateTypeNoAction];
    }
    
    if (!self.transferAllPaymentBuilder || self.transferAllPaymentBuilder.userCancelledNext) {
        [self doCurrencyConversionAfterMultiAddress];
    }
}

- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed
{
    if ([addressesUsed count] == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showErrorBeforeSending:BC_STRING_NO_ADDRESSES_WITH_SPENDABLE_BALANCE_ABOVE_OR_EQUAL_TO_DUST];
            [LoadingViewPresenter.shared hide];
        });
        return;
    }
    
    if ([amount longLongValue] + [fee longLongValue] > [WalletManager.sharedInstance.wallet getTotalBalanceForSpendableActiveLegacyAddresses]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AlertViewPresenter.shared standardNotifyWithTitle:BC_STRING_WARNING_TITLE message:BC_STRING_SOME_FUNDS_CANNOT_BE_TRANSFERRED_AUTOMATICALLY in:self handler:nil];
            [LoadingViewPresenter.shared hide];
        });
    }
    
    self.fromAddress = @"";
    self.sendFromAddress = YES;
    self.sendToAddress = NO;
    self.toAccount = [WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType];
    self.toField.text = [WalletManager.sharedInstance.wallet getLabelForAccount:[WalletManager.sharedInstance.wallet getDefaultAccountIndexForAssetType:self.assetType] assetType:self.assetType];
    
    self.feeFromTransactionProposal = [fee longLongValue];
    self.amountInSatoshi = [amount longLongValue];
        
    self.selectAddressTextField.text = [addressesUsed count] == 1 ? [NSString stringWithFormat:BC_STRING_ARGUMENT_ADDRESS, [addressesUsed count]] : [NSString stringWithFormat:BC_STRING_ARGUMENT_ADDRESSES, [addressesUsed count]];
    
    [self disablePaymentButtons];
    
    [self.transferAllPaymentBuilder setupFirstTransferWithAddressesUsed:addressesUsed];
}

- (void)showSummaryForTransferAll
{
    [LoadingViewPresenter.shared hide];
    
    [self showSummaryForTransferAllWithCustomFromLabel:self.selectAddressTextField.text];
    
    [self enablePaymentButtons];
    
    self.sendProgressCancelButton.hidden = [self.transferAllPaymentBuilder.transferAllAddressesToTransfer count] <= 1;
}

- (BOOL)transferAllMode
{
    return self.transferAllPaymentBuilder && !self.transferAllPaymentBuilder.userCancelledNext;
}

- (void)updateFeeLabels
{
    if (self.feeType == FeeTypeCustom) {
        self.feeField.hidden = NO;
        [self.feeTappableView changeXPosition:self.feeAmountLabel.frame.origin.x];
        
        self.feeAmountLabel.hidden = NO;
        self.feeAmountLabel.textColor = UIColor.gray2;

        self.feeDescriptionLabel.hidden = YES;
        
        self.feeTypeLabel.hidden = YES;
    } else {
        self.feeField.hidden = YES;
        [self.feeTappableView changeXPosition:0];

        self.feeWarningLabel.hidden = YES;
        [self.lineBelowFeeField changeYPositionAnimated:[self defaultYPositionForWarningLabel] completion:nil];

        self.feeAmountLabel.hidden = NO;
        self.feeAmountLabel.textColor = UIColor.gray5;
        self.feeAmountLabel.text = nil;
        
        self.feeDescriptionLabel.hidden = NO;
        
        self.feeTypeLabel.hidden = NO;
        
        NSString *typeText;
        NSString *descriptionText;
        
        if (self.feeType == FeeTypeRegular) {
            typeText = BC_STRING_REGULAR;
            descriptionText = BC_STRING_GREATER_THAN_ONE_HOUR;
        } else if (self.feeType == FeeTypePriority) {
            typeText = BC_STRING_PRIORITY;
            descriptionText = BC_STRING_LESS_THAN_ONE_HOUR;
        }
        
        self.feeTypeLabel.text = typeText;
        self.feeDescriptionLabel.text = descriptionText;
    }
}

- (void)updateFeeAmountLabelText:(uint64_t)fee
{
    self.lastDisplayedFee = fee;
    
    if (self.feeType == FeeTypeCustom) {
        NSNumber *regularFee = [self.fees objectForKey:DICTIONARY_KEY_FEE_REGULAR];
        NSNumber *priorityFee = [self.fees objectForKey:DICTIONARY_KEY_FEE_PRIORITY];
        self.feeAmountLabel.text = [NSString stringWithFormat:@"%@: %@, %@: %@", BC_STRING_REGULAR, regularFee, BC_STRING_PRIORITY, priorityFee];
    } else {
        self.feeAmountLabel.text = [NSString stringWithFormat:@"%@ (%@)", [self formatMoney:fee localCurrency:NO], [self formatMoney:fee localCurrency:YES]];
    }
}

- (void)setupFeeWarningLabelFrameSmall
{
    CGFloat warningLabelOriginY = self.feeAmountLabel.frame.origin.y + self.feeAmountLabel.frame.size.height - 4;
    self.feeWarningLabel.frame = CGRectMake(self.feeField.frame.origin.x, warningLabelOriginY, self.feeOptionsButton.frame.origin.x - self.feeField.frame.origin.x, self.lineBelowFeeField.frame.origin.y - warningLabelOriginY);
}

- (void)setupFeeWarningLabelFrameLarge
{
    CGFloat warningLabelOriginY = self.feeDescriptionLabel.frame.origin.y + self.feeDescriptionLabel.frame.size.height - 4;
    self.feeWarningLabel.frame = CGRectMake(self.feeField.frame.origin.x, warningLabelOriginY, self.feeOptionsButton.frame.origin.x - self.feeField.frame.origin.x, self.lineBelowFeeField.frame.origin.y - warningLabelOriginY);
}

- (CGFloat)defaultYPositionForWarningLabel
{
    return 112;
}

- (void)disableToField
{
    CGFloat alpha = 0.0;

    self.toField.enabled = NO;
    self.toField.alpha = alpha;
    
    self.addressBookButton.enabled = NO;
    self.addressBookButton.alpha = alpha;
}

- (void)enableToField
{
    CGFloat alpha = 1.0;
    
    self.toField.enabled = YES;
    self.toField.alpha = alpha;
    
    self.addressBookButton.enabled = YES;
    self.addressBookButton.alpha = alpha;
}

- (void)disableAmountViews
{
    CGFloat alpha = 0.5;
    
    self.btcAmountField.enabled = NO;
    self.btcAmountField.alpha = alpha;
    
    self.fiatAmountField.enabled = NO;
    self.fiatAmountField.alpha = alpha;
    
    self.fundsAvailableButton.enabled = NO;
    self.fundsAvailableButton.alpha = alpha;
}

- (void)enableAmountViews
{
    CGFloat alpha = 1.0;

    self.btcAmountField.enabled = YES;
    self.btcAmountField.alpha = alpha;
    
    self.fiatAmountField.enabled = YES;
    self.fiatAmountField.alpha = alpha;
    
    self.fundsAvailableButton.enabled = YES;
    self.fundsAvailableButton.alpha = alpha;
}

- (CGFloat)continuePaymentButtonOriginY
{
    CGFloat spacing = 20;
    return self.view.frame.size.height - BUTTON_HEIGHT - spacing;
}

#pragma mark - Asset Agnostic Methods

- (NSString *)formatAmount:(uint64_t)amount localCurrency:(BOOL)useLocalCurrency
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        return [NSNumberFormatter formatAmount:amount localCurrency:useLocalCurrency];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        return [NSNumberFormatter formatBCHAmount:amount includeSymbol:NO inLocalCurrency:useLocalCurrency];
    }
    DLog(@"Warning: Unsupported asset type!");
    return nil;
}

- (NSString *)formatMoney:(uint64_t)amount localCurrency:(BOOL)useLocalCurrency
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        return [NSNumberFormatter formatMoney:amount localCurrency:useLocalCurrency];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        return [NSNumberFormatter formatBCHAmount:amount includeSymbol:NO inLocalCurrency:useLocalCurrency];
    }
    DLog(@"Warning: Unsupported asset type!");
    return nil;
}

- (BOOL)canChangeFromAddress
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        return !([WalletManager.sharedInstance.wallet hasAccount] && ![WalletManager.sharedInstance.wallet hasLegacyAddresses:self.assetType] && [WalletManager.sharedInstance.wallet getActiveAccountsCount:self.assetType] == 1);
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        
    }
    return YES;
}

- (void)changePaymentFromAddress:(NSString *)address
{
    [WalletManager.sharedInstance.wallet changePaymentFromAddress:address isAdvanced:self.feeType == FeeTypeCustom assetType:self.assetType];
}

- (void)changePaymentFromAccount:(int)account
{
    [WalletManager.sharedInstance.wallet changePaymentFromAccount:account isAdvanced:self.feeType == FeeTypeCustom assetType:self.assetType];
}

- (void)getTransactionFeeWithUpdateType:(FeeUpdateType)updateType
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [WalletManager.sharedInstance.wallet getTransactionFeeWithUpdateType:updateType];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        id to = self.sendToAddress ? self.toAddress : [NSNumber numberWithInt:self.toAccount];
        [WalletManager.sharedInstance.wallet buildBitcoinCashPaymentTo:to amount:self.amountInSatoshi];
        [self showSummary];
    }
}

- (void)sweepPaymentRegular
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [WalletManager.sharedInstance.wallet sweepPaymentRegular];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [self didGetMaxFee:[NSNumber numberWithLongLong:self.feeFromTransactionProposal] amount:[NSNumber numberWithLongLong:self.availableAmount] dust:0 willConfirm:NO];
    }
}

- (void)sweepPaymentAdvanced
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [WalletManager.sharedInstance.wallet sweepPaymentAdvanced];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        // No custom fee in bch
    }
}

- (void)changeSatoshiPerByte:(uint64_t)satoshiPerByte updateType:(FeeUpdateType)updateType
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [WalletManager.sharedInstance.wallet changeSatoshiPerByte:satoshiPerByte updateType:updateType];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        // No custom fee in bch
    }
}

- (void)checkIfOverspending
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [WalletManager.sharedInstance.wallet checkIfOverspending];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [self didCheckForOverSpending:[NSNumber numberWithLongLong:self.availableAmount] fee:[NSNumber numberWithLongLong:self.feeFromTransactionProposal]];
    }
}

- (void)sendPaymentWithListener:(TransactionProgressListeners*)listener secondPassword:(NSString *)secondPassword
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [WalletManager.sharedInstance.wallet sendPaymentWithListener:listener secondPassword:secondPassword];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [WalletManager.sharedInstance.wallet sendBitcoinCashPaymentWithListener:listener];
    }
}

#pragma mark - Textfield Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"Tried to access Send textField when not initialized!");
        return NO;
    }
    
    if (textField == self.selectAddressTextField) {
        // If we only have one account and no legacy addresses -> can't change from address
        if ([self canChangeFromAddress]) {
            [self selectFromAddressClicked:textField];
        }
        return NO;  // Hide both keyboard and blinking cursor.
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.tapGesture == nil) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        
        [self.view addGestureRecognizer:self.tapGesture];
    }
    
    if (textField == self.btcAmountField) {
        self.displayingLocalSymbolSend = NO;
    }
    else if (textField == self.fiatAmountField) {
        self.displayingLocalSymbolSend = YES;
    }
    
    [self doCurrencyConversion];
    
    self.transactionType = SendTransactionTypeRegular;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.exchangeAddressButton.hidden = NO;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.btcAmountField || textField == self.fiatAmountField) {
        
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSArray  *points = [newString componentsSeparatedByString:@"."];
        NSLocale *locale = [textField.textInputMode.primaryLanguage isEqualToString:LOCALE_IDENTIFIER_AR] ? [NSLocale localeWithLocaleIdentifier:textField.textInputMode.primaryLanguage] : [NSLocale currentLocale];
        NSArray  *commas = [newString componentsSeparatedByString:[locale objectForKey:NSLocaleDecimalSeparator]];
        
        // Only one comma or point in input field allowed
        if ([points count] > 2 || [commas count] > 2)
            return NO;
        
        // Only 1 leading zero
        if (points.count == 1 || commas.count == 1) {
            if (range.location == 1 && ![string isEqualToString:@"."] && ![string isEqualToString:@","] && ![string isEqualToString:@"٫"] && [textField.text isEqualToString:@"0"]) {
                return NO;
            }
        }
        
        // When entering amount in BTC, max 8 decimal places
        if (textField == self.btcAmountField || textField == self.feeField) {
            NSUInteger maxlength = 8;
            
            if (points.count == 2) {
                NSString *decimalString = points[1];
                if (decimalString.length > maxlength) {
                    return NO;
                }
            }
            else if (commas.count == 2) {
                NSString *decimalString = commas[1];
                if (decimalString.length > maxlength) {
                    return NO;
                }
            }
        }
        
        // Fiat currencies have a max of 3 decimal places, most of them actually only 2. For now we will use 2.
        else if (textField == self.fiatAmountField) {
            if (points.count == 2) {
                NSString *decimalString = points[1];
                if (decimalString.length > 2) {
                    return NO;
                }
            }
            else if (commas.count == 2) {
                NSString *decimalString = commas[1];
                if (decimalString.length > 2) {
                    return NO;
                }
            }
        }
        
        if (textField == self.fiatAmountField) {
            // Convert input amount to internal value
            NSString *amountString = [newString stringByReplacingOccurrencesOfString:@"," withString:@"."];
            if (![amountString containsString:@"."]) {
                amountString = [newString stringByReplacingOccurrencesOfString:@"٫" withString:@"."];
            }
            self.amountInSatoshi = [WalletManager.sharedInstance.wallet conversionForBitcoinAssetType:self.assetType] * [amountString doubleValue];
        }
        else if (textField == self.btcAmountField) {
            self.amountInSatoshi = [NSNumberFormatter parseBitcoinValueFrom:newString];
        }
        
        if (self.amountInSatoshi > BTC_LIMIT_IN_SATOSHI) {
            return NO;
        } else {
            [self performSelector:@selector(doCurrencyConversion) withObject:nil afterDelay:0.1f];
            return YES;
        }
        
    } else if (textField == self.feeField) {
        
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if ([newString containsString:@"."] ||
            [newString containsString:@","] ||
            [newString containsString:@"٫"]) return NO;
        
        if (newString.length == 0) {
            self.feeWarningLabel.hidden = YES;
            [self.lineBelowFeeField changeYPositionAnimated:[self defaultYPositionForWarningLabel] completion:nil];
        }

        [self performSelector:@selector(updateSatoshiPerByteAfterTextChange) withObject:nil afterDelay:0.1f];
        
        return YES;
    } else if (textField == self.toField) {
        NSString *entry = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSURL *bitpayURLCandidate = [NSURL URLWithString:entry];
        if (bitpayURLCandidate != nil) {
            if ([self isBitpayURL:bitpayURLCandidate] && self.assetType == LegacyAssetTypeBitcoin)
            {
                NSString *bitpayInvoiceID = [self invoiceIDFromBitPayURL:bitpayURLCandidate];
                [self handleBitpayInvoiceID:bitpayInvoiceID event:[BitpayUrlPasted createWithLegacyAssetType:self.assetType]];
                return YES;
            }
        }
        self.sendToAddress = true;
        self.toAddress = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (self.toAddress && [WalletManager.sharedInstance.wallet isValidAddress:self.toAddress assetType:self.assetType]) {
            [self selectToAddress:self.toAddress];
            self.addressSource = DestinationAddressSourcePaste;
            return NO;
        } else {
            self.exchangeAddressButton.hidden = self.toAddress.length > 0;
        }
        
        DLog(@"toAddress: %@", self.toAddress);
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)updateFundsAvailable
{
    if (self.fiatAmountField.textColor == UIColor.error && self.btcAmountField.textColor == UIColor.error && [self.fiatAmountField.text isEqualToString:[NSNumberFormatter formatAmount:self.availableAmount localCurrency:YES]]) {
        [self.fundsAvailableButton setTitle:[NSString stringWithFormat:BC_STRING_USE_TOTAL_AVAILABLE_MINUS_FEE_ARGUMENT, [self formatMoney:self.availableAmount localCurrency:NO]] forState:UIControlStateNormal];
    } else {
        [self.fundsAvailableButton setTitle:[NSString stringWithFormat:BC_STRING_USE_TOTAL_AVAILABLE_MINUS_FEE_ARGUMENT,
                                        [self formatMoney:self.availableAmount localCurrency:self.displayingLocalSymbolSend]]
                                forState:UIControlStateNormal];
        [self.fundsAvailableButton setTitleColor:UIColor.brandSecondary forState:UIControlStateNormal];
    }
    
}

- (void)selectFromAddress:(NSString *)address
{
    self.sendFromAddress = true;
    
    NSString *addressOrLabel;
    NSString *label = [WalletManager.sharedInstance.wallet labelForLegacyAddress:address assetType:self.assetType];
    if (label && ![label isEqualToString:@""]) {
        addressOrLabel = label;
    }
    else {
        addressOrLabel = address;
    }
    
    self.selectAddressTextField.text = addressOrLabel;
    self.fromAddress = address;
    DLog(@"fromAddress: %@", address);
    
    [self changePaymentFromAddress:address];
    
    [self doCurrencyConversion];
}

- (void)selectToAddress:(NSString *)address
{
    DLog(@"toAddress: %@", self.toAddress);

    self.sendToAddress = true;
    self.toAddress = address;
    self.toField.text = [WalletManager.sharedInstance.wallet labelForLegacyAddress:address assetType:self.assetType];
    
    self.exchangeAddressButton.hidden = self.addressSource != DestinationAddressSourceExchange;
    
    [WalletManager.sharedInstance.wallet changePaymentToAddress:address assetType:self.assetType];
    
    [self doCurrencyConversion];
}

- (void)selectFromAccount:(int)account
{
    self.sendFromAddress = false;
    
    self.availableAmount = [[WalletManager.sharedInstance.wallet getBalanceForAccount:account assetType:self.assetType] longLongValue];
    
    self.selectAddressTextField.text = [WalletManager.sharedInstance.wallet getLabelForAccount:account assetType:self.assetType];
    self.fromAccount = account;
    DLog(@"fromAccount: %@", [WalletManager.sharedInstance.wallet getLabelForAccount:account assetType:self.assetType]);
    
    [self changePaymentFromAccount:account];
    
    [self updateFundsAvailable];
    
    [self doCurrencyConversion];
}

- (void)selectToAccount:(int)account
{
    self.sendToAddress = false;

    self.toField.text = [WalletManager.sharedInstance.wallet getLabelForAccount:account assetType:self.assetType];
    self.toAccount = account;
    self.exchangeAddressButton.hidden = YES;
    
    self.toAddress = @"";
    DLog(@"toAccount: %@", [WalletManager.sharedInstance.wallet getLabelForAccount:account assetType:self.assetType]);
    
    [WalletManager.sharedInstance.wallet changePaymentToAccount:account assetType:self.assetType];
    
    [self doCurrencyConversion];
}

# pragma mark - AddressBook delegate

- (LegacyAssetType)getAssetType
{
    return self.assetType;
}

- (void)didSelectFromAddress:(NSString *)address
{
    [self selectFromAddress:address];
}

- (void)didSelectFromAccount:(int)account assetType:(LegacyAssetType)asset
{
    [self selectFromAccount:account];
}

- (void)didSelectToAddress:(NSString *)address
{
    [self selectToAddress:address];
    [self setDropdownAddressSource];
}

- (void)didSelectToAccount:(int)account assetType:(LegacyAssetType)asset
{
    [self selectToAccount:account];
    [self setDropdownAddressSource];
}

- (void)setDropdownAddressSource {
    self.addressSource = DestinationAddressSourceDropDown;
    [self.exchangeAddressButton setImage:[UIImage imageNamed:@"exchange-icon-small"] forState:UIControlStateNormal];
    self.toField.hidden = false;
    self.destinationAddressIndicatorLabel.hidden = true;
}

#pragma mark - Transaction Description Delegate

- (void)confirmButtonDidTap:(NSString *_Nullable)note
{
    self.noteToSet = note;
}

#pragma mark - Fee Calculation

- (void)getTransactionFeeWithSuccess:(void (^)(void))success error:(void (^)(void))error
{
    self.getTransactionFeeSuccess = success;
    
    [self getTransactionFeeWithUpdateType:FeeUpdateTypeConfirm];
}

- (void)didCheckForOverSpending:(NSNumber *)amount fee:(NSNumber *)fee
{
    if ([amount longLongValue] <= 0) {
        [self handleZeroSpendableAmount];
        return;
    }
    
    self.feeFromTransactionProposal = [fee longLongValue];
    
    __weak SendBitcoinViewController *weakSelf = self;
    
    [self getTransactionFeeWithSuccess:^{
        [weakSelf showSummary];
    } error:nil];
}

- (void)didGetMaxFee:(NSNumber *)fee amount:(NSNumber *)amount dust:(NSNumber *)dust willConfirm:(BOOL)willConfirm
{
    if ([amount longLongValue] <= 0) {
        [self handleZeroSpendableAmount];
        return;
    }
    
    self.feeFromTransactionProposal = [fee longLongValue];
    uint64_t maxAmount = [amount longLongValue];
    self.dust = dust == nil ? 0 : [dust longLongValue];
    
    DLog(@"SendViewController: got max fee of %lld", [fee longLongValue]);
    self.amountInSatoshi = maxAmount;
    [self doCurrencyConversion];
    
    if (willConfirm) {
        [self showSummary];
    }
}

- (void)didUpdateTotalAvailable:(NSNumber *)sweepAmount finalFee:(NSNumber *)finalFee
{
    self.availableAmount = [sweepAmount longLongValue];
    uint64_t fee = [finalFee longLongValue];
    
    if (self.assetType == LegacyAssetTypeBitcoinCash) self.feeFromTransactionProposal = fee;
    
    CGFloat warningLabelYPosition = [self defaultYPositionForWarningLabel];
    
    if (self.availableAmount <= 0) {
        [self.lineBelowFeeField changeYPositionAnimated:warningLabelYPosition + 30 completion:^(BOOL finished) {
            if (self.feeType == FeeTypeCustom) {
                [self setupFeeWarningLabelFrameSmall];
            } else {
                [self setupFeeWarningLabelFrameLarge];
            }
            self.feeWarningLabel.hidden = self.lineBelowFeeField.frame.origin.y == warningLabelYPosition;
        }];
        self.feeWarningLabel.text = BC_STRING_NOT_ENOUGH_FUNDS_TO_USE_FEE;
    } else {
        if ([self.feeWarningLabel.text isEqualToString:BC_STRING_NOT_ENOUGH_FUNDS_TO_USE_FEE]) {
            [self.lineBelowFeeField changeYPositionAnimated:warningLabelYPosition completion:nil];
            self.feeWarningLabel.hidden = YES;
        }
    }
    
    [self updateFeeAmountLabelText:fee];
    [self doCurrencyConversionAfterMultiAddress];
}

- (void)didGetFee:(NSNumber *)fee dust:(NSNumber *)dust txSize:(NSNumber *)txSize
{
    self.feeFromTransactionProposal = [fee longLongValue];
    self.recommendedForcedFee = [fee longLongValue];
    self.dust = dust == nil ? 0 : [dust longLongValue];
    self.txSize = [txSize longLongValue];
    
    if (self.getTransactionFeeSuccess) {
        self.getTransactionFeeSuccess();
    }
}

- (void)didChangeSatoshiPerByte:(NSNumber *)sweepAmount fee:(NSNumber *)fee dust:(NSNumber *)dust updateType:(FeeUpdateType)updateType
{
    self.availableAmount = [sweepAmount longLongValue];
    
    if (updateType != FeeUpdateTypeConfirm) {
        if (self.amountInSatoshi > self.availableAmount) {
            self.feeField.textColor = UIColor.error;
            [self disablePaymentButtons];
        } else {
            [self removeHighlightFromAmounts];
            self.feeField.textColor = UIColor.gray5;
            [self enablePaymentButtons];
        }
    }
    
    [self updateFundsAvailable];
    
    uint64_t feeValue = [fee longLongValue];

    self.feeFromTransactionProposal = feeValue;
    self.dust = dust == nil ? 0 : [dust longLongValue];
    [self updateFeeAmountLabelText:feeValue];
    
    if (updateType == FeeUpdateTypeConfirm) {
        [self showSummary];
    } else if (updateType == FeeUpdateTypeSweep) {
        [self sweepPaymentAdvanced];
    }
}

- (void)checkMaxFee
{
    [self checkIfOverspending];
}

- (void)updateSatoshiPerByteAfterTextChange
{
    [self updateSatoshiPerByteWithUpdateType:FeeUpdateTypeNoAction];
}

- (void)updateSatoshiPerByteWithUpdateType:(FeeUpdateType)feeUpdateType
{
    if (self.feeType == FeeTypeCustom) {
        uint64_t typedSatoshiPerByte = [self.feeField.text longLongValue];
        
        NSDictionary *limits = [self.fees objectForKey:DICTIONARY_KEY_FEE_LIMITS];
        
        if (typedSatoshiPerByte < [[limits objectForKey:DICTIONARY_KEY_FEE_LIMITS_MIN] longLongValue]) {
            DLog(@"Fee rate lower than recommended");
            
            CGFloat warningLabelYPosition = [self defaultYPositionForWarningLabel];
            
            if (self.feeField.text.length > 0) {
                if (IS_USING_SCREEN_SIZE_LARGER_THAN_5S) {
                    [self.lineBelowFeeField changeYPositionAnimated:warningLabelYPosition + 12 completion:^(BOOL finished) {
                        [self setupFeeWarningLabelFrameSmall];
                        self.feeWarningLabel.hidden = self.lineBelowFeeField.frame.origin.y == warningLabelYPosition;
                    }];
                } else {
                    [self.lineBelowFeeField changeYPositionAnimated:[self defaultYPositionForWarningLabel] completion:^(BOOL finished) {
                        [self setupFeeWarningLabelFrameSmall];
                        self.feeWarningLabel.hidden = NO;
                    }];
                }
                self.feeWarningLabel.text = BC_STRING_LOW_FEE_NOT_RECOMMENDED;
            }
        } else if (typedSatoshiPerByte > [[limits objectForKey:DICTIONARY_KEY_FEE_LIMITS_MAX] longLongValue] && !self.isBitpayPayPro) {
            DLog(@"Fee rate higher than recommended");
            
            CGFloat warningLabelYPosition = [self defaultYPositionForWarningLabel];

            if (self.feeField.text.length > 0) {
                if (IS_USING_SCREEN_SIZE_LARGER_THAN_5S) {
                    [self.lineBelowFeeField changeYPositionAnimated:warningLabelYPosition + 12 completion:^(BOOL finished) {
                        [self setupFeeWarningLabelFrameSmall];
                        self.feeWarningLabel.hidden = self.lineBelowFeeField.frame.origin.y == warningLabelYPosition;
                    }];
                } else {
                    [self.lineBelowFeeField changeYPositionAnimated:[self defaultYPositionForWarningLabel] completion:^(BOOL finished) {
                        [self setupFeeWarningLabelFrameSmall];
                        self.feeWarningLabel.hidden = NO;
                    }];
                }
                self.feeWarningLabel.text = BC_STRING_HIGH_FEE_NOT_NECESSARY;
            }
        } else {
            [self.lineBelowFeeField changeYPositionAnimated:[self defaultYPositionForWarningLabel] completion:nil];
            self.feeWarningLabel.hidden = YES;
        }
        
        [WalletManager.sharedInstance.wallet changeSatoshiPerByte:typedSatoshiPerByte updateType:feeUpdateType];
        
    } else if (self.feeType == FeeTypeRegular) {
        uint64_t regularRate = [[self.fees objectForKey:DICTIONARY_KEY_FEE_REGULAR] longLongValue];
        [self changeSatoshiPerByte:regularRate updateType:feeUpdateType];
    } else if (self.feeType == FeeTypePriority) {
        uint64_t priorityRate = [[self.fees objectForKey:DICTIONARY_KEY_FEE_PRIORITY] longLongValue];
        [WalletManager.sharedInstance.wallet changeSatoshiPerByte:priorityRate updateType:feeUpdateType];
    }
}

- (void)selectFeeType:(FeeType)feeType
{
    self.feeType = feeType;
    
    [self updateFeeLabels];
    
    [self updateSatoshiPerByteWithUpdateType:FeeUpdateTypeNoAction];

    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFromLeft];
}

#pragma mark - Fee Selection Delegate

- (void)didSelectFeeType:(FeeType)feeType
{
    if (feeType == FeeTypeCustom) {
        BOOL hasSeenWarning = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_HAS_SEEN_CUSTOM_FEE_WARNING];
        if (!hasSeenWarning) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:BC_STRING_WARNING_TITLE message:BC_STRING_CUSTOM_FEE_WARNING preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CONTINUE style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self selectFeeType:feeType];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_KEY_HAS_SEEN_CUSTOM_FEE_WARNING];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self selectFeeType:feeType];
        }
    } else {
        [self selectFeeType:feeType];
    }
}

- (FeeType)selectedFeeType
{
    return self.feeType;
}

#pragma mark - Actions

- (void)setupTransferAll
{
    self.transferAllPaymentBuilder = [[TransferAllFundsBuilder alloc] initWithAssetType:self.assetType usingSendScreen:YES];
    self.transferAllPaymentBuilder.delegate = self;
}

- (void)archiveTransferredAddresses
{
    [LoadingViewPresenter.shared showWith:[NSString stringWithFormat:BC_STRING_ARCHIVING_ADDRESSES]];
                                      
    [WalletManager.sharedInstance.wallet archiveTransferredAddresses:self.transferAllPaymentBuilder.transferAllAddressesTransferred];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedArchivingTransferredAddresses) name:[ConstantsObjcBridge notificationKeyBackupSuccess] object:nil];
}

- (void)finishedArchivingTransferredAddresses
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConstantsObjcBridge notificationKeyBackupSuccess] object:nil];
    [[ModalPresenter sharedInstance] closeAllModals];
}

- (IBAction)selectFromAddressClicked:(id)sender
{
    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"Tried to access select from screen when not initialized!");
        return;
    }
    
    BCAddressSelectionView *addressSelectionView = [[BCAddressSelectionView alloc] initWithWallet:WalletManager.sharedInstance.wallet selectMode:SelectModeSendFrom delegate:self];
    [[ModalPresenter sharedInstance] showModalWithContent:addressSelectionView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_SEND_FROM onDismiss:nil onResume:nil];
}

- (IBAction)addressBookClicked:(id)sender
{
    if (![WalletManager.sharedInstance.wallet isInitialized]) {
        DLog(@"Tried to access select to screen when not initialized!");
        return;
    }
    
    // TODO: IOS-2269: Display address dropdown

    BCAddressSelectionView *addressSelectionView = [[BCAddressSelectionView alloc] initWithWallet:WalletManager.sharedInstance.wallet selectMode:SelectModeSendTo delegate:self];
    [[ModalPresenter sharedInstance] showModalWithContent:addressSelectionView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_SEND_TO onDismiss:nil onResume:nil];
}

- (BOOL)isBitpayURL:(NSURL *)URL
{
    return [URL.absoluteString containsString:@"https://bitpay.com/"];
}

- (NSString * _Nullable)invoiceIDFromBitPayURL:(NSURL *)URL
{
    NSString *BTCPrefix = @"bitcoin:?r=";
    NSString *BCHPrefix = @"bitcoincash:?r=";
    NSString *bitpayPayload = URL.absoluteString;
    if ([bitpayPayload containsString:BTCPrefix]) {
        bitpayPayload = [bitpayPayload stringByReplacingOccurrencesOfString:BTCPrefix withString:@""];
    }
    if ([bitpayPayload containsString:BCHPrefix]) {
        bitpayPayload = [bitpayPayload stringByReplacingOccurrencesOfString:BCHPrefix withString:@""];
    }
    NSURL *modifiedURL = [NSURL URLWithString:bitpayPayload];
    if (modifiedURL == nil) {
        return nil;
    } else {
        NSString *invoiceID = [modifiedURL lastPathComponent];
        return invoiceID;
    }
}

- (void)handleBitpayInvoiceID:(NSString *)invoiceID event:(id<ObjcAnalyticsEvent> _Nonnull) event
{
    [LoadingViewPresenter.shared showCircularIn:self.view with:nil];
    [self.analyticsRecorder recordWithEvent:event];
    [self.bitpayService bitpayPaymentRequestWithInvoiceID:invoiceID assetType:self.assetType completion:^(ObjcCompatibleBitpayObject * _Nullable paymentReq, NSString * _Nullable error) {
        [LoadingViewPresenter.shared hide];
        if (error != nil) {
            DLog(@"Error when creating bitpay request: %@", error);
            [AlertViewPresenter.shared standardErrorWithTitle:BC_STRING_ERROR
                                                              message:error
                                                                   in:self
                                                              handler:nil];
            return;
        }
        self.isBitpayPayPro = YES;
        [self disableInputs];

        // set required fee type to priority
        self.feeType = FeeTypePriority;
        [self updateFeeLabels];
        
        //Set self.toField to bitcoinLink url
        NSString *bitcoinLink = [NSString stringWithFormat: @"bitcoin:?r=%@", paymentReq.paymentUrl];
        self.toField.text = bitcoinLink;
        
        //Get decimal BTC amount from satoshi amount and set self.btcAmountField
        self.amountInSatoshi = paymentReq.amount;
        double amountInBtc = (double) paymentReq.amount / 100000000;
        NSString *amountDecimalNumber = [NSString stringWithFormat:@"%f", amountInBtc];
        
        self.btcAmountField.text = amountDecimalNumber;
        
        //Set toAddress to required BitPay paymentRequest address and update wallet internal payment address
        self.toAddress = paymentReq.address;
        self.sendToAddress = true;
        [WalletManager.sharedInstance.wallet changePaymentToAddress:paymentReq.address assetType:self.assetType];
        self.addressSource = DestinationAddressSourceBitPay;
        
        //Set merchant name
        NSString *merchant = [paymentReq.memo componentsSeparatedByString:@"for merchant "][1];
        self.bitpayMerchant = merchant;
        self.bitpayLabel.text = merchant;
        self.bitpayLabel.hidden = NO;
        self.bitpayLogo.hidden = NO;
        self.bitpayTimeRemainingText.hidden = NO;
        self.lineBelowBitpayLabel.hidden = NO;
        
        
        //Set time remaining string
        self.bitpayExpiration = paymentReq.expires;
        
        self.bitpayTimeRemainingText.textColor = UIColor.gray3;
        
        self.bitpayTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(handleTimerTick:) userInfo: nil repeats: YES];
        
        [self performSelector:@selector(doCurrencyConversion) withObject:nil afterDelay:0.1f];
    }];
}

- (void)didReadQRCodeMetadata:(AVMetadataMachineReadableCodeObject *)metadata {

    CryptoAssetQRMetadataBridge* qrMetadata = [[CryptoAssetQRMetadataBridge alloc] initWithMetadata:metadata assetType:self.assetType];

    NSString *paymentRequestUrl = qrMetadata.paymentRequestUrl;
    // If paymentRequestUrl is not nil, this may be a BitPay invoice.
    // We are only going to catch this if it has the BitPay invoice url prefix
    // and we are on the `Bitcoin` screen.
    if (paymentRequestUrl != nil) {
        if ([paymentRequestUrl hasPrefix:@"https://bitpay.com/i/"] && self.assetType == LegacyAssetTypeBitcoin) {
            NSString *invoiceId = [paymentRequestUrl stringByReplacingOccurrencesOfString:@"https://bitpay.com/i/" withString:@""];
            [self handleBitpayInvoiceID:invoiceId event:[BitpayUrlScanned createWithLegacyAssetType:LegacyAssetTypeBitcoin]];
            return;
        } else {
            // There is a `paymentRequestUrl` but we don't support it.
            return;
        }
    }

    NSString *address = qrMetadata.address;
    // If paymentRequestUrl is nil, this is a regular crypto address.
    if (address == nil || ![qrMetadata isAsset:self.assetType] || ![WalletManager.sharedInstance.wallet isValidAddress:address assetType:self.assetType]) {
        NSString *assetName = qrMetadata.assetName;
        NSString *errorMessage = [NSString stringWithFormat:LocalizationConstantsObjcBridge.invalidXAddressY, assetName, address];
        [AlertViewPresenter.shared standardErrorWithTitle:LocalizationConstantsObjcBridge.error
                                                          message:errorMessage
                                                               in:self
                                                          handler:nil];
        return;
    }

    [self selectToAddress:address];

    self.addressSource = DestinationAddressSourceQR;

    NSString *amount = qrMetadata.amount;

    if ([NSNumberFormatter stringHasBitcoinValue:amount]) {
        NSDecimalNumber *amountDecimalNumber = [NSDecimalNumber decimalNumberWithString:amount];
        NSDecimalNumber *satoshi = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:SATOSHI];
        self.amountInSatoshi = [amountDecimalNumber decimalNumberByMultiplyingBy:satoshi].longLongValue;
    } else {
        [self performSelector:@selector(doCurrencyConversion) withObject:nil afterDelay:0.1f];
        return;
    }

    // If self.amountInSatoshi is empty, open the amount field
    if (self.amountInSatoshi == 0) {
        self.btcAmountField.text = nil;
        self.fiatAmountField.text = nil;
        [self.fiatAmountField becomeFirstResponder];
    }

    [self performSelector:@selector(doCurrencyConversion) withObject:nil afterDelay:0.1f];
}

- (IBAction)closeKeyboardClicked:(id)sender
{
    [self.btcAmountField resignFirstResponder];
    [self.fiatAmountField resignFirstResponder];
    [self.toField resignFirstResponder];
    [self.feeField resignFirstResponder];
}

- (IBAction)feeOptionsClicked:(UIButton *)sender
{
    BCFeeSelectionView *feeSelectionView = [[BCFeeSelectionView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    feeSelectionView.delegate = self;
    [[ModalPresenter sharedInstance] showModalWithContent:feeSelectionView closeType:ModalCloseTypeBack showHeader:true headerText:BC_STRING_FEE onDismiss:nil onResume:nil];
}

- (IBAction)labelAddressClicked:(id)sender
{
    [WalletManager.sharedInstance.wallet addToAddressBook:self.toField.text label:self.labelAddressTextField.text];
    
    [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
    self.labelAddressTextField.text = @"";
    
    // Complete payment
    [self showSummary];
}

- (IBAction)useAllClicked:(id)sender
{
    [self reportFormUseBalanceClick];
    
    [self.btcAmountField resignFirstResponder];
    [self.fiatAmountField resignFirstResponder];
    
    [self sweepPaymentRegular];
    
    self.transactionType = SendTransactionTypeSweep;
}

- (void)feeInformationButtonClicked
{
    NSString *title = BC_STRING_FEE_INFORMATION_TITLE;
    NSString *message = BC_STRING_FEE_INFORMATION_MESSAGE;
    
    if (self.feeType != FeeTypeCustom) {
        message = [message stringByAppendingString:BC_STRING_FEE_INFORMATION_MESSAGE_APPEND_REGULAR_SEND];
    }
    
    if (self.surgeIsOccurring || [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_SURGE]) {
        message = [message stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", BC_STRING_SURGE_OCCURRING_MESSAGE]];
    }

    if (self.dust > 0) {
        message = [message stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", BC_STRING_FEE_INFORMATION_DUST]];
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleCancel handler:nil]];
    [[NSNotificationCenter defaultCenter] addObserver:alert selector:@selector(autoDismiss) name:ConstantsObjcBridge.notificationKeyReloadToDismissViews object:nil];
    TabControllerManager *tabControllerManager = AppCoordinator.shared.tabControllerManager;
    [tabControllerManager.tabViewController presentViewController:alert animated:YES completion:nil];
}

- (IBAction)sendPaymentClicked:(id)sender
{
    [self reportSendFormConfirmClick];
    
    if ([self.toAddress length] == 0) {
        self.toAddress = self.toField.text;
        DLog(@"toAddress: %@", self.toAddress);
    }
    
    if ([self.toAddress length] == 0) {
        [self showErrorBeforeSending:BC_STRING_YOU_MUST_ENTER_DESTINATION_ADDRESS];
        return;
    }
    
    if (self.sendToAddress && ![WalletManager.sharedInstance.wallet isValidAddress:self.toAddress assetType:self.assetType]) {
        [self showErrorBeforeSending:BC_STRING_INVALID_TO_BITCOIN_ADDRESS];
        return;
    }
    
    if (!self.sendFromAddress && !self.sendToAddress && self.fromAccount == self.toAccount) {
        [self showErrorBeforeSending:BC_STRING_FROM_TO_DIFFERENT];
        return;
    }
    
    if (self.sendFromAddress && self.sendToAddress && [self.fromAddress isEqualToString:self.toAddress]) {
        [self showErrorBeforeSending:BC_STRING_FROM_TO_ADDRESS_DIFFERENT];
        return;
    }
    
    uint64_t value = self.amountInSatoshi;
    // Convert input amount to internal value
    NSString *language = self.btcAmountField.textInputMode.primaryLanguage;
    NSLocale *locale = language ? [NSLocale localeWithLocaleIdentifier:language] : [NSLocale currentLocale];
    NSString *amountString = [self.btcAmountField.text stringByReplacingOccurrencesOfString:[locale objectForKey:NSLocaleDecimalSeparator] withString:@"."];
    
    NSString *europeanComma = @",";
    NSString *arabicComma= @"٫";
    
    if ([amountString containsString:europeanComma]) {
        amountString = [self.btcAmountField.text stringByReplacingOccurrencesOfString:europeanComma withString:@"."];
    } else if ([amountString containsString:arabicComma]) {
        amountString = [self.btcAmountField.text stringByReplacingOccurrencesOfString:arabicComma withString:@"."];
    }
    if (value <= 0 || [amountString doubleValue] <= 0) {
        [self showErrorBeforeSending:BC_STRING_INVALID_SEND_VALUE];
        return;
    }
    
    [self hideKeyboard];
    
    [self disablePaymentButtons];
    
    self.transactionType = SendTransactionTypeRegular;
    
    if (self.feeType == FeeTypeCustom) {
        [self updateSatoshiPerByteWithUpdateType:FeeUpdateTypeConfirm];
    } else {
        [self checkMaxFee];
    }
    
    [WalletManager.sharedInstance.wallet getSurgeStatus];
}

@end

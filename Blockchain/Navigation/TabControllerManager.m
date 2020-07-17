//
//  TabControllerManager.m
//  Blockchain
//
//  Created by kevinwu on 8/21/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <PlatformUIKit/PlatformUIKit.h>
#import "TabControllerManager.h"
#import "Transaction.h"
#import "Blockchain-Swift.h"

@interface TabControllerManager () <WalletSettingsDelegate, WalletSendBitcoinDelegate, WalletSendEtherDelegate, WalletExchangeIntermediateDelegate, WalletTransactionDelegate>

#pragma mark - Private Properties

@property (strong, nonatomic) SendLumensViewController *sendLumensViewController;

@property (strong, nonatomic) ExchangeContainerViewController *exchangeContainerViewController;


@property (strong, nonatomic) SendPaxViewController *sendPaxViewController;
@property (strong, nonatomic) UINavigationController *activityNavigationController;

@property (strong, nonatomic) UINavigationController *dashboardNavigationController;

// TODO: Reuse the same screen for all transfer flows
@property (strong, nonatomic) SendViewController *transferEtherViewController;
@property (strong, nonatomic) SendRouter *sendRouter;

@end

@implementation TabControllerManager

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabViewController.assetDelegate = self;

    LegacyAssetType assetType = BlockchainSettings.sharedAppInstance.selectedLegacyAssetType;

    if (![AssetSelectorView.availableAssets containsObject:@(assetType)]) {
        // Guard against value being read is not enabled for use with Asset Selector.
        assetType = LegacyAssetTypeBitcoin;
    }
    self.assetType = assetType;
    [self.tabViewController selectAsset:assetType];

    WalletManager *walletManager = WalletManager.sharedInstance;
    walletManager.settingsDelegate = self;
    walletManager.sendBitcoinDelegate = self;
    walletManager.sendEtherDelegate = self;
    walletManager.partnerExchangeIntermediateDelegate = self;
    walletManager.transactionDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [AppCoordinator.sharedInstance showHdUpgradeViewIfNeeded];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.destinationViewController isKindOfClass:[TabViewController class]]) {
        self.tabViewController = segue.destinationViewController;
    }
}

- (void)didSetAssetType:(LegacyAssetType)assetType
{
    self.assetType = assetType;

    BlockchainSettings.sharedAppInstance.selectedLegacyAssetType = self.assetType;

    BOOL animated = NO;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_DURATION * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.tabViewController.selectedIndex == [ConstantsObjcBridge tabSend]) {
            [self showSendCoinsAnimated:animated];
        } else if (self.tabViewController.selectedIndex == [ConstantsObjcBridge tabDashboard]) {
            [self showDashboard];
        } else if (self.tabViewController.selectedIndex == [ConstantsObjcBridge tabTransactions]) {
            [self showTransactionsAnimated:animated];
        } else if (self.tabViewController.selectedIndex == [ConstantsObjcBridge tabReceive]) {
            [self showReceiveAnimated:animated];
        }
    });
}

#pragma mark - Wallet Settings Delegate

- (void)didChangeLocalCurrency
{
    [self.sendBitcoinViewController reloadFeeAmountLabel];
    [self.receiveBitcoinViewController doCurrencyConversion];
}

#pragma mark - Wallet Transaction Delegate

- (void)onTransactionReceived
{
    [SoundManager.sharedInstance playBeep];
    [self receivedTransactionMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:[ConstantsObjcBridge notificationKeyTransactionReceived] object:nil];
}

- (void)didPushTransaction
{
    DestinationAddressSource source = [self getSendAddressSource];
    NSString *eventName;

    if (source == DestinationAddressSourceQR) {
        eventName = WALLET_EVENT_TX_FROM_QR;
    } else if (source == DestinationAddressSourcePaste) {
        eventName = WALLET_EVENT_TX_FROM_PASTE;
    } else if (source == DestinationAddressSourceURI) {
        eventName = WALLET_EVENT_TX_FROM_URI;
    } else if (source == DestinationAddressSourceDropDown) {
        eventName = WALLET_EVENT_TX_FROM_DROPDOWN;
    } else if (source == DestinationAddressSourceNone) {
        DLog(@"Destination address source none");
        return;
    } else {
        DLog(@"Unknown destination address source %d", source);
        return;
    }

    NSURL *URL = [NSURL URLWithString:[[BlockchainAPI.shared walletUrl] stringByAppendingFormat:URL_SUFFIX_EVENT_NAME_ARGUMENT, eventName]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"POST";

    NSURLSessionDataTask *dataTask = [[[NetworkDependenciesObjc sharedInstance] session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            DLog(@"Error saving address input: %@", [error localizedDescription]);
        }
    }];

    [dataTask resume];
}

#pragma mark - Reloading

- (void)reload
{
    [_sendBitcoinViewController reload];
    [_sendBitcoinCashViewController reload];
    [_receiveBitcoinViewController reload];
    [_receiveBitcoinCashViewController reload];
}

- (void)reloadAfterMultiAddressResponse
{
    [_sendBitcoinViewController reloadAfterMultiAddressResponse];
    [_sendBitcoinCashViewController reloadAfterMultiAddressResponse];
    [_receiveBitcoinViewController reload];
    [_receiveBitcoinCashViewController reload];
}

- (void)reloadMessageViews
{
    [self.sendBitcoinViewController hideSelectFromAndToButtonsIfAppropriate];
}

- (void)logout
{
    [_receiveBitcoinViewController clearAmounts];
    [self.exchangeContainerViewController showWelcome];

    [self dashBoardClicked:nil];
}

- (void)forgetWallet
{
    self.receiveBitcoinViewController = nil;
    self.receiveBitcoinCashViewController = nil;
    self.sendLumensViewController = nil;
    self.transferEtherViewController = nil;
    self.sendRouter = nil;
    self.sendPaxViewController = nil;
    self.exchangeContainerViewController = nil;
}

#pragma mark - BTC Send

- (BOOL)isSending
{
    return self.sendBitcoinViewController.isSending;
}

- (void)showSendCoinsAnimated:(BOOL)animated
{
    int tabIndex = (int)[ConstantsObjcBridge tabSend];
    
    switch (self.assetType) {
        case LegacyAssetTypeBitcoin: {
            if (!_sendBitcoinViewController) {
                _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
                _sendBitcoinViewController.assetType = LegacyAssetTypeBitcoin;
            }
            
            [_tabViewController setActiveViewController:_sendBitcoinViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeEther: {
            if (!_sendRouter) {
                _sendRouter = [[SendRouter alloc] initUsing:_tabViewController appCoordinator: AppCoordinator.sharedInstance];
            }
            if (!_transferEtherViewController) {
                _transferEtherViewController = [_sendRouter sendViewControllerBy:LegacyAssetTypeEther];
            }
            [_tabViewController setActiveViewController:_transferEtherViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeBitcoinCash: {
            if (!_sendBitcoinCashViewController) {
                _sendBitcoinCashViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
                _sendBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
            }
            
            [_tabViewController setActiveViewController:_sendBitcoinCashViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeStellar: {
            if (!_sendLumensViewController) {
                _sendLumensViewController = [SendLumensViewController makeWith:StellarServiceProvider.shared];
            }
            
            [_tabViewController setActiveViewController:_sendLumensViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypePax: {
            if (!_sendPaxViewController) {
                _sendPaxViewController = [SendPaxViewController make];
            }
            [_tabViewController setActiveViewController:_sendPaxViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeAlgorand: {
            break;
        }
        case LegacyAssetTypeTether: {
            // TICKET: IOS-3563 - Add USD-T support to Send
            break;
        }
    }
}

- (void)setupTransferAllFunds
{
    if (!_sendBitcoinViewController) {
       _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
    }

    [self showSendCoinsAnimated:YES];

    [_sendBitcoinViewController setupTransferAll];
}

- (void)hideSendKeyboard
{
    [self.sendBitcoinViewController hideKeyboard];
}

- (DestinationAddressSource)getSendAddressSource
{
    return self.sendBitcoinViewController.addressSource;
}

- (void)setupSendToAddress:(NSString *)address
{
    [self showSendCoinsAnimated:YES];

    if (self.assetType == LegacyAssetTypeBitcoin) {
        self.sendBitcoinViewController.addressFromURLHandler = address;
        [self.sendBitcoinViewController reload];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        self.sendBitcoinCashViewController.addressFromURLHandler = address;
        [self.sendBitcoinCashViewController reload];
    }
}

#pragma mark - Wallet Send Bitcoin Delegate

- (void)didChangeSatoshiPerByteWithSweepAmount:(NSNumber * _Nonnull)sweepAmount fee:(NSNumber * _Nonnull)fee dust:(NSNumber * _Nullable)dust updateType:(FeeUpdateType)updateType
{
    [_sendBitcoinViewController didChangeSatoshiPerByte:sweepAmount fee:fee dust:dust updateType:updateType];
}

- (void)didCheckForOverSpendingWithAmount:(NSNumber * _Nonnull)amount fee:(NSNumber * _Nonnull)fee
{
    [_sendBitcoinViewController didCheckForOverSpending:amount fee:fee];
}

- (void)didGetFeeWithFee:(NSNumber * _Nonnull)fee dust:(NSNumber * _Nullable)dust txSize:(NSNumber * _Nonnull)txSize
{
    [_sendBitcoinViewController didGetFee:fee dust:dust txSize:txSize];
}

- (void)didGetMaxFeeWithFee:(NSNumber * _Nonnull)fee amount:(NSNumber * _Nonnull)amount dust:(NSNumber * _Nullable)dust willConfirm:(BOOL)willConfirm
{
    [_sendBitcoinViewController didGetMaxFee:fee amount:amount dust:dust willConfirm:willConfirm];
}

- (void)didUpdateTotalAvailableWithSweepAmount:(NSNumber * _Nonnull)sweepAmount finalFee:(NSNumber * _Nonnull)finalFee
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [_sendBitcoinViewController didUpdateTotalAvailable:sweepAmount finalFee:finalFee];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [_sendBitcoinCashViewController didUpdateTotalAvailable:sweepAmount finalFee:finalFee];
    }
}

- (void)updateSendBalanceWithBalance:(NSNumber * _Nonnull)balance fees:(NSDictionary * _Nonnull)fees
{
    [_sendBitcoinViewController updateSendBalance:balance fees:fees];
}

- (void)didGetSurgeStatus:(BOOL)surgeStatus
{
    _sendBitcoinViewController.surgeIsOccurring = surgeStatus;
}

- (void)updateTransferAllAmount:(NSNumber *)amount fee:(NSNumber *)fee addressesUsed:(NSArray *)addressesUsed
{
    [_sendBitcoinViewController updateTransferAllAmount:amount fee:fee addressesUsed:addressesUsed];
}

- (void)showSummaryForTransferAll
{
    [_sendBitcoinViewController showSummaryForTransferAll];
}

- (void)sendDuringTransferAll:(NSString *)secondPassword
{
    [self.sendBitcoinViewController sendDuringTransferAll:secondPassword];
}

- (void)didErrorDuringTransferAll:(NSString *)error secondPassword:(NSString *)secondPassword
{
    [_sendBitcoinViewController didErrorDuringTransferAll:error secondPassword:secondPassword];
}

- (void)receivedTransactionMessage
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        if (_receiveBitcoinViewController) {
            [_receiveBitcoinViewController storeRequestedAmount];
        }
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [_receiveBitcoinCashViewController reload];
    }
}

- (void)didReceivePaymentNoticeWithNotice:(NSString *_Nullable)notice
{
    if (notice &&
        self.tabViewController.selectedIndex == [ConstantsObjcBridge tabSend] &&
        !LoadingViewPresenter.sharedInstance.isVisible &&
        AuthenticationCoordinator.sharedInstance.isDisplayingLoginAuthenticationFlow &&
        !self.tabViewController.presentedViewController) {
        [[AlertViewPresenter sharedInstance] standardNotifyWithTitle:[LocalizationConstantsObjcBridge information] message:notice in:self handler: nil];
    }
}

- (void)didErrorWhileBuildingPaymentWithError:(NSString *)message
{
    [[AlertViewPresenter sharedInstance] standardErrorWithTitle:[LocalizationConstantsObjcBridge error] message:message in:self handler:nil];
}

#pragma mark - Eth Send

- (void)didFetchEthExchangeRate:(NSNumber *)rate
{
    self.latestEthExchangeRate = [NSDecimalNumber decimalNumberWithDecimal:[rate decimalValue]];

    [self.tabViewController didFetchEthExchangeRate];
}

#pragma mark - Wallet Send Ether Delegate

- (void)didSendEther
{
    [WalletActionEventBus.sharedInstance publishObjWithAction:WalletActionSendCrypto extras:nil];

    [[ModalPresenter sharedInstance] closeAllModals];

    [[AlertViewPresenter sharedInstance] standardErrorWithTitle:[LocalizationConstantsObjcBridge success] message:BC_STRING_PAYMENT_SENT_ETHER in:self handler:nil];

    [self showTransactionsAnimated:YES];

    [self didPushTransaction];
}

- (void)didGetEtherAddressWithSecondPassword
{
    // TODO: IOS-2193
}

- (void)didErrorDuringEtherSendWithError:(NSString * _Nonnull)error
{
    [[ModalPresenter sharedInstance] closeAllModals];

    [[AlertViewPresenter sharedInstance] standardErrorWithTitle:[LocalizationConstantsObjcBridge error] message:error in:self handler:nil];
}

- (void)didUpdateEthPaymentWithPayment:(NSDictionary * _Nonnull)payment
{}

- (void)didErrorWhenGettingFiatAtTimeWithError:(NSString *)error {
    [[AlertViewPresenter sharedInstance] standardErrorWithTitle:BC_STRING_ERROR message:BC_STRING_ERROR_GETTING_FIAT_AT_TIME in:self handler:nil];
}

#pragma mark - Receive

- (void)showReceiveAnimated:(BOOL)animated
{
    int tabIndex = (int)[ConstantsObjcBridge tabReceive];

    switch (self.assetType) {
        case LegacyAssetTypeBitcoin: {
            if (!_receiveBitcoinViewController) {
                _receiveBitcoinViewController = [[ReceiveBitcoinViewController alloc] initWithNibName:NIB_NAME_RECEIVE_COINS bundle:[NSBundle mainBundle]];
            }
            
            [_tabViewController setActiveViewController:_receiveBitcoinViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeEther: {
            [self setReceiveControllerIfNeededForAssetType:self.assetType animated:animated];
            break;
        }
        case LegacyAssetTypeBitcoinCash: {
            if (!_receiveBitcoinCashViewController) {
                _receiveBitcoinCashViewController = [[ReceiveBitcoinViewController alloc] initWithNibName:NIB_NAME_RECEIVE_COINS bundle:[NSBundle mainBundle]];
                _receiveBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
            }
            
            [_tabViewController setActiveViewController:_receiveBitcoinCashViewController animated:animated index:tabIndex];
            break;
        }
        case LegacyAssetTypeStellar: {
            [self setReceiveControllerIfNeededForAssetType:self.assetType animated:animated];
            break;
        }
        case LegacyAssetTypePax: {
            [self setReceiveControllerIfNeededForAssetType:self.assetType animated:animated];
            break;
        }
        case LegacyAssetTypeAlgorand: {
            break;
        }
        case LegacyAssetTypeTether: {
            // TICKET: IOS-3563 - Add USD-T support to Receive
            break;
        }
    }
}

- (void)setReceiveControllerIfNeededForAssetType:(LegacyAssetType)assetType animated:(BOOL)animated
{
    if ([_tabViewController.activeViewController isKindOfClass:[ReceiveCryptoViewController class]]) {
        ReceiveCryptoViewController *receive = (ReceiveCryptoViewController *) _tabViewController.activeViewController;
        if ([receive legacyAssetType] != assetType) {
            ReceiveCryptoViewController *receiveCryptoViewController = [ReceiveCryptoViewController makeFor:assetType];
            [_tabViewController setActiveViewController:receiveCryptoViewController animated:animated index:(int)[ConstantsObjcBridge tabReceive]];
        }
    } else {
        ReceiveCryptoViewController *receiveCryptoViewController = [ReceiveCryptoViewController makeFor:assetType];
        [_tabViewController setActiveViewController:receiveCryptoViewController animated:animated index:(int)[ConstantsObjcBridge tabReceive]];
    }
}

- (void)clearReceiveAmounts
{
    [self.receiveBitcoinViewController clearAmounts];
}

- (void)didSetDefaultAccount
{
    [self.receiveBitcoinViewController reloadMainAddress];
    [self.receiveBitcoinCashViewController reloadMainAddress];
}

- (void)paymentReceived:(uint64_t)amount
{
    if (self.assetType == LegacyAssetTypeBitcoin) {
        [_receiveBitcoinViewController paymentReceived:amount];
    } else if (self.assetType == LegacyAssetTypeBitcoinCash) {
        [_receiveBitcoinCashViewController paymentReceived:amount];
    }
}

- (NSDecimalNumber *)lastEthExchangeRate
{
    return self.latestEthExchangeRate;
}

#pragma mark - Dashboard

- (void)showDashboard {
    if (self.dashboardNavigationController == nil) {
        DashboardViewController *vc = [[DashboardViewController alloc] init];
        self.dashboardNavigationController = [[UINavigationController alloc] initWithRootViewController: vc];
    }
    [_tabViewController setActiveViewController:self.dashboardNavigationController animated:true index:[ConstantsObjcBridge tabDashboard]];
}

- (void)showActivity {
    if (self.activityNavigationController == nil) {
        ActivityScreenViewController *viewController = [[ActivityScreenViewController alloc] init];
        self.activityNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    [_tabViewController setActiveViewController:self.activityNavigationController animated:true index:[ConstantsObjcBridge tabTransactions]];
}

#pragma mark - Transactions

- (void)showTransactionsAnimated:(BOOL)animated
{
    [self showActivity];
}

- (void)setupBitpayPaymentFromURL:(NSURL *)bitpayURL
{
    if (!self.sendBitcoinViewController) {
        // really no reason to lazyload anymore...
        _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
    }
    
    [self showSend:LegacyAssetTypeBitcoin];
    [_sendBitcoinViewController setAmountStringFromBitPayURL:bitpayURL];
}

- (void)setupBitcoinPaymentFromURLHandlerWithAmountString:(NSString *)amountString address:(NSString *)address
{
    if (!self.sendBitcoinViewController) {
        // really no reason to lazyload anymore...
        _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
    }
    
    [_sendBitcoinViewController setAmountStringFromUrlHandler:amountString withToAddress:address];
    [_sendBitcoinViewController reload];
}

#pragma mark - Reloading

- (void)reloadSymbols
{
    [_sendBitcoinViewController reloadSymbols];
    [_sendBitcoinCashViewController reloadSymbols];
    [_tabViewController reloadSymbols];
}

- (void)reloadSendController
{
    [_sendBitcoinViewController reload];
}

- (void)clearSendToAddressAndAmountFields
{
    [self.sendBitcoinViewController clearToAddressAndAmountFields];
}

- (void)enableSendPaymentButtons
{
    [self.sendBitcoinViewController enablePaymentButtons];
}

- (BOOL)isSendViewControllerTransferringAll
{
    return _sendBitcoinViewController.transferAllMode;
}

- (void)transferFundsToDefaultAccountFromAddress:(NSString *)address
{
    if (!_sendBitcoinViewController) {
        _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
    }

    [_sendBitcoinViewController transferFundsToDefaultAccountFromAddress:address];
}

- (void)hideSendAndReceiveKeyboards
{
    // Dismiss sendviewController keyboard
    if (_sendBitcoinViewController) {
        [_sendBitcoinViewController hideKeyboardForced];

        // Make sure the the send payment button on send screen is enabled (bug when second password requested and app is backgrounded)
        [_sendBitcoinViewController enablePaymentButtons];
    }

    // Dismiss receiveCoinsViewController keyboard
    if (_receiveBitcoinViewController) {
        [_receiveBitcoinViewController hideKeyboardForced];
    }
}

- (void)updateBadgeNumber:(NSInteger)number forSelectedIndex:(int)index
{
    [self.tabViewController updateBadgeNumber:number forSelectedIndex:index];
}

#pragma mark - Navigation

- (void)transitionToIndex:(NSInteger)index
{
    if (index == [ConstantsObjcBridge tabSend]) {
        [self sendCoinsClicked:nil];
    } else if (index == [ConstantsObjcBridge tabDashboard]) {
        [self dashBoardClicked:nil];
    } else if (index == [ConstantsObjcBridge tabTransactions]) {
        [self transactionsClicked:nil];
    } else if (index == [ConstantsObjcBridge tabReceive]) {
        [self receiveCoinClicked:nil];
    }
}

- (IBAction)menuButtonClicked:(UIButton *)sender
{
    if (self.sendBitcoinViewController) {
        [self hideSendKeyboard];
    }
}

- (void)dashBoardClicked:(UITabBarItem *)sender
{
    [self showDashboard];
}

- (void)receiveCoinClicked:(UITabBarItem *)sender
{
    [self recordRequestTabItemClick];
    [self showReceiveAnimated:YES];
}

- (void)swapTapped:(nullable UITabBarItem *)sender
{
    [self recordSwapTabItemClick];
    [self.tabViewController setActiveViewController:self.exchangeContainerViewController animated:true index:[ConstantsObjcBridge tabSwap]];
}

- (void)showReceiveBitcoinCash
{
    [self changeAssetSelectorAsset:LegacyAssetTypeBitcoinCash];
    [self showReceiveAnimated:YES];
    [_receiveBitcoinCashViewController reload];
}

- (void)showReceive:(LegacyAssetType)assetType {
    [self changeAssetSelectorAsset:assetType];
    [self showReceiveAnimated:YES];
}

- (void)showSend:(LegacyAssetType)assetType {
    [self changeAssetSelectorAsset:assetType];
    [self showSendCoinsAnimated:YES];
}

- (void)showTransactionsAlgorand
{
    [self showTransactionsAnimated:YES];
}

- (void)showTransactionsBitcoin
{
    [self changeAssetSelectorAsset:LegacyAssetTypeBitcoin];
    [self showTransactionsAnimated:YES];
}

- (void)showTransactionsEther
{
    [self changeAssetSelectorAsset:LegacyAssetTypeEther];
    [self showTransactionsAnimated:YES];
}

- (void)showTransactionsBitcoinCash
{
    [self changeAssetSelectorAsset:LegacyAssetTypeBitcoinCash];
    [self showTransactionsAnimated:YES];
}

-(void)showTransactionsStellar
{
    [self changeAssetSelectorAsset:LegacyAssetTypeStellar];
    [self showTransactionsAnimated:YES];
}

-(void)showTransactionsPax
{
    [self changeAssetSelectorAsset:LegacyAssetTypePax];
    [self showTransactionsAnimated:YES];
}

-(void)showTransactionsTether
{
    [self showTransactionsAnimated:YES];
}

- (void)changeAssetSelectorAsset:(LegacyAssetType)assetType
{
    self.assetType = assetType;
    BlockchainSettings.sharedAppInstance.selectedLegacyAssetType = assetType;
    [self.tabViewController selectAsset:assetType];
}

- (void)transactionsClicked:(UITabBarItem *)sender
{
    [self recordActivityTabItemClick];
    [self showTransactionsAnimated:YES];
}

- (void)sendCoinsClicked:(UITabBarItem *)sender
{
    [self recordSendTabItemClick];
    [self showSendCoinsAnimated:YES];
}

- (void)qrCodeButtonClicked
{
    if (_receiveBitcoinViewController) {
        [_receiveBitcoinViewController hideKeyboard];
    }

    UIViewController * _Nullable viewControllerToPresent;
    switch (self.assetType) {
        case LegacyAssetTypeBitcoin: {
            if (!_sendBitcoinViewController) {
                _sendBitcoinViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
            }
            [_sendBitcoinViewController QRCodebuttonClicked:nil];
            viewControllerToPresent = _sendBitcoinViewController;
            break;
        }
        case LegacyAssetTypeEther: {
            if (!_sendRouter) {
                _sendRouter = [[SendRouter alloc] initUsing:_tabViewController appCoordinator: AppCoordinator.sharedInstance];
            }
            _transferEtherViewController = [_sendRouter sendViewControllerBy:LegacyAssetTypeEther];
            
            viewControllerToPresent = _transferEtherViewController;
            break;
        }
        case LegacyAssetTypeBitcoinCash: {
            if (!_sendBitcoinCashViewController) {
                _sendBitcoinCashViewController = [[SendBitcoinViewController alloc] initWithNibName:NIB_NAME_SEND_COINS bundle:[NSBundle mainBundle]];
                _sendBitcoinCashViewController.assetType = LegacyAssetTypeBitcoinCash;
            }
            [_sendBitcoinCashViewController QRCodebuttonClicked:nil];
            viewControllerToPresent = _sendBitcoinCashViewController;
            break;
        }
        case LegacyAssetTypeStellar: {
            // Always creating a new SendLumensViewController for stellar. This is because there is a layout issue
            // when reusing an existing SendLumensViewController wherein after you scan the QR code, the view occupies
            // the full frame, and not the adjusted frame.
            _sendLumensViewController = [SendLumensViewController makeWith:StellarServiceProvider.shared];
            [_sendLumensViewController scanQrCodeForDestinationAddress];
            viewControllerToPresent = _sendLumensViewController;
            break;
        }
        case LegacyAssetTypePax: {
            _sendPaxViewController = [SendPaxViewController make];
            [_sendPaxViewController scanQrCodeForDestinationAddress];
            viewControllerToPresent = _sendPaxViewController;
            break;
        }
        case LegacyAssetTypeAlgorand: {
            break;
        }
        case LegacyAssetTypeTether: {
            // TICKET: IOS-3563 - Add USD-T support to Send
            break;
        }
    }
    if (viewControllerToPresent != nil) {
        [_tabViewController setActiveViewController:viewControllerToPresent animated:NO index:[ConstantsObjcBridge tabSend]];
    }
    
    // Display QR only AFTER setting active view controller (previous logic is risky and should be changed)
    if (self.assetType == LegacyAssetTypeEther && _sendRouter) {
        [_sendRouter presentQRCodeScanUsing:self.assetType];
    }
}

/// This callback happens when an Eth account is created. This happens when a user goes to
/// swap for the first time. This is a delegate callback from the JS layer. This needs to be
/// refactored so that it is in a completion handler and only in `ExchangeContainerViewController`
- (void)didCreateEthAccountForExchange
{
    [self.exchangeContainerViewController showExchange];
}

- (ExchangeContainerViewController *)exchangeContainerViewController {
    if (_exchangeContainerViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExchangeContainerViewController" bundle:[NSBundle mainBundle]];
        _exchangeContainerViewController = [storyboard instantiateInitialViewController];
    }
    return _exchangeContainerViewController;
}

@end

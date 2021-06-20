// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <Foundation/Foundation.h>

@class Wallet;
@class MultiAddressResponse;
@protocol WalletSuccessCallback;
@protocol WalletDismissCallback;

@protocol WalletDelegate <NSObject>

@optional
- (void)didBackupWallet;
- (void)didCreateNewAccount:(NSString *)guid sharedKey:(NSString *)sharedKey password:(NSString *)password;
- (void)didFailBackupWallet;
- (void)didFailGetHistory:(NSString *_Nullable)error;
- (void)didFailRecovery;
- (void)didFetchBitcoinCashHistory;
- (void)didGenerateNewAddress;
- (void)didGetMultiAddressResponse:(MultiAddressResponse *)response;
- (void)didRecoverWallet;
- (void)didSetDefaultAccount;
- (void)errorCreatingNewAccount:(NSString *)message;
- (void)getPrivateKeyPasswordWithSuccess:(id<WalletSuccessCallback>)success;
- (void)getSecondPasswordWithSuccess:(id<WalletSuccessCallback>)success dismiss:(id<WalletDismissCallback>)dismiss;
- (void)returnToAddressesScreen;
- (void)walletDidDecryptWithSharedKey:(nullable NSString *)sharedKey guid:(nullable NSString *)guid;
- (void)walletDidFinishLoad;
- (void)walletDidGetAccountInfo:(Wallet *)wallet;
- (void)walletDidGetAccountInfoAndExchangeRates:(Wallet *)wallet;
- (void)walletDidGetBtcExchangeRates;
- (void)walletDidLoad;
- (void)walletFailedToDecrypt;
- (void)walletFailedToLoad;
- (void)walletJSReady;
@end

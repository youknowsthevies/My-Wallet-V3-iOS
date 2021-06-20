// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "KeychainItemWrapper+SwipeAddresses.h"

@implementation KeychainItemWrapper (SwipeAddresses)

#pragma mark - Swipe To Receive

+ (NSString *)keychainKeyForAssetType:(LegacyAssetType)assetType
{
    switch (assetType) {
        case LegacyAssetTypeAave:
            return KEYCHAIN_KEY_AAVE_ADDRESS;
        case LegacyAssetTypeAlgorand:
            return KEYCHAIN_KEY_ALGO_ADDRESS;
        case LegacyAssetTypeBitcoin:
            return KEYCHAIN_KEY_BTC_SWIPE_ADDRESSES;
        case LegacyAssetTypeBitcoinCash:
            return KEYCHAIN_KEY_BCH_SWIPE_ADDRESSES;
        case LegacyAssetTypeEther:
            return KEYCHAIN_KEY_ETHER_ADDRESS;
        case LegacyAssetTypePax:
            return KEYCHAIN_KEY_PAX_ADDRESS;
        case LegacyAssetTypePolkadot:
            return KEYCHAIN_KEY_DOT_ADDRESS;
        case LegacyAssetTypeStellar:
            return KEYCHAIN_KEY_XLM_ADDRESS;
        case LegacyAssetTypeTether:
            return KEYCHAIN_KEY_USDT_ADDRESS;
        case LegacyAssetTypeWDGLD:
            return KEYCHAIN_KEY_WDGLD_ADDRESS;
        case LegacyAssetTypeYearnFinance:
            return KEYCHAIN_KEY_YFI_ADDRESS;
    }
}

+ (void)removeAllSwipeAddressesForAssetType:(LegacyAssetType)assetType
{
    NSString *keychainKey = [KeychainItemWrapper keychainKeyForAssetType:assetType];

    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:keychainKey accessGroup:nil];
    [keychain resetKeychainItem];
}

+ (void)removeAllSwipeAddresses
{
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeBitcoin];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeBitcoinCash];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeEther];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeStellar];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypePax];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeAlgorand];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeTether];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeWDGLD];
    [KeychainItemWrapper removeAllSwipeAddressesForAssetType:LegacyAssetTypeYearnFinance];
}

@end

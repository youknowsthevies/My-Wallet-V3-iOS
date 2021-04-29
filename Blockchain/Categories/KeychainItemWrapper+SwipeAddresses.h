// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "KeychainItemWrapper.h"
#import "Assets.h"

@interface KeychainItemWrapper (SwipeAddresses)
+ (NSArray *)getSwipeAddressesForAssetType:(LegacyAssetType)assetType;
+ (void)addSwipeAddress:(NSString *)swipeAddress assetType:(LegacyAssetType)assetType;
+ (void)removeFirstSwipeAddressForAssetType:(LegacyAssetType)assetType;
+ (void)removeSwipeAddress:(NSString *)swipeAddress assetType:(LegacyAssetType)assetType;
+ (void)removeAllSwipeAddressesForAssetType:(LegacyAssetType)assetType;
+ (void)removeAllSwipeAddresses;
+ (void)setSingleSwipeAddress:(NSString *_Nonnull)swipeAddress forAssetType:(LegacyAssetType)assetType;
+ (NSString *_Nullable)getSingleSwipeAddressForAssetType:(LegacyAssetType)assetType;
+ (NSString *)keychainKeyForAssetType:(LegacyAssetType)assetType;
@end

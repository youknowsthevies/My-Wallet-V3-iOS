// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#ifndef Assets_h
#define Assets_h

/// LegacyAssetType is used by Wallet and other legacy ObjC code when dealing with Bitcoin or Bitcoin Cash.
typedef NS_CLOSED_ENUM(NSInteger, LegacyAssetType) {
    LegacyAssetTypeBitcoin,
    LegacyAssetTypeBitcoinCash
};

#endif /* Assets_h */

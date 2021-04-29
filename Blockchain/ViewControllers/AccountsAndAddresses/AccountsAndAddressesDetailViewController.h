// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
#import "Assets.h"

@interface AccountsAndAddressesDetailViewController : UIViewController

@property (nonatomic, assign) int account;
@property (nonatomic, assign) LegacyAssetType assetType;
@property (nonatomic, copy) NSString *navigationItemTitle;
@property (nonatomic, copy) NSString *address;

@end

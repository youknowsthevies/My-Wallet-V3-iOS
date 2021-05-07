// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
#import "AssetSelectorView.h"

@interface AccountsAndAddressesNavigationController : UINavigationController

- (AssetSelectorView *)assetSelectorView;
- (void)didGenerateNewAddress;
- (void)reload;

@end

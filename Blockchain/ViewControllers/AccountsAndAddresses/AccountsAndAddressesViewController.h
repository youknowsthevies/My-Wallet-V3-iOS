// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
#import "Assets.h"
#import "Blockchain-Swift.h"

@interface AccountsAndAddressesViewController : UIViewController
@property (nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSArray *allKeys;
@property (nonatomic) UIView *containerView;
@property (nonatomic) LegacyAssetType assetType;
@property (nonatomic) AssetSelectorView *assetSelectorView;
- (void)didGenerateNewAddress;
@end

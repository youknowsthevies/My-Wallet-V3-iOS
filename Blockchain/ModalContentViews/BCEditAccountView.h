// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
#import "Assets.h"
@class BCSecureTextField;

@interface BCEditAccountView : UIView <UITextFieldDelegate>

@property int accountIdx;
@property (nonatomic) LegacyAssetType assetType;
@property (nonatomic, strong) BCSecureTextField *labelTextField;
- (id)initWithAssetType:(LegacyAssetType)assetType;
@end

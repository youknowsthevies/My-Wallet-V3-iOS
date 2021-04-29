// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
@class BCSecureTextField;

@interface BCCreateAccountView : UIView <UITextFieldDelegate>

@property (nonatomic, strong) BCSecureTextField *labelTextField;

@end

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
@class BCTextField;

@interface BCEditAddressView : UIView <UITextFieldDelegate>

@property NSString *address;
@property (nonatomic) BCTextField *labelTextField;

-(id)initWithAddress:(NSString *)address;

@end

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>

@implementation UIApplication (Suspend)

- (void)suspendApp
{
    [self performSelector:@selector(suspend)];
}

@end

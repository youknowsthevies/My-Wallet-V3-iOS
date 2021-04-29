// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "UIViewController+AutoDismiss.h"

@implementation UIViewController (AutoDismiss)

- (void)autoDismiss
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Special case for UIActivityViewController, when tapping more actions shows another viewController
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

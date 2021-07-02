// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "UIView+ChangeFrameAttribute.h"

@implementation UIView (ChangeFrameAttribute)

- (void)changeXPosition:(CGFloat)newX
{
    self.frame = CGRectMake(newX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)changeYPosition:(CGFloat)newY
{
    self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
}

- (void)changeWidth:(CGFloat)newWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
}

@end

// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import "BCModalView.h"
#import "LocalizationConstants.h"
#import "Blockchain-Swift.h"

// TODO: deprecate BCModalView
@implementation BCModalView

- (id)initWithCloseType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *)headerText
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect myHolderViewFrame = CGRectZero;
    CGFloat safeAreaInsetTop = [UIView rootViewSafeAreaInsets].top;
    CGFloat offsetY = safeAreaInsetTop;

    self = [super initWithFrame:window.frame];

    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.closeType = closeType;

        if (showHeader) {
            myHolderViewFrame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:NO assetSelector:NO];
            CGFloat topBarHeight = [ConstantsObjcBridge defaultNavigationBarHeight] + safeAreaInsetTop;
            offsetY = topBarHeight;
            CGRect topBarFrame = CGRectMake(0, 0, window.frame.size.width, topBarHeight);
            UIView *topBarView = [self createTopBarViewWithFrame:topBarFrame];
            [self addSubview:topBarView];

            UILabel *headerLabel = [self createHeader];
            headerLabel.text = headerText;
            [headerLabel sizeToFit];
            CGFloat labelWidth = MIN(headerLabel.frame.size.width, topBarView.frame.size.width - 105);
            CGFloat labelHeight = headerLabel.frame.size.height;
            CGFloat labelPosX = (topBarView.frame.size.width / 2) - (labelWidth / 2);
            CGFloat labelPosY = (topBarView.frame.size.height / 2) - (headerLabel.frame.size.height / 2) + (safeAreaInsetTop / 2);
            [headerLabel setFrame:CGRectMake(labelPosX, labelPosY, labelWidth, labelHeight)];
            [topBarView addSubview:headerLabel];

            if (closeType == ModalCloseTypeBack) {
                self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 44)];
                self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                self.backButton.center = CGPointMake(self.backButton.center.x, headerLabel.center.y);
                [self.backButton setImage:[UIImage imageNamed:@"back_chevron_icon"] forState:UIControlStateNormal];
                [self.backButton addTarget:self action:@selector(closeModalClicked:) forControlEvents:UIControlEventTouchUpInside];
                [topBarView addSubview:self.backButton];
            } else if (closeType == ModalCloseTypeClose) {
                CGFloat rightEdgeInset = 8;
                self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 37 - rightEdgeInset, 0, 37, 44)];
                self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                self.closeButton.center = CGPointMake(self.closeButton.center.x, headerLabel.center.y);
                [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
                [self.closeButton addTarget:self action:@selector(closeModalClicked:) forControlEvents:UIControlEventTouchUpInside];
                [topBarView addSubview:self.closeButton];
            }
            [self bringSubviewToFront:topBarView];
        } else {
            myHolderViewFrame = [UIView rootViewSafeAreaFrameWithNavigationBar:NO tabBar:NO assetSelector:NO];
        }
        self.myHolderView = [[UIView alloc] initWithFrame:CGRectOffset(myHolderViewFrame, 0, offsetY)];
        [self addSubview:self.myHolderView];
    }

    return self;
}

- (IBAction)closeModalClicked:(id)sender
{
    if (self.closeType != ModalCloseTypeNone) {
        if (self.closeType == ModalCloseTypeBack) {
            [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFromLeft];
        }
        else {
            [self endEditing:YES];
            [[ModalPresenter sharedInstance] closeModalWithTransition:kCATransitionFade];
        }
    }
}

@end

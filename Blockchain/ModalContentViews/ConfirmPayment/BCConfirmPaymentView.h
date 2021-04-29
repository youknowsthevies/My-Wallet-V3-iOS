// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
#import "BCDescriptionView.h"
@class BCConfirmPaymentViewModel;

@protocol ConfirmPaymentViewDelegate
- (void)confirmButtonDidTap:(NSString *)note;
- (void)feeInformationButtonClicked;
@end

@interface BCConfirmPaymentView : BCDescriptionView

- (instancetype)initWithFrame:(CGRect)frame viewModel:(BCConfirmPaymentViewModel *)viewModel sendButtonFrame:(CGRect)sendButtonFrame;

@property (nonatomic, strong) UIButton *reallyDoPaymentButton;
@property (nonatomic, strong) UIButton *feeInformationButton;
@property (nonatomic, weak) id <ConfirmPaymentViewDelegate> confirmDelegate;

@end

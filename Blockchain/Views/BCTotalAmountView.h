// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>

@interface BCTotalAmountView : UIView
@property (nonatomic) UILabel *btcAmountLabel;
@property (nonatomic) UILabel *fiatAmountLabel;
- (id)initWithFrame:(CGRect)frame color:(UIColor *)color amount:(uint64_t)amount;
- (void)updateLabelsWithAmount:(uint64_t)amount;
@end

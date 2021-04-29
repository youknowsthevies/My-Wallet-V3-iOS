// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
#import "FeeTypes.h"

@protocol FeeSelectionDelegate
- (void)didSelectFeeType:(FeeType)feeType;
- (FeeType)selectedFeeType;
@end

@interface BCFeeSelectionView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <FeeSelectionDelegate> delegate;

@end

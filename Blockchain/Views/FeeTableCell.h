//
//  FeeTableCell.h
//  Blockchain
//
//  Created by kevinwu on 5/8/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeeTypes.h"

@interface FeeTableCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, assign, readonly) FeeType feeType;

- (instancetype)initWithFeeType:(FeeType)feeType;

@end

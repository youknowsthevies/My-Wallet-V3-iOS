// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>

@interface ReceiveTableCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel * labelLabel;
@property(nonatomic, strong) IBOutlet UILabel *balanceLabel;
@property(nonatomic, strong) IBOutlet UILabel * addressLabel;
@property(nonatomic, strong) IBOutlet UILabel * watchLabel;
@property(nonatomic, strong) IBOutlet UIButton *balanceButton;

@end

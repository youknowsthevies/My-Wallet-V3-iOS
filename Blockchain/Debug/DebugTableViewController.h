// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DebugViewPresenter) {
    welcome = 0,
    pin = 2,
    settings = 3
};

@interface DebugTableViewController : UITableViewController
@property (nonatomic, assign) DebugViewPresenter presenter;
@end

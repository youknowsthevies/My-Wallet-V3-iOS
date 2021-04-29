// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>

@interface BCDescriptionView : UIScrollView

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, assign) BOOL isEditingDescription;
@property (nonatomic, assign) CGFloat descriptionCellHeight;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, assign) CGFloat originalTableViewHeight;

- (void)beginEditingDescription;
- (void)endEditingDescription;
- (UITableViewCell *)configureDescriptionTextViewForCell:(UITableViewCell *)cell;
- (UITextView *)configureTextViewWithFrame:(CGRect)frame;

@end

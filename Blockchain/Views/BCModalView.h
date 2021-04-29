// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>

//	Modal close codes
typedef enum {
    ModalCloseTypeClose = 100,
    ModalCloseTypeBack = 200,
    ModalCloseTypeNone = 300
}ModalCloseType;

@interface BCModalView : UIView

@property(nullable, nonatomic, copy) void (^onDismiss)(void);
@property(nullable, nonatomic, copy) void (^onResume)(void);
@property(nonatomic, strong) IBOutlet UIView * _Nullable myHolderView;
@property(nonatomic, strong) IBOutlet UIButton * _Nullable closeButton;
@property(nonatomic, strong) IBOutlet UIButton * _Nullable backButton;

@property(nonatomic) ModalCloseType closeType;

- (id _Nonnull )initWithCloseType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *_Nullable)headerText;
- (IBAction)closeModalClicked:(id _Nullable )sender;

@end

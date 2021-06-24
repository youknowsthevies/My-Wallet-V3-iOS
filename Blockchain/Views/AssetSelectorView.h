// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#import <UIKit/UIKit.h>
#import "Assets.h"

@protocol AssetSelectorViewDelegate
- (void)didSelectAsset:(LegacyAssetType)assetType;
- (void)didOpenSelector;
@end

@interface AssetSelectorView : UIView

@property (nonatomic, assign) LegacyAssetType selectedAsset;
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *assets;
@property (nonatomic, assign, readonly) BOOL isOpen;
@property (nonatomic, weak) id <AssetSelectorViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray<NSNumber *> *)assets parentView:(UIView *)parentView;
- (void)constraintToParent:(UIView *)parentView;
- (void)close;
- (void)open;
- (void)hide;
- (void)show;
- (void)reload;
@end

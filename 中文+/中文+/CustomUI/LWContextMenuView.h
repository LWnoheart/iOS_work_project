//
//  LWContextMenuView.h
//  中文+
//
//  Created by tangce on 14-7-3.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWContextOverlayViewDataSource;
@protocol LWContextOverlayViewDelegate;

@interface LWContextMenuView : UIView

@property (nonatomic, assign) id<LWContextOverlayViewDataSource> dataSource;
@property (nonatomic, assign) id<LWContextOverlayViewDelegate> delegate;


@end

@protocol LWContextOverlayViewDataSource <NSObject>

@required
- (NSInteger) numberOfMenuItems:(LWContextMenuView *)ContextMenuView;
- (UIImage*) imageForItemAtIndex:(NSInteger) index ContextMenuView:(LWContextMenuView *)ContextMenuView;

@end

@protocol LWContextOverlayViewDelegate <NSObject>

- (void) didSelectItemAtIndex:(NSInteger) selectedIndex ContextMenuView:(LWContextMenuView *)ContextMenuView;

@end
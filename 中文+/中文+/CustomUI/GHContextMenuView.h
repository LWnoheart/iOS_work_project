//
//  GHContextOverlayView.h
//  GHContextMenu
//
//  Created by Tapasya on 27/01/14.
//  Copyright (c) 2014 Tapasya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GHContextOverlayViewDataSource;
@protocol GHContextOverlayViewDelegate;

@interface GHContextMenuView : UIView

@property (nonatomic, assign) id<GHContextOverlayViewDataSource> dataSource;
@property (nonatomic, assign) id<GHContextOverlayViewDelegate> delegate;

//- (void) longPressDetected:(UIGestureRecognizer*) gestureRecognizer;

@end

@protocol GHContextOverlayViewDataSource <NSObject>

@required
- (NSInteger) numberOfMenuItems:(GHContextMenuView *)ContextMenuView;
- (UIImage*) imageForItemAtIndex:(NSInteger) index ContextMenuView:(GHContextMenuView *)ContextMenuView;

@end

@protocol GHContextOverlayViewDelegate <NSObject>

- (void) didSelectItemAtIndex:(NSInteger) selectedIndex ContextMenuView:(GHContextMenuView *)ContextMenuView;

@end

//
//  GHContextOverlayView.m
//  GHContextMenu
//
//  Created by Tapasya on 27/01/14.
//  Copyright (c) 2014 Tapasya. All rights reserved.
//

#import "GHContextMenuView.h"


NSInteger const GHMainItemSize = 40;
NSInteger const GHMenuItemSize = 35;
NSInteger const GHBorderWidth  = 4;



@interface GHMenuItemLocation : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat angle;


@end

@implementation GHMenuItemLocation

@end


@interface GHContextMenuView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer* longPressRecognizer;

@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, strong) NSMutableArray* menuItems;

@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat arcAngle;
@property (nonatomic) CGFloat angleBetweenItems;
@property (nonatomic, strong) NSMutableArray* itemLocations;

@end

@implementation GHContextMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [btn setBackgroundImage:[UIImage imageNamed:@"拓展.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"拓展.png"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1456;
        [self addSubview:btn];
        self.backgroundColor  = [UIColor clearColor];
        _menuItems = [NSMutableArray array];
        _itemLocations = [NSMutableArray array];
        _arcAngle = M_PI_2;
        _radius = 90;
        
        self.isShowing = NO;
        
    }
    return self;
}

-(void)buttonPress:(UIButton *)button
{
    if (!self.isShowing) {
        if (self.menuItems.count == 0||self.itemLocations.count == 0) {
            [self reloadData];
            [self layoutMenuItems];
        }
        [self showMenu];
    }else{
        [self hideMenu];
    }
}

- (void) showMenu
{
    self.isShowing = YES;
    for (UIButton *btn in self.menuItems) {
        btn.hidden = NO;
//        btn.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    [UIView animateWithDuration:0.3f animations:^(){
        for (int i = 0; i < self.menuItems.count; i++) {
            UIButton *btn = [self.menuItems objectAtIndex:i];
            GHMenuItemLocation *location = [self.itemLocations objectAtIndex:i];
            btn.center = location.position;
        }
    }];
}
//隐藏菜单
- (void) hideMenu
{
    [UIView animateWithDuration:0.3f animations:^(){
        for (UIButton *btn in self.menuItems) {
            btn.frame = CGRectMake(0, 0, GHMenuItemSize, GHMenuItemSize);
        }
    }completion:^(BOOL ber){
        if (ber) {
            for (UIButton *btn in self.menuItems) {
//                btn.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                btn.hidden = YES;
            }
            self.isShowing = NO;
        }
    }];
}

# pragma mark - menu item layout
//刷新数据，也就是移除层和位置数组并且提取新的层加入数组
- (void) reloadData
{
    for (UIButton *button in self.menuItems) {
        [button removeFromSuperview];
    }
    [self.menuItems removeAllObjects];
    
    if (self.dataSource != nil) {
        NSInteger count = [self.dataSource numberOfMenuItems:self];
        for (int i = 0; i < count; i++) {
            UIImage* image = [self.dataSource imageForItemAtIndex:i ContextMenuView:self];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundImage:image forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, GHMenuItemSize, GHMenuItemSize);
            [btn addTarget:self action:@selector(smallBtnPress:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [self addSubview:btn];
            btn.hidden = YES;
            [self.menuItems addObject:btn];
        }
    }
}
//更新移动目标点位置
- (void) layoutMenuItems
{
    [self.itemLocations removeAllObjects];
    
    CGSize itemSize = CGSizeMake(GHMenuItemSize, GHMenuItemSize);
    CGFloat itemRadius = sqrt(pow(itemSize.width, 2) + pow(itemSize.height, 2)) / 2;
    self.arcAngle = ((itemRadius * self.menuItems.count) / self.radius) * 1.5;
    
    NSUInteger count = self.menuItems.count;
	BOOL isFullCircle = (self.arcAngle == M_PI*2);
	NSUInteger divisor = (isFullCircle) ? count : count - 1;

    self.angleBetweenItems = self.arcAngle/divisor;
    
    for (int i = 0; i < self.menuItems.count; i++) {
        GHMenuItemLocation *location = [self locationForItemAtIndex:i];
        [self.itemLocations addObject:location];
    }
}
//根据index返回单独一个层的目标点位置
- (GHMenuItemLocation*) locationForItemAtIndex:(NSUInteger) index
{
	CGFloat itemAngle = [self itemAngleAtIndex:index];
	
	CGPoint itemCenter = CGPointMake(self.frame.size.width/2 + cosf(itemAngle) * self.radius,
									 self.frame.size.height/2 + sinf(itemAngle) * self.radius);
    GHMenuItemLocation *location = [GHMenuItemLocation new];
    location.position = itemCenter;
    location.angle = itemAngle;
    
    return location;
}
//本控件和父视图的角度
- (CGFloat) itemAngleAtIndex:(NSUInteger) index
{
    float bearingRadians = [self angleBeweenStartinPoint:self.center endingPoint:self.superview.center];
    
    CGFloat angle =  bearingRadians - self.arcAngle/2;
    
	CGFloat itemAngle = angle + (index * self.angleBetweenItems);
    
    if (itemAngle > 2 *M_PI) {
        itemAngle -= 2*M_PI;
    }else if (itemAngle < 0){
        itemAngle += 2*M_PI;
    }

    return itemAngle;
}

# pragma mark - helper methiods
//起始点和目标点的角度
- (CGFloat) angleBeweenStartinPoint:(CGPoint) startingPoint endingPoint:(CGPoint) endingPoint
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y);
    float bearingRadians = atan2f(originPoint.y, originPoint.x);
    
    bearingRadians = (bearingRadians > 0.0 ? bearingRadians : (M_PI*2 + bearingRadians));

    return bearingRadians;
}
//星按钮点按触发事件
-(void)smallBtnPress:(UIButton *)btn
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didSelectItemAtIndex:ContextMenuView:)]) {
        [self.delegate didSelectItemAtIndex:btn.tag ContextMenuView:self];
    }
    [self hideMenu];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([super pointInside:point withEvent:event]) {
        return YES;
    }else{
        if (self.isShowing) {
            for (UIButton *btn in self.menuItems) {
                CGPoint myPoint = [self convertPoint:point toView:btn];
                if ([btn pointInside:myPoint withEvent:event]) {
                    return YES;
                }
            }
            return NO;
        }else{
            return NO;
        }
    }
}

@end

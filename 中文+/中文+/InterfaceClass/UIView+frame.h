//
//  UIView+frame.h
//  聚城生活
//
//  Created by 李巍 on 14-1-9.
//  Copyright (c) 2014年 李巍. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (frame)

-(void)setX:(CGFloat)x;
-(CGFloat)getX;
-(void)setY:(CGFloat)y;
-(CGFloat)getY;
-(void)setwidth:(CGFloat)width;
-(CGFloat)getwidth;
-(void)setheight:(CGFloat)height;
-(CGFloat)getheight;
-(CGFloat)getBottom;
-(CGFloat)getRight;
+ (NSString *)printHierachy:(UIView *)v level:(int)aLevelIndex;
+(NSMutableArray *)getViewByClass:(Class)mainClass inView:(UIView *)mainView;
@end

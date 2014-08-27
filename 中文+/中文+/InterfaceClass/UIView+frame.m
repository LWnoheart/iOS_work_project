//
//  UIView+frame.m
//  聚城生活
//
//  Created by 李巍 on 14-1-9.
//  Copyright (c) 2014年 李巍. All rights reserved.
//

#import "UIView+frame.h"

@implementation UIView (frame)

-(void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
-(CGFloat)getX
{
    return self.frame.origin.x;
}
-(void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
-(CGFloat)getY
{
    return self.frame.origin.y;
}
-(void)setwidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
-(CGFloat)getwidth
{
    return self.frame.size.width;
}
-(void)setheight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
-(CGFloat)getheight
{
    return self.frame.size.height;
}
-(CGFloat)getBottom
{
    return ([self getY]+[self getheight]);
}
-(CGFloat)getRight
{
    return ([self getX]+[self getwidth]);
}



+ (NSString *)printHierachy:(UIView *)v level:(int)aLevelIndex
{
    NSString *space = @"";
    for (int i = 0; i < aLevelIndex; ++i)
    {
        space = [NSString stringWithFormat:@"%@  ", space];
    }
    NSString *desc = [NSString stringWithFormat:@"\n%@%@%@%x", space, v.class,NSStringFromCGRect(v.frame),(int)v];
    NSString *allsubdesc = @"";
    for (UIView *sub in v.subviews)
    {
        NSString *subdesc = [self printHierachy:sub level:aLevelIndex + 1];
        allsubdesc = [NSString stringWithFormat:@"%@%@", allsubdesc, subdesc];
    }
    return [NSString stringWithFormat:@"%@%@", desc, allsubdesc];
}

+(NSMutableArray *)getViewByClass:(Class)mainClass inView:(UIView *)mainView
{
    NSMutableArray *muArray = [[NSMutableArray alloc]init];
    for (UIView *view in mainView.subviews) {
        if ([view isKindOfClass:mainClass]) {
            [muArray addObject:view];
        }
        [muArray addObjectsFromArray:[self getViewByClass:mainClass inView:view]];
    }
    return muArray;
}
@end

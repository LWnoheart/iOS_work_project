//
//  LWHelpView.m
//  中文+
//
//  Created by tangce on 14-8-25.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "LWHelpView.h"
#import "AppDelegate.h"
@interface LWHelpView ()

@end

@implementation LWHelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = [UIScreen mainScreen].bounds;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 5465318;
        [_cancelButton addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _cancelButton = btn;
    }
    return self;
}
-(void)setHelpPictureArray:(NSArray *)pictureArray
{
    for (UIView *view in self.subviews) {
        if (view.tag != 5465318) {
            [view removeFromSuperview];
        }
    }
    self.contentOffset = CGPointMake(0, 0);
    CGRect frame = [UIScreen mainScreen].bounds;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        frame.size.height = frame.size.height-20;
    }
    self.contentSize = CGSizeMake(frame.size.width*pictureArray.count, frame.size.height);
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.bounces = NO;
    for (int i = 0; i<pictureArray.count; i++) {
        if (![[pictureArray objectAtIndex:i]isKindOfClass:[UIImage class]]) {
            NSLog(@"help image error!");
            return;
        }
        frame.origin.x = frame.size.width*i;
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:frame];
        imageview.image = [pictureArray objectAtIndex:i];
        [self addSubview:imageview];
        if (i == pictureArray.count-1) {
            if (self.cancelButtonFrame.size.width!=0) {
                CGRect btnframe = self.cancelButtonFrame;
                btnframe.origin.x = btnframe.origin.x + (frame.size.width *i);
                _cancelButton.frame = btnframe;
            }else{
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonPress:)];
                [imageview addGestureRecognizer:tap];
                imageview.userInteractionEnabled = YES;
            }
        }
    }
    AppDelegate *apl = [UIApplication sharedApplication].delegate;
    [apl.window addSubview:self];
}



-(void)buttonPress:(UIButton *)btn
{
    [UIView animateWithDuration:0.4f animations:^(){
        CGRect frame = self.frame;
        frame.origin.x = -frame.size.width;
        self.frame = frame;
    }completion:^(BOOL ber){
        [self removeFromSuperview];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

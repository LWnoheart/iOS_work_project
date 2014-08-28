//
//  ScanWelcomeView.m
//  技术攻关
//
//  Created by tangce on 14-8-28.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "ScanWelcomeView.h"
#import <MediaPlayer/MediaPlayer.h>
@interface ScanWelcomeView (){
    __weak UIImageView *_topView;
    __weak UIImageView *_bottomView;
}

@end

@implementation ScanWelcomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *image1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 300, 768, 724)];
        image1.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"h1004-bot" ofType:@"png"]];
        image1.userInteractionEnabled = YES;
        [self addSubview:image1];
        _bottomView = image1;
        
        UIImageView *image2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 768, 408)];
        image2.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"h1004-top" ofType:@"png"]];
        [self addSubview:image2];
        _topView = image2;
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(63, 505, 220, 100);
        btn1.tag = 101;
        [btn1 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"btnn1" ofType:@"png"]] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [image1 addSubview:btn1];
        
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.frame = CGRectMake(284, 505, 220, 100);
        btn2.tag = 102;
        [btn2 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"btnn2" ofType:@"png"]] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [image1 addSubview:btn2];
        
        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn3.frame = CGRectMake(510, 505, 220,100);
        btn3.tag = 103;
        [btn3 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"btnn3" ofType:@"png"]] forState:UIControlStateNormal];
        [btn3 addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [image1 addSubview:btn3];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void)buttonPress:(UIButton *)btn
{
    if (btn.tag == 102) {
//        NSString *moviePath = [NSString stringWithFormat:@""];
//        
//        MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL fileURLWithPath:moviePath]];
//        moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//        moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
//        moviePlayer.backgroundView.backgroundColor = [UIColor colorWithRed:239/255.f green:239/255.f blue:239/255.f alpha:1];
//        [moviePlayer prepareToPlay];
////        [moviePlayer.view setFrame:CGRectMake(0, 0, 0, 0)];
//        [self addSubview:moviePlayer.view];
//        [moviePlayer play];
    }else{
        if (btn.tag == 101) {
            SetObject(@"OK", @"firstScan");
        }
        CGRect topframe = _topView.frame;
        CGRect bottomframe = _bottomView.frame;
        topframe.origin.y = -topframe.size.height;
        bottomframe.origin.y = bottomframe.origin.y+bottomframe.size.height;
        [UIView animateWithDuration:0.5f animations:^(){
            _topView.frame = topframe;
            _bottomView.frame = bottomframe;
        }completion:^(BOOL ber){
            if (self.delegate&&[self.delegate respondsToSelector:@selector(ScanWelcomeViewRemoveFromSuperview)]) {
                [self.delegate ScanWelcomeViewRemoveFromSuperview];
            }
            [self removeFromSuperview];
        }];
    }
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

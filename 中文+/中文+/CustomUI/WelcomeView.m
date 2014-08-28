//
//  WelcomeView.m
//  技术攻关
//
//  Created by tangce on 14-8-27.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "WelcomeView.h"
#import "LWPageControl.h"

@interface WelcomeView ()<UIScrollViewDelegate>{
    __weak LWPageControl *_pageControl;
}

@end
@implementation WelcomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"bg" ofType:@"png"]];
        [self addSubview:imageView];
        //
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        scrollView.contentSize = CGSizeMake(frame.size.width*3, frame.size.height);
        scrollView.pagingEnabled = YES;
        scrollView.bounces = YES;
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        for (int i = 0; i < 3; i++) {
            UIImageView *scrollImage = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width*i, 0, frame.size.width, frame.size.height)];
            NSString *imageName = [NSString stringWithFormat:@"img%d",i+1];
            scrollImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:imageName ofType:@"png"]];
            [scrollView addSubview:scrollImage];
            if (i == 2) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
                scrollImage.userInteractionEnabled = YES;
                [scrollImage addGestureRecognizer:tap];
            }
        }
        [self addSubview:scrollView];
        LWPageControl *pageControl = [[LWPageControl alloc]initWithFrame:CGRectMake(275, 870, 300, 50) selectedImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"btn" ofType:@"png"]] unSelectedImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"btn-focus" ofType:@"png"]]];
//        pageControl.canTouch = YES;
        pageControl.numberOfPages = 3;
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x<scrollView.frame.size.width/2) {
        _pageControl.currentPage = 0;
    }else if (scrollView.contentOffset.x>scrollView.frame.size.width/2&&scrollView.contentOffset.x<scrollView.frame.size.width*1.5){
        _pageControl.currentPage = 1;
    }else if (scrollView.contentOffset.x>scrollView.frame.size.width*1.5){
        _pageControl.currentPage = 2;
    }
}


-(void)tapAction:(UITapGestureRecognizer *)tap
{
    CGRect frame = self.frame;
    frame.origin.x = -frame.size.width;
    [UIView animateWithDuration:0.4f animations:^(){
        self.frame = frame;
    }completion:^(BOOL ber){
        SetObject(@"OK", @"firstLaunch");
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

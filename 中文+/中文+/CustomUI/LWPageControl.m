//
//  LWPageControl.m
//  技术攻关
//
//  Created by tangce on 14-8-27.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "LWPageControl.h"


@interface LWPageControl ()
@property (nonatomic,strong) UIImage *selectedImage;
@property (nonatomic,strong) UIImage *unSelectedImage;
@property (nonatomic,strong) NSMutableArray *pagArray;
@end
@implementation LWPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pagArray = [[NSMutableArray alloc]init];
        self.canTouch = NO;
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame selectedImage:(UIImage *)selectedImage unSelectedImage:(UIImage *)unSelectedImage
{
    self = [self initWithFrame:frame];
    if (self) {
        self.selectedImage = selectedImage;
        self.unSelectedImage = unSelectedImage;
    }
    return self;
}
-(void)layoutSubviews
{
    _currentPage = -1;
    [self.pagArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.pagArray removeAllObjects];
    float widthTemp = (self.frame.size.width-self.frame.size.height)/_numberOfPages;
    for (int i = 0; i < _numberOfPages; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(widthTemp*i, 0, self.frame.size.height, self.frame.size.height);
        [btn setBackgroundImage:self.unSelectedImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(pagePress:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [self addSubview:btn];
        [self.pagArray addObject:btn];
    }
    self.currentPage = 0;
}

-(void)setCurrentPage:(NSInteger)currentPage
{
    if (currentPage<self.numberOfPages&&currentPage!=_currentPage) {
        if (_currentPage>=0) {
            UIButton *lastBtn = [self.pagArray objectAtIndex:_currentPage];
            [lastBtn setBackgroundImage:self.unSelectedImage forState:UIControlStateNormal];
        }
        UIButton *nowBtn = [self.pagArray objectAtIndex:currentPage];
        [nowBtn setBackgroundImage:self.selectedImage forState:UIControlStateNormal];
        _currentPage = currentPage;
    }
}


-(void)pagePress:(UIButton *)btn
{
    if (self.canTouch) {
        self.currentPage = btn.tag;
    }
}

-(void)setNumberOfPages:(NSInteger)numberOfPages
{
    if (numberOfPages!=_numberOfPages) {
        _numberOfPages = numberOfPages;
//        [self setNeedsLayout];
        [self layoutIfNeeded];
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

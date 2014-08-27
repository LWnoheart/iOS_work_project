//
//  BookCaseBG.m
//  中文+
//
//  Created by tangce on 14-7-1.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "BookCaseBG.h"

@implementation BookCaseBG

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"bookCaseDrawer" ofType:@"png"]];
        [self addSubview:imageView];
    }
    return self;
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

//
//  LWPageControl.h
//  技术攻关
//
//  Created by tangce on 14-8-27.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWPageControl : UIView
-(id)initWithFrame:(CGRect)frame selectedImage:(UIImage *)selectedImage unSelectedImage:(UIImage *)unSelectedImage;
@property (nonatomic,assign) NSInteger numberOfPages;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign) BOOL canTouch;
@end

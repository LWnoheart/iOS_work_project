//
//  LWHelpView.h
//  中文+
//
//  Created by tangce on 14-8-25.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWHelpView : UIScrollView

@property (nonatomic,assign) CGRect cancelButtonFrame;
@property (nonatomic,weak,readonly) UIButton *cancelButton;
-(void)setHelpPictureArray:(NSArray *)pictureArray;

@end

//
//  ScanWelcomeView.h
//  技术攻关
//
//  Created by tangce on 14-8-28.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanWelcomeViewDelegate <NSObject>

-(void)ScanWelcomeViewRemoveFromSuperview;

@end

@interface ScanWelcomeView : UIView
@property (nonatomic,weak) id<ScanWelcomeViewDelegate>delegate;
@end

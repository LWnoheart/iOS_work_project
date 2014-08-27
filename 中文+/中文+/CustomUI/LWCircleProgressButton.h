//
//  LWCircleProgressButton.h
//  技术攻关
//
//  Created by tangce on 14-8-25.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWCircleProgressButton : UIButton
/**
 * Progress (0.0 to 1.0)
 */
@property (nonatomic, assign) float progress;

/**
 * Indicator progress color.
 * Defaults to white [UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *progressTintColor;

/**
 * Indicator background (non-progress) color.
 * Defaults to translucent white (alpha 0.1)
 */
@property (nonatomic, strong) UIColor *backgroundTintColor;

/*
 * Display mode - NO = round or YES = annular. Defaults to round.
 */
@property (nonatomic, assign, getter = isAnnular) BOOL annular;
@end

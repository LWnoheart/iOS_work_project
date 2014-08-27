//
//  LWSelectTagView.h
//  聚城生活
//
//  Created by 李巍 on 13-12-24.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol LWSelectTagViewDelegate;

@interface LWSelectTagView : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) UIImage *selectImage;
@property (nonatomic, strong) UIImage *unSelectImage;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong) UIFont *textfont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, weak) id <LWSelectTagViewDelegate> delegate;
@end


@protocol LWSelectTagViewDelegate <NSObject>

-(void)LWSelectTagViewTriggerSelect:(LWSelectTagView *)view;

@end
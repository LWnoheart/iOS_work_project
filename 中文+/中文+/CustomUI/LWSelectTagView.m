//
//  LWSelectTagView.m
//  聚城生活
//
//  Created by 李巍 on 13-12-24.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import "LWSelectTagView.h"

#define GAP_OF_IMAGE_LABEL 4.0f

@interface LWSelectTagView (){
    UIImageView *_imageView;
}

@end



@implementation LWSelectTagView

- (id)initWithFrame:(CGRect)frame
{
    if (frame.size.width+GAP_OF_IMAGE_LABEL<frame.size.height) {
        return nil;
    }
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _selected = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap.numberOfTapsRequired = 1;
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap1.numberOfTapsRequired = 1;
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
        _imageView.userInteractionEnabled = YES;
        [_imageView addGestureRecognizer:tap];
        [self addSubview:_imageView];
        
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.height+GAP_OF_IMAGE_LABEL, 0, frame.size.width-frame.size.height-GAP_OF_IMAGE_LABEL, frame.size.height)];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.userInteractionEnabled = YES;
        [_textLabel addGestureRecognizer:tap1];
        [self addSubview:_textLabel];
    }
    return self;
}


-(void)tapAction:(UITapGestureRecognizer *)tap
{
    if (self.selected) {
        self.selected = NO;
    }else{
        self.selected = YES;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(LWSelectTagViewTriggerSelect:)]) {
        [self.delegate LWSelectTagViewTriggerSelect:self];
    }
}


-(void)setSelected:(BOOL)selected
{
    if (selected) {
        _imageView.image = self.selectImage;
    }else{
        _imageView.image = self.unSelectImage;
    }
    _selected = selected;
}

-(void)setSelectImage:(UIImage *)selectImage
{
    _selectImage = selectImage;
    if (self.selected) {
        _imageView.image = selectImage;
    }
}

-(void)setUnSelectImage:(UIImage *)unSelectImage
{
    _unSelectImage = unSelectImage;
    if (!self.selected) {
        _imageView.image = unSelectImage;
    }
}

-(void)setText:(NSString *)text
{
    _textLabel.text = text;
    _text = text;
}

-(void)setTextColor:(UIColor *)textColor
{
    _textLabel.textColor = textColor;
    _textColor = textColor;
}

-(void)setTextfont:(UIFont *)textfont
{
    _textLabel.font = textfont;
    _textfont = textfont;
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

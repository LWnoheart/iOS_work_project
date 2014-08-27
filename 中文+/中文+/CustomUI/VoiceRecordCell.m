//
//  VoiceRecordCell.m
//  中文+
//
//  Created by tangce on 14-8-11.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "VoiceRecordCell.h"

@implementation VoiceRecordCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 768, 100)];
        imageview.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"collectCellBackground" ofType:@"png"]];
        [self.contentView addSubview:imageview];
        
        UIImageView *textImageview = [[UIImageView alloc]initWithFrame:CGRectMake(64, 10, 520, 70)];
        textImageview.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"textBackground" ofType:@"png"]];
        [self.contentView addSubview:textImageview];
        textBGImageview = textImageview;
        
        self.voiceNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 350, 30)];
        self.voiceNameLabel.backgroundColor = [UIColor clearColor];
        self.voiceNameLabel.font = UIFONT(20);
        [self.contentView addSubview:self.voiceNameLabel];
        
        self.bookNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 50, 150, 20)];
        self.bookNameLabel.backgroundColor = [UIColor clearColor];
        self.bookNameLabel.font = UIFONT(14);
        self.bookNameLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.bookNameLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(250, 50, 150, 20)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = UIFONT(14);
        self.timeLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.timeLabel];
        
        self.smallLabel = [[UILabel alloc]initWithFrame:CGRectMake(430, 50, 150, 20)];
        self.smallLabel.backgroundColor = [UIColor clearColor];
        self.smallLabel.font = UIFONT(14);
        self.smallLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.smallLabel];
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(590, 15, 54, 65);
        btn1.tag = 1;
        [btn1 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"playe" ofType:@"png"]] forState:UIControlStateNormal];
        [btn1 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"playTD" ofType:@"png"]] forState:UIControlStateHighlighted];
        [btn1 addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn1];
        playBtn = btn1;
        
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.frame = CGRectMake(650, 15, 54, 65);
        btn2.tag = 2;
        [btn2 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"smallBook" ofType:@"png"]] forState:UIControlStateNormal];
        [btn2 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"smallBookTD" ofType:@"png"]] forState:UIControlStateHighlighted];
        [btn2 addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn2];
        bookBtn = btn2;
        
//        self.contentView.backgroundColor = [UIColor colorWithRed:251/255.f green:251/255.f blue:251/255.f alpha:1.0f];
        
        
        [self.voiceNameLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        if (self.voiceNameLabel.text) {
            textBGImageview.hidden = NO;
            playBtn.hidden = NO;
            bookBtn.hidden = NO;
        }else{
            textBGImageview.hidden = YES;
            playBtn.hidden = YES;
            bookBtn.hidden = YES;
        }
    }
}
-(void)buttonPress:(UIButton *)btn
{
    if (btn.tag == 1) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(VoiceRecordCellPlay:)]) {
            [self.delegate performSelector:@selector(VoiceRecordCellPlay:) withObject:self];
        }
    }else if (btn.tag == 2){
        if (self.delegate&&[self.delegate respondsToSelector:@selector(VoiceRecordCellBook:)]) {
            [self.delegate performSelector:@selector(VoiceRecordCellBook:) withObject:self];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)dealloc
{
    [self.voiceNameLabel removeObserver:self forKeyPath:@"text" context:nil];
}
@end

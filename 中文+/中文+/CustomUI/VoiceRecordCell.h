//
//  VoiceRecordCell.h
//  中文+
//
//  Created by tangce on 14-8-11.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol VoiceRecordCellDelegate;

@interface VoiceRecordCell : UITableViewCell
{
    __weak UIImageView *textBGImageview;
    __weak UIButton *playBtn;
    __weak UIButton *bookBtn;
}
@property (nonatomic,strong) UILabel *voiceNameLabel;
@property (nonatomic,strong) UILabel *bookNameLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *smallLabel;
@property (nonatomic,weak) id <VoiceRecordCellDelegate> delegate;
@end


@protocol VoiceRecordCellDelegate <NSObject>

-(void)VoiceRecordCellPlay:(id)VRCell;
-(void)VoiceRecordCellBook:(id)VRCell;

@end
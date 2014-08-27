//
//  PageVoiceView.h
//  中文+
//
//  Created by tangce on 14-8-7.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "VoiceCollectData.h"
@interface PageVoiceView : UIView

@property (nonatomic,strong)AVAudioPlayer *audioPlayer;

-(id)initWithFrame:(CGRect)frame rootPath:(NSString *)rootPath pageIndex:(NSInteger)pageIndex json:(NSDictionary *)jsonDic;
-(id)initWithFrame:(CGRect)frame voiceData:(VoiceCollectData *)voiceData;
-(id)initWithFrame:(CGRect)frame path:(NSString *)path;
@end

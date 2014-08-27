//
//  VoiceRecordViewController.h
//  中文+
//
//  Created by tangce on 14-8-11.
//  Copyright (c) 2014年 tangce. All rights reserved.
//


#import "LWvcWithTableview.h"

typedef NS_ENUM(NSInteger, RecordControllerStyle) {
    RecordControllerStyleReaded,
    RecordControllerStyleCollect,
    RecordControllerStyleFollow
};

@interface VoiceRecordViewController :LWvcWithTableview
@property (nonatomic,assign)RecordControllerStyle style;
@end

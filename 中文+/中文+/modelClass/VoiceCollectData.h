//
//  VoiceCollectData.h
//  中文+
//
//  Created by tangce on 14-8-7.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceCollectData : NSObject

@property (nonatomic,strong) NSString *path;
@property (nonatomic,strong) NSString *bookName;
@property (nonatomic,assign) NSInteger bookID;
@property (nonatomic,assign) NSInteger voiceID;
@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) NSDate *readDate;
@property (nonatomic,assign) NSInteger pageIndex;
@property (nonatomic,strong) NSString *bookPath;

@property (nonatomic,strong) NSString *splicePath;

@property (nonatomic,assign) NSInteger readCount;

@end

//
//  RecordManager.h
//  中文+
//
//  Created by tangce on 14-7-4.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol RecordManagerDelegate;

@interface RecordManager : NSObject

@property (nonatomic,strong,readonly) NSString *currentRecordPath;
@property (nonatomic, weak) id <RecordManagerDelegate> delegate;
@property (nonatomic,assign,readonly) BOOL isRecord;
@property (nonatomic,assign) BOOL useVoiceDetection;
+(RecordManager *)defaultManager;

-(void)startRecordVoiceToPath:(NSString *)path;
-(BOOL)stopRecordVoive;
-(void)removeRecordVoiceByPath:(NSString *)path;


-(void) exportSyntheticAudioM4AByPath:(NSString *)path1 Path:(NSString *)path2 outPath:(NSString *)outPath complete:(void (^)(void))handler;

-(void)splicingVoiceByPath:(NSString *)path1 path:(NSString *)path2 outPath:(NSString *)outPath;
@end

@protocol RecordManagerDelegate <NSObject>

-(void)recordVoiceDetection:(double )lowPassResults;

@end
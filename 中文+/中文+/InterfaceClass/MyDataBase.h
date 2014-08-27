//
//  MyDataBase.h
//  eduNet
//
//  Created by 李巍 on 13-5-28.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "VoiceCollectData.h"
@interface MyDataBase : NSObject
{
    sqlite3 *database;
    sqlite3 *cacheSqlite;
}

+ (MyDataBase *)shareMyDataBase;
- (void)openSqlite;
- (BOOL)creatForm;


-(void)saveCollectVoice:(VoiceCollectData *)voiceData;
-(BOOL)whetherDatabaseHaveCollect:(VoiceCollectData *)voiceData;
-(void)deleteCollectVoice:(VoiceCollectData *)voiceData;
-(NSArray *)getCollectVoiceFrom:(NSInteger)from to:(NSInteger)to;

-(void)saveReadedVoice:(VoiceCollectData *)voiceData;
-(NSArray *)getReadedVoiceFrom:(NSInteger)from to:(NSInteger)to;

-(void)saveSpliceVoice:(VoiceCollectData *)voiceData;
-(NSArray *)getSpliceVoiceFrom:(NSInteger)from to:(NSInteger)to;
-(NSArray *)getSpliceVoiceByVoiceID:(NSInteger)voiceID;

-(void)saveCacheWithData:(NSString *)cacheData cacheKey:(NSString *)key;
-(NSString *)getCacheDataWithCacheKey:(NSString *)key;
-(BOOL)canFindTheValueWithCacheKey:(NSString *)key useTime:(BOOL)use;
-(void)deleteCacheWithKey:(NSString *)key;
-(void)deleteCacheLikeKey:(NSString *)key;
- (void)closeSqlite;

@end

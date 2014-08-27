//
//  MyDataBase.m
//  eduNet
//
//  Created by 李巍 on 13-5-28.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import "MyDataBase.h"

@implementation MyDataBase
#pragma mark creatSQlite
+(MyDataBase *)shareMyDataBase
{
    static MyDataBase *myDB = nil;
    if (!myDB) {
        myDB = [[MyDataBase alloc]init];
        [myDB openSqlite];
        [myDB creatForm];
    }
    return myDB;
}


-(void)openSqlite
{
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
    NSLog(@"%@",documentsPaths);
    //创建下载目录
    if (sqlite3_open([databaseFilePath UTF8String], &database)==SQLITE_OK) {
    }
    NSArray *Paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath=[[Paths objectAtIndex:0] stringByAppendingPathComponent:@"cacheDate"];
    if (sqlite3_open([cachePath UTF8String], &cacheSqlite)==SQLITE_OK) {
    }
}


-(BOOL)creatForm
{
    BOOL ber;
    char *errorMsg;
    //收藏
    NSString *sqliteStr = [NSString stringWithFormat:@"create table if not exists collectData (path varchar,bookName varchar,name varchar,bookPath varchar,pageIndex INTEGER,bookID INTEGER,voiceID INTEGER)"];
    if (sqlite3_exec(database, [sqliteStr UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        NSLog(@"create collectTable ok.");
        ber = YES;
    }else {
        NSLog(@"error: %s",errorMsg);
        sqlite3_free(errorMsg);
        ber = NO;
    }
    //朗读记录
    NSString *readSqliteStr = [NSString stringWithFormat:@"create table if not exists readData (readDate varchar,path varchar,bookName varchar,name varchar,bookPath varchar,pageIndex INTEGER,bookID INTEGER,voiceID INTEGER,id INTEGER PRIMARY KEY AUTOINCREMENT)"];
    if (sqlite3_exec(cacheSqlite, [readSqliteStr UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        NSLog(@"create readDataTable ok.");
        ber = YES;
    }
    
    //跟读-音频合并splice
    NSString *spliceSqliteStr = [NSString stringWithFormat:@"create table if not exists spliceData (splicePath varchar,path varchar,bookName varchar,name varchar,bookPath varchar,pageIndex INTEGER,bookID INTEGER,voiceID INTEGER,readDate varchar,id INTEGER PRIMARY KEY AUTOINCREMENT)"];
    if (sqlite3_exec(cacheSqlite, [spliceSqliteStr UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        NSLog(@"create spliceTable ok.");
        ber = YES;
    }
    
    
    
    //缓存
    NSString *cacheSql = [NSString stringWithFormat:@"create table if not exists cache (date text,valueData text,key text)"];
    if (sqlite3_exec(cacheSqlite, [cacheSql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        NSLog(@"create cache ok.");
    }
    
    sqlite3_free(errorMsg);
    return ber;
}

#pragma mark ----------------------------------
#pragma mark CollectSQlite

-(BOOL)whetherDatabaseHaveCollect:(VoiceCollectData *)voiceData
{
//    NSString *selectSqliteStr = [NSString stringWithFormat:@"select * from collectData where path = '%@' and bookName = '%@' and name = '%@' and bookID = %d and voiceID = %d",voiveData.path,voiveData.bookName,voiveData.name,voiveData.bookID,voiveData.voiceID];
    NSString *selectSqliteStr = [NSString stringWithFormat:@"select * from collectData where voiceID = %d",voiceData.voiceID];
    
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(database, [selectSqliteStr UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *path = [[NSString alloc]initWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            if (path) {
                return YES;
            }else{
                NSLog(@"no");
                return NO;
            }
        }
    }
    return NO;
}



-(void)saveCollectVoice:(VoiceCollectData *)voiceData
{
    char *errorMsg;
    NSString *insertSqliteStr = [NSString stringWithFormat:@"insert into collectData (path,bookName,name,bookPath,pageIndex,bookID,voiceID) values('%@','%@','%@','%@',%d,%d,%d)",voiceData.path,voiceData.bookName,voiceData.name,voiceData.bookPath,voiceData.pageIndex,voiceData.bookID,voiceData.voiceID];
    
    if (sqlite3_exec(database, [insertSqliteStr UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        
    }else {
        NSLog(@"insert collection fail with reseaon:%s",errorMsg);
        sqlite3_free(errorMsg);
    }
}


-(void)deleteCollectVoice:(VoiceCollectData *)voiceData
{
    char *errorMsg;
//    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM collectData where path = '%@' and bookName = '%@' and name = '%@' and bookID = %d and voiceID = %d",voiveData.path,voiveData.bookName,voiveData.name,voiveData.bookID,voiveData.voiceID];
    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM collectData where voiceID = %d",voiceData.voiceID];
    if (sqlite3_exec(database, [sqlStr UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK){
        
    }else{
        sqlite3_free(errorMsg);
    }
}

-(NSArray *)getCollectVoiceFrom:(NSInteger)from to:(NSInteger)to
{
    NSString *selectSQL = [NSString stringWithFormat:@"select * from collectData limit %d,%d",from,to];
    sqlite3_stmt *statement;
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            VoiceCollectData *readData = [[VoiceCollectData alloc]init];
            readData.path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            readData.bookName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            readData.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            readData.bookPath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            readData.pageIndex = sqlite3_column_int(statement, 4);
            readData.bookID = sqlite3_column_int(statement, 5);
            readData.voiceID = sqlite3_column_int(statement, 6);
            [dataArray addObject:readData];
        }
    }
    return dataArray;
}

#pragma mark ----------------------------------
#pragma mark readedSQlite

-(void)saveReadedVoice:(VoiceCollectData *)voiceData
{
    char *errorMsg;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *insertSqliteStr = [NSString stringWithFormat:@"insert into readData (readDate,path,bookName,name,bookPath,pageIndex,bookID,voiceID) values('%@','%@','%@','%@','%@',%d,%d,%d)",[formatter stringFromDate:voiceData.readDate],voiceData.path,voiceData.bookName,voiceData.name,voiceData.bookPath,voiceData.pageIndex,voiceData.bookID,voiceData.voiceID];
    
    if (sqlite3_exec(cacheSqlite, [insertSqliteStr UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        
    }else {
        NSLog(@"insert readData fail with reseaon:%s",errorMsg);
        sqlite3_free(errorMsg);
    }
}

-(NSArray *)getReadedVoiceFrom:(NSInteger)from to:(NSInteger)to
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *selectSQl = [NSString stringWithFormat:@"select bookName,bookID,name,path,readDate,voiceID,bookPath,pageIndex,count(bookID) from readData group by voiceID order by id desc limit %d,%d",from,to];
    sqlite3_stmt *statement;
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(cacheSqlite, [selectSQl UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            VoiceCollectData *readData = [[VoiceCollectData alloc]init];
            readData.bookName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            readData.bookID = sqlite3_column_int(statement, 1);
            readData.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            readData.path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            readData.readDate = [formatter dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)]];
            readData.voiceID = sqlite3_column_int(statement, 5);
            readData.bookPath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 6)];
            readData.pageIndex = sqlite3_column_int(statement, 7);
            readData.readCount = sqlite3_column_int(statement, 8);
            [dataArray addObject:readData];
        }
    }
    return dataArray;
    
}

#pragma mark ----------------------------------
#pragma mark spliceSQlite
-(void)saveSpliceVoice:(VoiceCollectData *)voiceData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    char *errorMsg;
    NSString *insertSqliteStr = [NSString stringWithFormat:@"insert into spliceData (splicePath,path,bookName,name,bookPath,pageIndex,bookID,voiceID,readDate) values('%@','%@','%@','%@','%@',%d,%d,%d,'%@')",voiceData.splicePath,voiceData.path,voiceData.bookName,voiceData.name,voiceData.bookPath,voiceData.pageIndex,voiceData.bookID,voiceData.voiceID,[formatter stringFromDate:voiceData.readDate]];
    
    if (sqlite3_exec(cacheSqlite, [insertSqliteStr UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        
    }else {
        NSLog(@"insert readData fail with reseaon:%s",errorMsg);
        sqlite3_free(errorMsg);
    }
}

-(NSArray *)getSpliceVoiceFrom:(NSInteger)from to:(NSInteger)to
{
    NSString *selectSQl = [NSString stringWithFormat:@"select splicePath,path,bookName,name,bookPath,pageIndex,bookID,voiceID,count(bookID) from spliceData group by voiceID order by id desc limit %d,%d",from,to];
    sqlite3_stmt *statement;
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(cacheSqlite, [selectSQl UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            VoiceCollectData *readData = [[VoiceCollectData alloc]init];
            readData.splicePath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            readData.path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            readData.bookName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            readData.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            readData.bookPath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            readData.pageIndex = sqlite3_column_int(statement, 5);
            readData.bookID = sqlite3_column_int(statement, 6);
            readData.voiceID = sqlite3_column_int(statement, 7);
            readData.readCount = sqlite3_column_int(statement, 8);
            [dataArray addObject:readData];
        }
    }
    return dataArray;
}

-(NSArray *)getSpliceVoiceByVoiceID:(NSInteger)voiceID
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSString *selectSqliteStr = [NSString stringWithFormat:@"select * from spliceData where voiceID = %d order by id desc",voiceID];
    sqlite3_stmt *statement;
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(cacheSqlite, [selectSqliteStr UTF8String], -1, &statement, nil)==SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            VoiceCollectData *readData = [[VoiceCollectData alloc]init];
            readData.splicePath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            readData.path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            readData.bookName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            readData.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
            readData.bookPath = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
            readData.pageIndex = sqlite3_column_int(statement, 5);
            readData.bookID = sqlite3_column_int(statement, 6);
            readData.voiceID = sqlite3_column_int(statement, 7);
            readData.readDate = [formatter dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)]];
            [dataArray addObject:readData];
        }
    }
    return dataArray;
}
#pragma mark ----------------------------------
#pragma mark cacheSQlite


-(void)saveCacheWithData:(NSString *)cacheData cacheKey:(NSString *)key
{
    char *errorMsg;
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSString *sqliteStr = [NSString stringWithFormat:@"insert into cache (date,valueData,key) values('%@','%@','%@')",dateStr,cacheData,key];
    if (sqlite3_exec(cacheSqlite, [sqliteStr UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        
    }else {
        NSLog(@"插错了");
        sqlite3_free(errorMsg);
    }
}

-(NSString *)getCacheDataWithCacheKey:(NSString *)key
{
    NSString *data = nil;
    NSString *sqliteStr = [NSString stringWithFormat:@"SELECT * FROM cache WHERE key =  '%@'",key];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(cacheSqlite, [sqliteStr UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *value = (char *)sqlite3_column_text(statement, 1);
            data = [[NSString alloc]initWithUTF8String:value];
        }
    }
    sqlite3_finalize(statement);
    return data;
}


-(BOOL)canFindTheValueWithCacheKey:(NSString *)key useTime:(BOOL)use
{
    BOOL booler = NO;
    NSString *sqliteStr = [NSString stringWithFormat:@"SELECT * FROM cache WHERE key =  '%@'",key];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(cacheSqlite, [sqliteStr UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *value
            = (char *)sqlite3_column_text(statement, 0);
            NSString *dateStr = [[NSString alloc]initWithUTF8String:value];
            if (dateStr) {
                if (use) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *date = [dateFormatter dateFromString:dateStr];
                    NSTimeInterval time = [[NSDate date]timeIntervalSinceDate:date];
                    if ((time/60)<60) {
                        booler = YES;
//                        NSLog(@"时间差是:%f",time);
                    }
                }else{
                    booler = YES;
                }
            }
         }
    }
    return booler;
}


-(void)deleteCacheWithKey:(NSString *)key
{
    char *errorMsg;
    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM cache where key='%@'",key];
    const char *sql = [sqlStr UTF8String];
    if (sqlite3_exec(cacheSqlite, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
    }
    else
    {
        sqlite3_free(errorMsg);
    }
}



-(void)deleteCacheLikeKey:(NSString *)key
{
    char *errorMsg;
    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM cache where key like '%%%@%%'",key];
    const char *sql = [sqlStr UTF8String];
    if (sqlite3_exec(cacheSqlite, sql, NULL, NULL, &errorMsg)==SQLITE_OK)
    {
    }
    else
    {
        sqlite3_free(errorMsg);
    }
}







#pragma mark ----------------------------------
-(void)closeSqlite
{
    sqlite3_close(database);
}

@end

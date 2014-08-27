//
//  AllHttpService.h
//  faces
//
//  Created by 李巍 on 13-4-27.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIProgressDelegate.h"
#import "NSString+KeyEncryption.h"

#define HTTPIMAGEURL @"http://117.121.56.21/tangcenes/upLoadFiles/%@"
//#define ORG_ID 3252360
@protocol AllHttpServiceDelegate <NSObject>

-(void)requestHaveChange;

@end






@interface AllHttpService : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>
@property (nonatomic, strong) NSMutableDictionary *requestDic;


@property (strong, nonatomic) NSMutableData *contentData;

@property (strong, nonatomic) NSArray *XmlArray;
@property (weak, nonatomic) id <AllHttpServiceDelegate> delegate;

+(AllHttpService *)sharedHttpService;

-(void) saveClass:(NSObject *)clazz completionHandler:(void(^)(NSDictionary *))handler;

-(void) saveClassArray:(NSArray *)clazzArray completionHandler:(void(^)(NSDictionary *))handler;

-(void) deleteClassArray:(NSArray *)clazzArray completionHandler:(void(^)(NSDictionary *))handler;

-(ASIHTTPRequest *) selectAllObjectToseletCode:(NSString *)seletSQL selectDictionary:(NSDictionary *)selectDic selectType:(int)selectType UseLazy:(BOOL)lazy objectClassName:(NSString *)clazzName completionHandler:(void(^)(NSArray *))handler1;

-(ASIHTTPRequest *) selectAllObjectToseletCode:(NSString *)seletSQL selectDictionary:(NSDictionary *)selectDic selectType:(int)selectType UseLazy:(BOOL)lazy UseCache:(BOOL)useCache objectClassName:(NSString *)clazzName completionHandler:(void(^)(NSArray *))handler1;

-(void)downLoadAttachmentWithURL:(NSString *)URLName path:(NSString *)pathName completionHandler:(void(^)(void))handler1;

-(void)UploadMemberPictureWithData:(NSData *)pictureData pictureName:(NSString *)pictureName completionHandler:(void (^)(NSDictionary *))handler;

-(NSString *)createCacheKeyfromSeletSql:(NSString *)seletSQL seletValue:(NSString *)valueStr useLazy:(BOOL)lazy;

-(BOOL)haveHttpService;

@end

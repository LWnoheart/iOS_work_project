//
//  AllHttpService.m
//  faces
//
//  Created by 李巍 on 13-4-27.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import "AllHttpService.h"
//#import "GDataXMLNode.h"
#import "NSObject+fanshe.h"
#import "ASIFormDataRequest.h"
#import "Reachability.h"
#import "MyDataBase.h"
#import "NSObject+MyMethod.h"
#define WILDCARDOFURL @"http://117.121.56.21/tangcenes/androidInterFace/"



//#define WILDCARDOFURL @"http://192.168.0.140:8080/testapp/androidInterFace/"







@implementation AllHttpService
static AllHttpService *service = nil;

+(AllHttpService *)sharedHttpService
{
    @synchronized(self){
        if(service == nil){
            service = [[AllHttpService alloc] init];
            service.requestDic = [[NSMutableDictionary alloc]init];
//            service.XmlArray = [service getXmlData];
        }
    }
    return service;
}

#pragma mark ----------------------------------
#pragma mark SAVE DATA

-(void)saveClass:(NSObject *)clazz completionHandler:(void (^)(NSDictionary *))handler
{
    NSMutableString *strURL = [NSMutableString stringWithFormat:WILDCARDOFURL];
    [strURL appendFormat:@"saveOrUpdateDomain"];
    if (![service haveHttpService]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查你的网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        });
    }else{
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:strURL]];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Accept-Language" value:@"zh-cn,zh;q=0.5"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:[self getClassDicFromclass:clazz] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [request setPostValue:json forKey:@"json"];
        [request setNumberOfTimesToRetryOnTimeout:2];
        [request startAsynchronous];
        __weak ASIHTTPRequest *requestWeak = request;
        [request setCompletionBlock:^(){
            NSData *final = [requestWeak responseData];
            NSDictionary *getData = [NSJSONSerialization JSONObjectWithData:final options:NSJSONReadingMutableLeaves error:nil];
//            BOOL result;
//            if ([[getData valueForKey:@"flag"]isEqualToString:@"true"]) {
//                result = YES;
//            }else{
//                result = NO;
//                NSLog(@"%@",getData);
//            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                if (handler) {
                    handler(getData);
                }
            });
        }];
    }
}




-(void) saveClassArray:(NSArray *)clazzArray completionHandler:(void (^)(NSDictionary *))handler
{
    NSMutableString *strURL = [NSMutableString stringWithFormat:WILDCARDOFURL];
    [strURL appendFormat:@"saveOrUpdateDomainArray"];
    if (![service haveHttpService]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查你的网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            handler(nil);
        });
    }else{
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:strURL]];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Accept-Language" value:@"zh-cn,zh;q=0.5"];
        [request setPostValue:[self getClassJsonStringFromArray:clazzArray] forKey:@"json"];
        [request setNumberOfTimesToRetryOnTimeout:2];
        [request startAsynchronous];
        __weak ASIHTTPRequest *requestWeak = request;
        [request setCompletionBlock:^(){
            NSData *final = [requestWeak responseData];
            NSDictionary *getData = [NSJSONSerialization JSONObjectWithData:final options:NSJSONReadingMutableLeaves error:nil];
//            BOOL result;
//            if ([[getData valueForKey:@"flag"]isEqualToString:@"true"]) {
//                result = YES;
//            }else{
//                result = NO;
//                NSLog(@"%@----%@",getData,[getData valueForKey:@"errors"]);
//            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                handler(getData);
            });
        }];
    }
}


-(NSString *)getClassJsonStringFromArray:(NSArray *)clazzArray
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSObject *clazz in clazzArray) {
        [array addObject:[self getClassDicFromclass:clazz]];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return json;
}

-(NSDictionary *)getClassDicFromclass:(NSObject *)clazz
{
    NSArray *property = [self getPropertyListAndPropertyType:[clazz class]];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < [[property objectAtIndex:0] count]; i++) {
        NSString *propertyName = [[property objectAtIndex:0]objectAtIndex:i];
        NSString *propertyType = [[property objectAtIndex:1]objectAtIndex:i];
        if ([propertyName isEqualToString:@"id"]&&[clazz valueForKey:propertyName]!=[NSNumber numberWithInt:0]) {
            [dic setValue:[clazz valueForKey:propertyName] forKey:propertyName];
        }else if ([propertyType hasPrefix:@"Mi"]){
            id value = [clazz valueForKeyPath:[NSString stringWithFormat:@"%@.id",propertyName]];
            if (value) {
                [dic setValue:[NSDictionary dictionaryWithObjectsAndKeys:value,@"id",[[self getClassXMlData:propertyType]valueForKey:@"classPath"],@"class", nil] forKey:propertyName];
            }else{
                [dic setValue:@"" forKey:propertyName];
            }
        
        }else if ([propertyType isEqualToString:@"NSDate"]){
            [dic setValue:[[[[clazz valueForKey:propertyName]description]substringToIndex:19]tureDateWithoutT] forKey:propertyName];
        }else if (![propertyName isEqualToString:@"id"]&&![propertyType hasPrefix:@"Mi"]&&![propertyType isEqualToString:@"NSDate"]){
            [dic setValue:[clazz valueForKey:propertyName] forKey:propertyName];
        }
    }
    [dic setValue:[[self getClassXMlData:NSStringFromClass([clazz class])]valueForKey:@"classPath"] forKey:@"class"];
    return dic;
}

#pragma mark ----------------------------------
#pragma mark DELETE DATA

-(void)deleteClassArray:(NSArray *)clazzArray completionHandler:(void (^)(NSDictionary *))handler
{
    NSMutableString *strURL = [NSMutableString stringWithFormat:WILDCARDOFURL];
    [strURL appendFormat:@"deleteDomainArray"];
    if (![service haveHttpService]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查你的网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        });
    }else{
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:strURL]];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Accept-Language" value:@"zh-cn,zh;q=0.5"];
        [request setPostValue:[self getClassJsonStringFromArray:clazzArray] forKey:@"json"];
        [request setNumberOfTimesToRetryOnTimeout:2];
        [request startAsynchronous];
        __weak ASIHTTPRequest *requestWeak = request;
        [request setCompletionBlock:^(){
            NSData *final = [requestWeak responseData];
            NSDictionary *getData = [NSJSONSerialization JSONObjectWithData:final options:NSJSONReadingMutableLeaves error:nil];
//            BOOL result;
//            if ([[getData valueForKey:@"flag"]isEqualToString:@"true"]) {
//                result = YES;
//            }else{
//                result = NO;
//                NSLog(@"%@----%@",getData,[getData valueForKey:@"errors"]);
//            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                handler(getData);
            });
        }];
    }
}







#pragma mark ----------------------------------
#pragma mark GET DATA


-(ASIHTTPRequest *) selectAllObjectToseletCode:(NSString *)seletSQL selectDictionary:(NSDictionary *)selectDic selectType:(int)selectType UseLazy:(BOOL)lazy objectClassName:(NSString *)clazzName completionHandler:(void(^)(NSArray *))handler1
{
    return [service selectAllObjectToseletCode:seletSQL selectDictionary:selectDic selectType:selectType UseLazy:lazy UseCache:YES objectClassName:clazzName completionHandler:handler1];
}




//block回调异步查询
-(ASIHTTPRequest *) selectAllObjectToseletCode:(NSString *)seletSQL selectDictionary:(NSDictionary *)selectDic selectType:(int)selectType UseLazy:(BOOL)lazy UseCache:(BOOL)useCache objectClassName:(NSString *)clazzName completionHandler:(void(^)(NSArray *))handler1
{
    ASIFormDataRequest *request = nil;
    
    NSMutableString *strURL = [NSMutableString stringWithFormat:WILDCARDOFURL];
    [strURL appendFormat:@"executeSql"];
    NSString *mapJsonStr = nil;
    if (selectDic&&[NSJSONSerialization isValidJSONObject:selectDic]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:selectDic options:NSJSONWritingPrettyPrinted error:nil];
        mapJsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *key = [service createCacheKeyfromSeletSql:seletSQL seletValue:mapJsonStr useLazy:lazy];
    
    if (![service haveHttpService]&&![[MyDataBase shareMyDataBase]canFindTheValueWithCacheKey:key useTime:NO]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查你的网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            handler1(nil);
        });
    }else if (![service haveHttpService]&&[[MyDataBase shareMyDataBase]canFindTheValueWithCacheKey:key useTime:NO]&&useCache){
        NSString *dataStr = [[MyDataBase shareMyDataBase]getCacheDataWithCacheKey:key];
        NSData *final = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *getData;
        if (final) {
            getData = [NSJSONSerialization JSONObjectWithData:final options:NSJSONReadingMutableLeaves error:nil];
        }
        NSArray *classArray;
        if (getData.count != 0) {
            classArray = [service getClassArrayFromReceivedArrayData:getData className:clazzName];
        }else{
            classArray = nil;
            NSLog(@"请求为空");
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            handler1(classArray);
        });
    }else if ([service haveHttpService]&&[[MyDataBase shareMyDataBase]canFindTheValueWithCacheKey:key useTime:YES]&&useCache){
        NSString *dataStr = [[MyDataBase shareMyDataBase]getCacheDataWithCacheKey:key];
        NSData *final = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *getData = [NSJSONSerialization JSONObjectWithData:final options:NSJSONReadingMutableLeaves error:nil];
        NSArray *classArray;
        if (getData.count != 0) {
            classArray = [service getClassArrayFromReceivedArrayData:getData className:clazzName];
        }else{
            classArray = nil;
            NSLog(@"请求为空");
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            handler1(classArray);
        });
    }else if ([service haveHttpService]&&(![[MyDataBase shareMyDataBase]canFindTheValueWithCacheKey:key useTime:YES]||!useCache)){
        request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:strURL]];
//        NSLog(@"%@",strURL);
        if (mapJsonStr) {
            [request setPostValue:mapJsonStr forKey:@"mapjson"];
        }else{
            [request setPostValue:@"{}" forKey:@"mapjson"];
        }
//        NSLog(@"%@",mapJsonStr);
        [request setPostValue:[NSString stringWithFormat:@"%d",selectType] forKey:@"selectType"];
        [request setPostValue:seletSQL forKey:@"seletCode"];
//        NSLog(@"%@",seletSQL);
        if (lazy) {
            NSDictionary *propertyDic = [[service getPropertyListAndPropertyType:NSClassFromString(clazzName)]objectAtIndex:2];
            NSArray *propertyArray = [[service getClassXMlData:clazzName]valueForKey:@"property"];
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (NSDictionary *dic in propertyArray) {
                [array addObject:[dic valueForKey:@"propertyName"]];
                NSMutableString *str = [[NSMutableString alloc]initWithString:[dic valueForKey:@"propertyName"]];
                for (NSDictionary *dic1 in [[self getClassXMlData:[propertyDic valueForKey:str]]valueForKey:@"property"]) {
                    if ([dic1 valueForKey:@"propertyName"]) {
                        NSMutableString *str2 = [[NSMutableString alloc]initWithString:str];
                        [str2 appendFormat:@"."];
                        [str2 appendString:[dic1 valueForKey:@"propertyName"]];
                        [array addObject:str2];
                    }
                }
            }
            if ([NSJSONSerialization isValidJSONObject:array]) {
                NSData *lazyData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
                NSString *lazyJson = [[NSString alloc]initWithData:lazyData encoding:NSUTF8StringEncoding];
                [request setPostValue:lazyJson forKey:@"lazy"];
//                NSLog(@"%@",lazyJson);
            }else{
                NSLog(@"lazy的json数据转换出错");
            }
        }
        [request setNumberOfTimesToRetryOnTimeout:2];
        [request startAsynchronous];
        __weak ASIHTTPRequest *requestWeak = request;
        [request setCompletionBlock:^(){
            if (requestWeak.responseStatusCode == 200) {
                NSData *final = [requestWeak responseData];
                NSArray *getData = [NSJSONSerialization JSONObjectWithData:final options:NSJSONReadingMutableLeaves error:nil];
                NSLog(@"%@",getData);
                NSArray *classArray;
                if (getData.count != 0) {
                    [[MyDataBase shareMyDataBase]deleteCacheWithKey:key];
                    [[MyDataBase shareMyDataBase]saveCacheWithData:[requestWeak responseString] cacheKey:key];
                    classArray = [service getClassArrayFromReceivedArrayData:getData className:clazzName];
                }else{
                    classArray = nil;
                    NSLog(@"请求为空");
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        if (![clazzName isEqualToString:@"MiMemberSignUp"]) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求数据为空!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^(){
                    handler1(classArray);
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^(){
                    NSLog(@"%@",seletSQL);
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"网速不给力>_<" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    handler1(nil);
                });
            }
        }];
    }
    
    return request;
}








-(NSArray *)getClassArrayFromReceivedArrayData:(NSArray *)arrayData className:(NSString *)clazzName
{
    NSMutableArray *classArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in arrayData) {
        NSObject *object = [self getClassfromData:dic className:clazzName];
        [classArray addObject:object];
    }
    return classArray;
}
-(NSObject *)getClassfromData:(NSDictionary *)dicData className:(NSString *)clazzName
{
    NSObject *object = [[NSClassFromString(clazzName) alloc]init];
    NSArray *property = [service getPropertyListAndPropertyType:NSClassFromString(clazzName)];
    for (NSString *propertyName in [property objectAtIndex:0]) {
        if ([[[property objectAtIndex:2]valueForKey:propertyName]isEqualToString:@"NSDate"]) {
//            NSLog(@"给%@类的属性%@赋值%@",clazzName,propertyName,(NSDate *)[dicData valueForKey:propertyName]);
            [object setTureValue:(NSDate *)[dicData valueForKey:propertyName] forKey:propertyName];
            
        }else if ([[[property objectAtIndex:2]valueForKey:propertyName]hasPrefix:@"Mi"]){
//            NSLog(@"%@===%@",[dicData valueForKey:propertyName],[[property objectAtIndex:2]valueForKey:propertyName]);
            if ([dicData valueForKey:propertyName]) {
//                NSLog(@"给%@类的属性%@赋值*外键*",clazzName,propertyName);
                [object setTureValue:[service getClassfromData:[dicData valueForKey:propertyName] className:[[property objectAtIndex:2]valueForKey:propertyName]] forKey:propertyName];
            }
        }else{
//            NSLog(@"给%@类的属性%@赋值%@",clazzName,propertyName,[dicData valueForKey:propertyName]);
            [object setTureValue:[dicData valueForKey:propertyName] forKey:propertyName];
        }
    }
    return object;
}


#pragma mark ----------------------------------
#pragma mark DOWNLOAD

-(void)downLoadAttachmentWithURL:(NSString *)URLName path:(NSString *)pathName completionHandler:(void(^)(void))handler1
{
    if ([service haveHttpService]) {
        NSMutableString *strURL = [NSMutableString stringWithFormat:@"http://117.121.56.21/tangcenes/upLoadFiles/"];
        [strURL appendString:URLName];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strURL]];
        [request setDownloadDestinationPath:pathName];
        [self.requestDic setObject:request forKey:URLName];
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestHaveChange)]) {
            [self.delegate requestHaveChange];
        }
        [request startAsynchronous];
        __weak ASIHTTPRequest *requestWeak = request;
        __weak AllHttpService *mine = self;
        [request setCompletionBlock:^(){
            NSLog(@"下载完成%d",requestWeak.responseStatusCode);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                handler1();
                [mine.requestDic removeObjectForKey:URLName];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    if (mine.delegate && [mine.delegate respondsToSelector:@selector(requestHaveChange)]) {
                        [mine.delegate requestHaveChange];
                    }
                });
            });
        }];
        [request setFailedBlock:^(){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"下载文件出错，请退出重新下载!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [mine.requestDic removeObjectForKey:URLName];
            if (mine.delegate && [mine.delegate respondsToSelector:@selector(requestHaveChange)]) {
                [mine.delegate requestHaveChange];
            }
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查你的网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}

#pragma mark ----------------------------------
#pragma mark UPDATE_MEMBER_FILE

-(void)UploadMemberPictureWithData:(NSData *)pictureData pictureName:(NSString *)pictureName completionHandler:(void (^)(NSDictionary *))handler
{
    if ([service haveHttpService]) {
        if (!pictureName) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
            NSMutableString *nameTemp = [NSMutableString stringWithString:currentDateStr];
            [nameTemp appendFormat:@"apple.png"];
            pictureName = nameTemp;
        }
        NSMutableString *strURL = [NSMutableString stringWithFormat:WILDCARDOFURL];
        [strURL appendFormat:@"upLoadFiles"];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
        [request setRequestMethod:@"POST"];
        [request setTimeOutSeconds:30];
        [request setPostValue:pictureName forKey:@"fileName"];
        [request addData:pictureData forKey:@"uploadFile"];
        //        [request addFile:filePath forKey:@"uploadFile"];
        [request startAsynchronous];
        __weak ASIHTTPRequest *requestWeak = request;
        [request setCompletionBlock:^(){
            NSString *str = [NSString stringWithString:[requestWeak responseString]];
            str = [str substringToIndex:str.length-1];
            str = [str substringFromIndex:1];
            NSMutableString *dataStr = [NSMutableString stringWithFormat:@"{"];
            [dataStr appendString:str];
            [dataStr appendFormat:@"}"];
            NSDictionary *getData = [NSJSONSerialization JSONObjectWithData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            dispatch_async(dispatch_get_main_queue(), ^(){
                handler(getData);
            });
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请检查你的网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}


#pragma mark ----------------------------------
#pragma mark data storage



-(NSString *)createCacheKeyfromSeletSql:(NSString *)seletSQL seletValue:(NSString *)valueStr useLazy:(BOOL)lazy
{
    NSMutableString *keyStr = [[NSMutableString alloc]init];
    if (lazy) {
        [keyStr appendFormat:@"1111"];
    }else{
        [keyStr appendFormat:@"0000"];
    }
    [keyStr appendString:seletSQL];
    if (valueStr) {
        [keyStr appendString:valueStr];
    }
    return keyStr;
}



#pragma mark ----------------------------------











#pragma mark someClassMethod

-(BOOL)haveHttpService
{
    BOOL booler = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            booler=NO;
            //   NSLog(@"没有网络");
            break;
        case ReachableViaWWAN:
            booler=YES;
            //   NSLog(@"正在使用3G网络");
            break;
        case ReachableViaWiFi:
            booler=YES;
            //  NSLog(@"正在使用wifi网络");
            break;
    }
    return booler;
}





-(NSDictionary *)getClassXMlData:(NSString *)className
{
    NSDictionary *dic;
    for (NSDictionary *dic1 in self.XmlArray) {
        if ([[dic1 valueForKey:@"className"]isEqualToString:className]) {
            dic = [NSDictionary dictionaryWithDictionary:dic1];
        }
    }
    return dic;
}

//-(NSArray *)getXmlData
//{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"reflectionClass" ofType:@"xml"];
//    NSData *xmlData = [[NSData alloc]initWithContentsOfFile:filePath];
//    GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
//    NSArray *arrayData = [[doc rootElement] elementsForName:@"item"];
//    NSMutableArray *array = [[NSMutableArray alloc]init];
//    for (GDataXMLElement *classData in arrayData) {
//        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//        [dic setValue:[[[classData elementsForName:@"className"]objectAtIndex:0]stringValue] forKey:@"className"];
//        [dic setValue:[[[classData elementsForName:@"classPath"]objectAtIndex:0]stringValue] forKey:@"classPath"];
//        NSArray *propertyArray = [classData elementsForName:@"property"];
//        NSMutableArray *arrayDone = [[NSMutableArray alloc]init];
//        for (GDataXMLElement *propertyXMl in propertyArray) {
//            NSMutableDictionary *dicDone = [[NSMutableDictionary alloc]init];
//            [dicDone setValue:[[[propertyXMl elementsForName:@"name"]objectAtIndex:0]stringValue] forKey:@"propertyName"];
//            [dicDone setValue:[[[propertyXMl elementsForName:@"annotation"]objectAtIndex:0]stringValue] forKey:@"annotation"];
//            [arrayDone addObject:dicDone];
//        }
//        [dic setValue:arrayDone forKey:@"property"];
//        [array addObject:dic];
//    }
//    return array;
//    
//}
//

#pragma mark -----------------------
@end

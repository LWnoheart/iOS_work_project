//
//  Header.h
//  中文+
//
//  Created by tangce on 14-7-4.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#ifndef ____Header_h
#define ____Header_h



#define IOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
#define  NavigationVC_StartY (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)?64.f:0.f)
#define APP (AppDelegate*)[UIApplication sharedApplication].delegate
#define DEVICE_WIDTH  ([[UIScreen mainScreen] bounds].size.width)

#define DEVICE_HEIGHT (([[UIScreen mainScreen] bounds].size.height)-0)

#define UIFONT(S) [UIFont systemFontOfSize:S]

#define  SetObject(object,key) [[NSUserDefaults standardUserDefaults] setObject:object forKey:key]
#define  GetObject(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define  RemoveObject(key) [[NSUserDefaults standardUserDefaults] removeObjectForKey:key]

#define Document_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define Caches_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]


#define RemoveFile(path) [[NSFileManager defaultManager]removeItemAtPath:path error:nil]
#define ExistFile(path) [[NSFileManager defaultManager]fileExistsAtPath:path]
#define CreatFile(path) [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
#endif

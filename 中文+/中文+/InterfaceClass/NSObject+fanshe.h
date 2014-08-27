//
//  NSObject+fanshe.h
//  ios 类反射
//
//  Created by 李巍 on 13-3-15.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^aspect_block_t)(NSInvocation *invocation);
@interface NSObject (fanshe)

- (NSArray *)getPropertyList: (Class)clazz;

-(NSArray *)getPropertyListAndPropertyType:(Class)clazz;
//- (NSMutableDictionary *)serializeObject:(id)theObject;

-(NSArray *)getMethodList:(Class)clazz;

//- (void)interceptClass:(Class)aClass beforeExecutingSelectorLooklikeName:(NSString *)seletorStr usingBlock:(aspect_block_t)block;
@end

//
//  NSObject+MyMethod.m
//  faces
//
//  Created by 李巍 on 13-4-27.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import "NSObject+MyMethod.h"

@implementation NSObject (MyMethod)
-(void)setTureValue:(id)value forKey:(NSString *)key
{
    if (value&&value!=[NSNull null]) {
        [self setValue:value forKey:key];
    }
}
-(void)setTureValue:(id)value forKeyPath:(NSString *)key
{
    if (value) {
        [self setValue:value forKeyPath:key];
    }
}

@end

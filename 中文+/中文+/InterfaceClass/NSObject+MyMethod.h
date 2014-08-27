//
//  NSObject+MyMethod.h
//  faces
//
//  Created by 李巍 on 13-4-27.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MyMethod)
-(void)setTureValue:(id)value forKey:(NSString *)key;
-(void)setTureValue:(id)value forKeyPath:(NSString *)key;
@end

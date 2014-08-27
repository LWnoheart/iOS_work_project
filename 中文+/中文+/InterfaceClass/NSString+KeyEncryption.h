//
//  NSString+KeyEncryption.h
//  eduNet
//
//  Created by 李巍 on 13-6-4.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KeyEncryption)
- (NSString *) sha1_base64;
- (NSString *) md5_base64;
- (NSString *) tureDate;
- (NSString *) tureDateWithoutT;
- (NSString *) onlyTextFromHTML;
- (NSString *) timeDateStr;
@end

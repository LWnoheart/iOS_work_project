//
//  NSString+KeyEncryption.m
//  eduNet
//
//  Created by 李巍 on 13-6-4.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import "NSString+KeyEncryption.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (KeyEncryption)
- (NSString *) sha1_base64 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSData * base64 = [[NSData alloc]initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    base64 = [GTMBase64 encodeData:base64];
    NSString * output = [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
    return output;
}
- (NSString *) md5_base64 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSData * base64 = [[NSData alloc]initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    base64 = [GTMBase64 encodeData:base64];
    NSString * output = [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
    return output;
}
-(NSString *)tureDate
{
    NSString *str = [self stringByReplacingCharactersInRange:[self rangeOfString:@"T"] withString:@" "];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *dateTemp = [formatter dateFromString:[str substringToIndex:str.length-1]];
    NSString *dateStr = [formatter stringFromDate:[dateTemp dateByAddingTimeInterval:8*60*60]];
    return dateStr;
}
-(NSString *)tureDateWithoutT
{
    NSRange range = [self rangeOfString:@"T"];
    NSString *str = self;
    if (range.length != 0) {
        str = [self stringByReplacingCharactersInRange:range withString:@" "];
    }
    return str;
}

-(NSString *)onlyTextFromHTML
{
    NSRange range;
    NSString *memoStr = [NSString stringWithString:self];
    while ((range = [memoStr rangeOfString:@"<([^>]*)>" options:NSRegularExpressionSearch]).location != NSNotFound){
        memoStr = [memoStr stringByReplacingCharactersInRange:range withString:@""];
    }
    while ((range = [memoStr rangeOfString:@"&[a-z]*;" options:NSRegularExpressionSearch]).location != NSNotFound){
        memoStr = [memoStr stringByReplacingCharactersInRange:range withString:@""];
    }
    return memoStr;
}
-(NSString *)timeDateStr
{
    NSString *str = [NSString stringWithString:self];
    return str;
}
@end
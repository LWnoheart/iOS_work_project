//
//  MiFasciculeBook.h
//  中文+
//
//  Created by tangce on 14-7-10.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MiFasciculeBook : NSObject
@property (nonatomic,assign)NSInteger id;
/** 教材名称 */
@property (nonatomic,strong)NSString *bookName;
/** 压缩包地址*/
@property (nonatomic,strong)NSString *zipUri;

/** 教材缩略图 */
@property (nonatomic,strong)NSString *bookImage;
/** 教材pdf地址*/
@property (nonatomic,strong)NSString *bookDir;

@property (nonatomic,assign)NSInteger isState;
@end

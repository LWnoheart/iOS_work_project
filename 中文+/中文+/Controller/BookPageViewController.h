//
//  BookPageViewController.h
//  中文+
//
//  Created by tangce on 14-7-2.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookPageViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pageIndex:(NSInteger)pageIndex;
@property (nonatomic, assign,readonly) NSInteger currentIndex;
@property (nonatomic, strong) NSString *bookPath;
@end

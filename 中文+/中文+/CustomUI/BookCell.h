//
//  BookCell.h
//  中文+
//
//  Created by tangce on 14-6-30.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BookCellState) {
    BookCellStateNormal,
    BookCellStateDownLoad,
    BookCellStateGray
};

@interface BookCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, assign) BookCellState style;
@end

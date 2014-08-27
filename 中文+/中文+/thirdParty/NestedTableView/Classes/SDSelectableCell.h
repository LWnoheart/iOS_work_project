//
//  SDSelectableCell.h
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 23/05/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDNestedTableViewController;


@interface SDSelectableCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *itemText;

@property (nonatomic, assign) SDNestedTableViewController *parentTable;



- (void) setupInterface;

@end

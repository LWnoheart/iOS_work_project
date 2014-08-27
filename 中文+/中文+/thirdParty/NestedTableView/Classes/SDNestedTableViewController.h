//
//  SDNestedTableViewController.h
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 21/05/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//


#import "LWvcWithTableview.h"
#import "SDSelectableCell.h"
#import "SDGroupCell.h"
#import "SDSubCell.h"

@protocol SDNestedTableDelegate<NSObject>

- (void) mainTable:(UITableView *)mainTable itemDidChange:(SDGroupCell *)item;
- (void) item:(SDGroupCell *)item subItemDidChange:(SDSelectableCell *)subItem;

@end

@interface SDNestedTableViewController : LWvcWithTableview<SDNestedTableDelegate>
{
	NSMutableDictionary *expandedIndexes;
}



- (void) mainItemDidChange: (SDGroupCell *)item forTap:(BOOL)tapped;
- (void) mainItem:(SDGroupCell *)item subItemDidChange: (SDSelectableCell *)subItem forTap:(BOOL)tapped;

#pragma mark - To be implemented in subclasses

- (NSInteger) mainTable:(UITableView *)mainTable numberOfItemsInSection:(NSInteger)section;
- (NSInteger) mainTable:(UITableView *)mainTable numberOfSubItemsforItem:(SDGroupCell *)item atIndexPath:(NSIndexPath *)indexPath;

- (SDGroupCell *) mainTable:(UITableView *)mainTable setItem:(SDGroupCell *)item forRowAtIndexPath:(NSIndexPath *)indexPath;
- (SDSubCell *) item:(SDGroupCell *)item setSubItem:(SDSubCell *)subItem forRowAtIndexPath:(NSIndexPath *)indexPath;
//收起
- (void) collapsingItem:(SDGroupCell *)item withIndexPath:(NSIndexPath *)indexPath;
//展开
- (void) expandingItem:(SDGroupCell *)item withIndexPath:(NSIndexPath *)indexPath;

- (NSString *) nibNameForMainCell;

#pragma mark - Internal

@property (assign) int mainItemsAmt;
@property (strong) NSMutableDictionary *subItemsAmt;
@property (assign) id<SDNestedTableDelegate> delegate;

@property (assign) IBOutlet SDGroupCell *groupCell;


- (void) collapsableButtonTapped: (UIControl *)button withEvent: (UIEvent *)event;
- (void) groupCell:(SDGroupCell *)cell didSelectSubCell:(SDSelectableCell *)subCell withIndexPath: (NSIndexPath *)indexPath andWithTap:(BOOL)tapped;

@end

//
//  SDGroupCell.h
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 21/05/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSubCell.h"
#import "SDSelectableCell.h"


static const int height = 100;
static const int subCellHeight = 80;

@interface SDGroupCell : SDSelectableCell <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIButton *expandBtn;
}

@property (assign) BOOL isExpanded;
@property (assign) IBOutlet UITableView *subTable;
@property (assign) IBOutlet SDSubCell *subCell;
@property (nonatomic) int subCellsAmt;
@property (nonatomic, assign) NSMutableDictionary *selectableSubCellsState;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) IBOutlet UILabel *thirdLabel;

//- (void) rotateExpandBtn:(id)sender;
//- (void) rotateExpandBtnToExpanded;
//- (void) rotateExpandBtnToCollapsed;

+ (int) getHeight;
+ (int) getsubCellHeight;

@end

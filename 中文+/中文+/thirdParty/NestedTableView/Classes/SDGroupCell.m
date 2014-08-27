//
//  SDGroupCell.m
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 21/05/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//

#import "SDGroupCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SDNestedTableViewController.h"

@implementation SDGroupCell

@synthesize isExpanded, subTable, subCell, subCellsAmt, selectableSubCellsState;

+ (int) getHeight
{
    return height;
}

+ (int) getsubCellHeight
{
    return subCellHeight;
}

#pragma mark - Lifecycle

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        
    }
    return self;
}


- (void) setupInterface
{
    [super setupInterface];
    
    expandBtn.frame = CGRectMake(625, 15, 54, 65);
    [expandBtn setBackgroundColor:[UIColor clearColor]];
    [expandBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"smallBook" ofType:@"png"]] forState:UIControlStateNormal];
    [expandBtn setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"smallBookTD" ofType:@"png"]] forState:UIControlStateHighlighted];
    [expandBtn addTarget:self.parentTable action:@selector(collapsableButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
//    [expandBtn addTarget:self action:@selector(rotateExpandBtn:) forControlEvents:UIControlEventTouchUpInside];
//    expandBtn.alpha = 0.45;
    
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        if (self.itemText.text) {
            [self.contentView viewWithTag:7913].hidden = NO;
            [self.contentView viewWithTag:8462].hidden = NO;
        }else{
            [self.contentView viewWithTag:7913].hidden = YES;
            [self.contentView viewWithTag:8462].hidden = YES;
        }
    }
}


#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return subCellsAmt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDSubCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubCell"];
    
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"SDSubCell" owner:self options:nil];
        cell = subCell;
        self.subCell = nil;
    }
    cell.tag = indexPath.row;
    
    cell = [self.parentTable item:self setSubItem:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return subCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SDSubCell *cell = (SDSubCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil)
    {
        cell = (SDSubCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    [self.parentTable groupCell:self didSelectSubCell:cell withIndexPath:indexPath andWithTap:YES];
}
- (void)awakeFromNib
{
    // Initialization code
    expandBtn.tag = 8462;
    [self.itemText addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)dealloc
{
    [self.itemText removeObserver:self forKeyPath:@"text" context:nil];
}
@end

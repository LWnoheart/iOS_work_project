//
//  SDNestedTableViewController.m
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 21/05/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//

#import "SDNestedTableViewController.h"

@interface SDNestedTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation SDNestedTableViewController

@synthesize mainItemsAmt, subItemsAmt, groupCell;
@synthesize delegate;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - To be implemented in sublclasses

- (NSInteger)mainTable:(UITableView *)mainTable numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"\n Oops! You didn't specify the amount of Items in the Main tableview \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
    return 0;
}

- (NSInteger)mainTable:(UITableView *)mainTable numberOfSubItemsforItem:(SDGroupCell *)item atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"\n Oops! You didn't specify the amount of Sub Items for this Main Item \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
    return 0; 
}

- (SDGroupCell *)mainTable:(UITableView *)mainTable setItem:(SDGroupCell *)item forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0)
    {
        NSLog(@"\n Oops! Item cells in the Main tableview are not configured \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
    }
    return item;
}

- (SDSubCell *)item:(SDGroupCell *)item setSubItem:(SDSubCell *)subItem forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NSLog(@"\n Oops! Sub Items for this Item are not configured \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
    }
    return subItem;
}

- (void)expandingItem:(SDGroupCell *)item withIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collapsingItem:(SDGroupCell *)item withIndexPath:(NSIndexPath *)indexPath 
{

}
    
// Optional method to implement. Will be called when creating a new main cell to return the nib name you want to use

- (NSString *) nibNameForMainCell
{
    return @"SDGroupCell";
}

#pragma mark - Delegate methods

- (void) mainTable:(UITableView *)mainTable itemDidChange:(SDGroupCell *)item
{
    NSLog(@"\n Oops! You didn't specify a behavior for this Item \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
}

- (void) item:(SDGroupCell *)item subItemDidChange:(SDSelectableCell *)subItem
{
    NSLog(@"\n Oops! You didn't specify a behavior for this Sub Item \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
}

- (void) mainItemDidChange: (SDGroupCell *)item forTap:(BOOL)tapped
{
    if(delegate != nil && [delegate respondsToSelector:@selector(mainTable:itemDidChange:)] )
    {
        [delegate performSelector:@selector(mainTable:itemDidChange:) withObject:self.mytableView withObject:item];
    }
}

- (void) mainItem:(SDGroupCell *)item subItemDidChange: (SDSelectableCell *)subItem forTap:(BOOL)tapped
{
    if(delegate != nil && [delegate respondsToSelector:@selector(item:subItemDidChange:)] )
    {
        [delegate performSelector:@selector(item:subItemDidChange:) withObject:item withObject:subItem];
    }
}

#pragma mark - Class lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    subItemsAmt = [[NSMutableDictionary alloc] initWithDictionary:nil];
	expandedIndexes = [[NSMutableDictionary alloc] init];
    
    self.mytableView.rowHeight = 40;
    self.mytableView.backgroundColor = [UIColor clearColor];
    self.mytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - TableView delegation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    mainItemsAmt = [self mainTable:tableView numberOfItemsInSection:section];
    return mainItemsAmt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:[self nibNameForMainCell] owner:self options:nil];
        cell = groupCell;
        self.groupCell = nil;
    }
    cell.tag = indexPath.row;
    [cell setParentTable: self];
    
    cell = [self mainTable:tableView setItem:cell forRowAtIndexPath:indexPath];
    
    NSNumber *amt = [NSNumber numberWithInt:[self mainTable:tableView numberOfSubItemsforItem:cell atIndexPath:indexPath]];
    [subItemsAmt setObject:amt forKey:[NSNumber numberWithInt:indexPath.row]];
    
    [cell setSubCellsAmt: [[subItemsAmt objectForKey:[NSNumber numberWithInt:indexPath.row]] intValue]];
    
    BOOL isExpanded = [[expandedIndexes objectForKey:[NSNumber numberWithInt:indexPath.row]] boolValue];
    cell.isExpanded = isExpanded;
    
    [cell.subTable reloadData];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int amt = [[subItemsAmt objectForKey:[NSNumber numberWithInt:indexPath.row]] intValue];
    BOOL isExpanded = [[expandedIndexes objectForKey:[NSNumber numberWithInt:indexPath.row]] boolValue];
    if(isExpanded)
    {
        return [SDGroupCell getHeight] + [SDGroupCell getsubCellHeight]*amt + 1;
    }
    return [SDGroupCell getHeight];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[expandedIndexes objectForKey:[NSNumber numberWithInt:indexPath.row]] boolValue]) {
        [self collapsingItem:(SDGroupCell *)[tableView cellForRowAtIndexPath:indexPath] withIndexPath:indexPath];
    } else {
        [self expandingItem:(SDGroupCell *)[tableView cellForRowAtIndexPath:indexPath] withIndexPath:indexPath];
    }
    
    // reset cell expanded state in array
	BOOL isExpanded = ![[expandedIndexes objectForKey:[NSNumber numberWithInt:indexPath.row]] boolValue];
	NSNumber *expandedIndex = [NSNumber numberWithBool:isExpanded];
	[expandedIndexes setObject:expandedIndex forKey:[NSNumber numberWithInt:indexPath.row]];
    
    [self.mytableView beginUpdates];
    [self.mytableView endUpdates];
}

#pragma mark - Nested Tables events

- (void) groupCell:(SDGroupCell *)cell didSelectSubCell:(SDSelectableCell *)subCell withIndexPath:(NSIndexPath *)indexPath andWithTap:(BOOL)tapped
{
    [self mainItem:cell subItemDidChange:subCell forTap:tapped];
}

- (void) collapsableButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    UITableView *tableView = self.mytableView;
    NSIndexPath * indexPath = [tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: tableView]];
    if ( indexPath == nil )
        return;
    SDGroupCell *cell = (SDGroupCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self mainItemDidChange:cell forTap:YES];
}

@end

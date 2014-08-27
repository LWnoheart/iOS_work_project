//
//  SDSelectableCell.m
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 23/05/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//

#import "SDSelectableCell.h"

@implementation SDSelectableCell

@synthesize itemText, parentTable;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        
    }
    return self;
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    [self setupInterface];
}

- (void) setupInterface
{
    [self setClipsToBounds: YES];
    
//    tapTransitionsOverlay.backgroundColor = [UIColor colorWithRed:0.15 green:0.54 blue:0.93 alpha:1.0];
//    
//    CGRect frame = self.itemText.frame;
//    frame.size.width = checkBox.frame.origin.x - frame.origin.x - (int)(self.frame.size.width/30);
//    self.itemText.frame = frame;
}

@end

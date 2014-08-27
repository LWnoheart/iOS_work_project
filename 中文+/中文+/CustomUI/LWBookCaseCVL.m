//
//  LWBookCaseCVL.m
//  中文+
//
//  Created by tangce on 14-6-30.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "LWBookCaseCVL.h"
#import "BookCaseBG.h"
#define GET_MAX_MULTIPLE(x,y)  ((x%y>0) ? x/y+1 : x/y)
@interface LWBookCaseCVL (){
    CGPoint itemBeginPoint;
    CGSize itemCycleIncremental;
    NSInteger numberOfRow;
    NSInteger decorationIncrementalH;
}

@end

@implementation LWBookCaseCVL


-(void)prepareLayout
{
    [super prepareLayout];
    [self registerClass:[BookCaseBG class] forDecorationViewOfKind:@"BOOKCASEBG"];
    numberOfRow = (self.collectionView.frame.size.width+_minSpaceWight-_itemsInset.left-_itemsInset.right)/(self.itemSize.width+_minSpaceWight);
    itemBeginPoint = CGPointMake(_itemsInset.left, _itemsInset.top);
    itemCycleIncremental = CGSizeMake(self.itemSize.width+(self.collectionView.frame.size.width-_itemsInset.left-_itemsInset.right-(numberOfRow*self.itemSize.width))/(numberOfRow-1), self.itemSize.height+_minSpaceHeight);
    decorationIncrementalH = self.itemSize.height+_minSpaceHeight;
}

-(CGSize)collectionViewContentSize
{
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger multiple = GET_MAX_MULTIPLE(itemCount,numberOfRow);
    return CGSizeMake(self.collectionView.frame.size.width, decorationIncrementalH*multiple);
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i=0 ; i < [self.collectionView numberOfItemsInSection:0 ]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        if ((i+numberOfRow)%numberOfRow==0) {
            [attributes addObject:[self layoutAttributesForDecorationViewOfKind:@"BOOKCASEBG" atIndexPath:indexPath]];
        }
    }
//    for (NSInteger j=0; j<GET_MAX_MULTIPLE([self.collectionView numberOfItemsInSection:0], numberOfRow); j++) {
//        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:j inSection:0];
//        
//    }
    return attributes;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(itemBeginPoint.x+itemCycleIncremental.width*((indexPath.item+numberOfRow)%numberOfRow), itemBeginPoint.y+itemCycleIncremental.height*(indexPath.row/numberOfRow), self.itemSize.width, self.itemSize.height);
    
    
    return attributes;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}
////if your layout supports supplementary views
//-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    
//}
//if your layout supports decoration views
-(UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes* att = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind  withIndexPath:indexPath];
    
    att.frame=CGRectMake(0, decorationIncrementalH*(indexPath.item/numberOfRow), self.collectionView.frame.size.width, decorationIncrementalH);
    
    att.zIndex=-1;
    
    
    return att;
}
@end

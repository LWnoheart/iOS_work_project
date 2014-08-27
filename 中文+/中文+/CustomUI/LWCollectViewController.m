//
//  LWCollectViewController.m
//  中文+
//
//  Created by tangce on 14-6-30.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "LWCollectViewController.h"
#import "LWBookCaseCVL.h"
#import "BookCell.h"
#import "BookCaseBG.h"
@interface LWCollectViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation LWCollectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    LWBookCaseCVL *collectLayout = [[LWBookCaseCVL alloc]init];
    collectLayout.itemSize = CGSizeMake(200, 200);
    collectLayout.minSpaceHeight = 10;
    collectLayout.minSpaceWight = 30;
    collectLayout.itemsInset = UIEdgeInsetsMake(20, 50, 20, 50);
    [collectLayout registerClass:[BookCaseBG class] forDecorationViewOfKind:@"BOOKCASEBG"];
    self.myCollectView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:collectLayout];
    self.myCollectView.dataSource = self;
    self.myCollectView.delegate = self;
    [self.myCollectView registerClass:[BookCell class] forCellWithReuseIdentifier:@"TT_TT"];
    [self.view addSubview:self.myCollectView];
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    // Do any additional setup after loading the view.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 36;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCell *cell = [self.myCollectView dequeueReusableCellWithReuseIdentifier:@"TT_TT" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%d",indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

//// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}// called when the user taps on an already-selected item in multi-select mode
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

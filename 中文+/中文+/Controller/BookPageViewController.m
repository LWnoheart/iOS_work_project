//
//  BookPageViewController.m
//  中文+
//
//  Created by tangce on 14-7-2.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "BookPageViewController.h"
#import "BookPageImage.h"
#import "BookCell.h"


@interface BookPageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    BookPageImage *currentPage;
    __weak UICollectionView *myCollectView;

}
@property (nonatomic, strong) NSDictionary *bookJson;
@end

@implementation BookPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil pageIndex:(NSInteger)pageIndex
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currentIndex = pageIndex;
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currentIndex = 1;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //
    NSString *jsonPath = [NSString stringWithFormat:@"%@/bookConfig.txt",self.bookPath];
    self.bookJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingAllowFragments error:nil];
    
    self.navigationItem.title = [self.bookJson objectForKey:@"bookName"];
    
    
    //
    BookPageImage *image = [[BookPageImage alloc]initWithFrame:CGRectMake(0, NavigationVC_StartY, self.view.frame.size.width, self.view.frame.size.height-NavigationVC_StartY) rootPath:self.bookPath pageIndex:self.currentIndex];
    [self.view addSubview:image];
    currentPage = image;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    //
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"index20" ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:@selector(indexPress:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:self.currentIndex] forKey:self.bookPath];
}

-(void)swipeAction:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self changePageIndex:self.currentIndex+1];
    }else if (swipe.direction == UISwipeGestureRecognizerDirectionRight){
        [self changePageIndex:self.currentIndex-1];
    }
}

-(void)changePageIndex:(NSInteger)index
{
    NSInteger maxPage = [[self.bookJson objectForKey:@"page"]integerValue];
    if (index<1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已至首页" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }else if (index>maxPage){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已至末页" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    float startX = 0;
    CGSize shadowSize;
    if (index<self.currentIndex) {
        startX = -self.view.frame.size.width;
        shadowSize = CGSizeMake(4, 0);
    }else if (index>self.currentIndex){
        startX = self.view.frame.size.width;
        shadowSize = CGSizeMake(-4, 0);
    }else if (index == self.currentIndex){
        return;
    }
    BookPageImage *image = [[BookPageImage alloc]initWithFrame:CGRectMake(startX, NavigationVC_StartY, self.view.frame.size.width, self.view.frame.size.height-NavigationVC_StartY) rootPath:self.bookPath pageIndex:index];
    image.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    image.layer.shadowOpacity = 0.6;
    image.layer.shadowOffset = shadowSize;
    [self.view addSubview:image];
    [UIView animateWithDuration:0.3f animations:^(){
        CGRect frame = image.frame;
        frame.origin.x = 0;
        image.frame = frame;
    }completion:^(BOOL ber){
        if (ber) {
            [currentPage removeFromSuperview];
            currentPage = image;
            _currentIndex = index;
        }
    }];
}


-(void)indexPress:(id)sender
{
    if (!myCollectView) {
        UICollectionViewFlowLayout *collectLayout = [[UICollectionViewFlowLayout alloc]init];
        collectLayout.minimumLineSpacing = 30;
        collectLayout.minimumInteritemSpacing = 30;
        collectLayout.itemSize = CGSizeMake(150, 208);
        collectLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        collectLayout.sectionInset = UIEdgeInsetsMake(64, 20, 0, 20);
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:currentPage.frame collectionViewLayout:collectLayout];
        myCollectView = collectionView;
        myCollectView.backgroundColor = [UIColor clearColor];
        UIView *background = [[UIView alloc]init];
        background.backgroundColor = [UIColor grayColor];
        background.alpha = 0.5;
        myCollectView.backgroundView = background;
        myCollectView.dataSource = self;
        myCollectView.delegate = self;
        [myCollectView registerClass:[BookCell class] forCellWithReuseIdentifier:@"TT_TT"];
        [self.view addSubview:myCollectView];
    }else{
        [myCollectView removeFromSuperview];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger maxPage = [[self.bookJson objectForKey:@"page"]integerValue];
    return maxPage;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCell *cell = [myCollectView dequeueReusableCellWithReuseIdentifier:@"TT_TT" forIndexPath:indexPath];
    cell.style = BookCellStateNormal;
    NSString *imagePath = [NSString stringWithFormat:@"%@/page/%ld.jpg",self.bookPath,(long)indexPath.row+1];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    CGSize newSize = CGSizeMake(150, 208);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.image.image = newImage;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self changePageIndex:indexPath.row+1];
    [myCollectView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

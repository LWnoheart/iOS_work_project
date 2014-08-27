//
//  BookCaseViewController.m
//  中文+
//
//  Created by tangce on 14-7-4.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "BookCaseViewController.h"
#import "LWBookCaseCVL.h"
#import "BookCell.h"
#import "BookCaseBG.h"
#import "BookPageViewController.h"
#import "MBProgressHUD.h"
#import "MiFasciculeBook.h"
#import "ZipArchive.h"
#import "UIImage+OpenCV.h"

@interface BookCaseViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate,AllHttpServiceDelegate>{
    MiFasciculeBook *currntBook;
}
@property (nonatomic, strong)UICollectionView *myCollectView;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation BookCaseViewController

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
    
    self.navigationItem.title = @"书架";
    //
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    self.HUD.labelText = @"加载中...";
    self.HUD.labelFont = [UIFont systemFontOfSize:12];
    self.HUD.color = [UIColor lightGrayColor];
    [self.view addSubview:self.HUD];
    //
    LWBookCaseCVL *collectLayout = [[LWBookCaseCVL alloc]init];
    collectLayout.itemSize = CGSizeMake(180, 255);
    collectLayout.minSpaceHeight = 80;
    collectLayout.minSpaceWight = 10;
    collectLayout.itemsInset = UIEdgeInsetsMake(20, 60, 0, 60);
    [collectLayout registerClass:[BookCaseBG class] forDecorationViewOfKind:@"BOOKCASEBG"];
    self.myCollectView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:collectLayout];
    self.myCollectView.backgroundColor = [UIColor whiteColor];
    self.myCollectView.dataSource = self;
    self.myCollectView.delegate = self;
    [self.myCollectView registerClass:[BookCell class] forCellWithReuseIdentifier:@"TT_TT"];
    [self.view addSubview:self.myCollectView];
    UIImageView *bookCaseHeader = [[UIImageView alloc]initWithFrame:CGRectMake(0, -287, 768, 287)];
    bookCaseHeader.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"bookCaseHead" ofType:@"png"]];
    if (IOS_7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.myCollectView.contentInset = UIEdgeInsetsMake(64+287, 0, 0, 0);
    }else{
        self.myCollectView.contentInset = UIEdgeInsetsMake(287, 0, 0, 0);
    }
    [self.myCollectView addSubview:bookCaseHeader];
    //
    __weak BookCaseViewController *ours = self;
    [self.HUD show:YES];
    self.dataArray = [[NSMutableArray alloc]init];
    NSString *sqlStr = [NSString stringWithFormat:@"from MiFasciculeBook h where h.isState > 0"];
    NSDictionary *sqlDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:0],@"offset",[NSNumber numberWithInt:100000],@"max", nil];
    [[AllHttpService sharedHttpService]selectAllObjectToseletCode:sqlStr selectDictionary:sqlDic selectType:1 UseLazy:NO objectClassName:@"MiFasciculeBook" completionHandler:^(NSArray *array){
        for (NSObject *object in array) {
            [ours.dataArray addObject:object];
        }
        [ours.myCollectView reloadData];
        [ours.HUD hide:YES];
    }];
    [AllHttpService sharedHttpService].delegate = self;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.downLoadBookID!=0) {
        [self downLoadBook:self.downLoadBookID];
    }
    self.downLoadBookID = 0;
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//    [AllHttpService sharedHttpService].delegate = nil;
//    for (ASIHTTPRequest *request in [AllHttpService sharedHttpService].requestDic.allValues) {
//        request.downloadProgressDelegate = nil;
//    }
//}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataArray.count<7) {
        return 7;
    }else{
        return self.dataArray.count;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCell *cell = [self.myCollectView dequeueReusableCellWithReuseIdentifier:@"TT_TT" forIndexPath:indexPath];
    if (indexPath.row<self.dataArray.count) {
        MiFasciculeBook *book = [self.dataArray objectAtIndex:indexPath.row];
        [cell.image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:HTTPIMAGEURL,book.bookImage]] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"de_03" ofType:@"png"]]];
        if ([[AllHttpService sharedHttpService].requestDic.allKeys containsObject:book.zipUri]) {
            cell.style = BookCellStateDownLoad;
            ASIHTTPRequest *request = [[AllHttpService sharedHttpService].requestDic objectForKey:book.zipUri];
            request.downloadProgressDelegate = cell;
        }else if ([self containBook:book]){
            cell.style = BookCellStateNormal;
        }else{
            cell.style = BookCellStateGray;
        }
    }else{
        cell.image.image = nil;
        cell.style = BookCellStateNormal;
    }
    return cell;
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//{
//    return 2;
//}

//// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//
//}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"%@",rrquest);
//}
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"%ld",(long)indexPath.row);
//}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCell *cell = (BookCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.style == BookCellStateDownLoad) {
        return NO;
    }
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}// called when the user taps on an already-selected item in multi-select mode
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<self.dataArray.count) {
        MiFasciculeBook *book = [self.dataArray objectAtIndex:indexPath.row];
        NSString *path = [self containBook:book];
        if (path) {
            NSInteger index = [[[NSUserDefaults standardUserDefaults]objectForKey:path]integerValue];
            if (index<1) {
                index = 1;
            }
            BookPageViewController *pageVC = [[BookPageViewController alloc]initWithNibName:nil bundle:nil pageIndex:index];
            pageVC.bookPath = path;
            [self.navigationController pushViewController:pageVC animated:YES];
        }else{
            if (book.isState != 2) {
                UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"提示" message:@"敬请期待！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert1 show];
                return;
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"是否下载 %@",book.bookName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
            alert.tag = 17803;
            [alert show];
            currntBook = book;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 17803) {
        if (buttonIndex == 1) {
            MiFasciculeBook *bookNow = currntBook;
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *path = [cachePath stringByAppendingFormat:@"/%@",bookNow.zipUri];
            [[AllHttpService sharedHttpService]downLoadAttachmentWithURL:currntBook.zipUri path:path completionHandler:^(){
                NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *toPath = [documentPath stringByAppendingFormat:@"/folder/%@/",bookNow.bookDir];
                ZipArchive *_zip = [[ZipArchive alloc]init];
                if( [_zip UnzipOpenFile:path] )
                {
                    BOOL ret = [_zip UnzipFileTo:toPath overWrite:YES];
                    if( NO==ret )
                    {
                        NSLog(@"解压缩失败");
                    }
                    [_zip UnzipCloseFile];
                    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
                    
                }
                //opencv--save
                NSString *jsonPath = [NSString stringWithFormat:@"%@bookConfig.txt",toPath];
                NSDictionary *bookJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingAllowFragments error:nil];
                int pageCount = [[bookJson objectForKey:@"page"]integerValue];
                NSString *xmlPath = [NSString stringWithFormat:@"%@vocabulary.xml",toPath];
                cv::FileStorage fs([xmlPath UTF8String], cv::FileStorage::WRITE);
                for (int i = 0; i<pageCount; i++) {
                    UIImage *yuanImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@page/%d.jpg",toPath,i+1]];
                    cv::Mat met = [yuanImage getDetectorExtractor];
                    const char *vocabulary = [[NSString stringWithFormat:@"element%d",i]UTF8String];
                    fs<<vocabulary<<met;
                }
                NSLog(@"opencv save vector MAT");
                fs.release();
            }];
        }
    }
}



-(void)requestHaveChange
{
    [self.myCollectView reloadData];
}


-(NSString *)containBook:(MiFasciculeBook *)book
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *bookNameArray = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[path stringByAppendingString:@"/folder/"] error:nil];
    for (NSString *name in bookNameArray) {
        if ([name isEqualToString:book.bookDir]) {
            return [path stringByAppendingFormat:@"/folder/%@",book.bookDir];
        }
    }
    return nil;
}

-(void)downLoadBook:(NSInteger)bookID
{
    MiFasciculeBook *book;
    for (MiFasciculeBook *bookTemp in self.dataArray) {
        if (bookTemp.id == bookID) {
            book = bookTemp;
            break;
        }
    }
    NSString *path = [BOOK_PATH stringByAppendingString:book.bookDir];
    if (![[AllHttpService sharedHttpService].requestDic.allKeys containsObject:book.zipUri]&&!ExistFile(path)) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"是否下载 %@",book.bookName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
        alert.tag = 17803;
        [alert show];
        currntBook = book;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [AllHttpService sharedHttpService].delegate = nil;
    for (ASIHTTPRequest *request in [AllHttpService sharedHttpService].requestDic.allValues) {
        request.downloadProgressDelegate = nil;
    }
}

@end

//
//  ScanViewController.m
//  中文+
//
//  Created by tangce on 14-8-5.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "ScanViewController.h"
#import "LWSelectTagView.h"
#import "BookPageViewController.h"
#import "LWImageCapture.h"
#import "BookCell.h"
#import "UIImage+OpenCV.h"
#import <opencv2/legacy/legacy.hpp>

#define QualifiedDistance 30
#define QualifiedRatio 0.2f

@interface ScanViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,LWImageCaptureDelegate>{
    __weak UICollectionView *myCollectView;
    cv::vector<cv::Mat> save;
}
@property (nonatomic,strong)NSArray *bookArray;
@property (nonatomic,strong)NSString *bookPath;
@property (assign) NSInteger pagNUM;
@property (nonatomic, strong) LWImageCapture *lw_capture;
@property (nonatomic, strong) UIImageView *scanline;

@end

@implementation ScanViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"拍一拍";
    // Do any additional setup after loading the view.
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"index20" ofType:@"png"]] style:UIBarButtonItemStylePlain target:self action:@selector(selectBook:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    NSMutableArray *bookarrayMT = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:BOOK_PATH error:nil]];
    NSString *dsPath = nil;
    for (NSString *str in bookarrayMT) {
        if ([str isEqualToString:@".DS_Store"]) {
            dsPath = str;
        }
    }
    [bookarrayMT removeObject:dsPath];
    self.bookArray = bookarrayMT;
    
    self.lw_capture = [[LWImageCapture alloc]initWithParentView:self.view];
    self.lw_capture.delegate = self;
    self.lw_capture.defaultFPS = 1.5f;
    
    self.scanline = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 4)];
    self.scanline.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"xiantiao" ofType:@"png"]];
    [self.view addSubview:self.scanline];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap:)];
    [self.lw_capture.parentView addGestureRecognizer:tap];
    
    
    if (GetObject(@"ScanBookPath")) {
        NSString *path = [BOOK_PATH stringByAppendingString:GetObject(@"ScanBookPath")];;
        if (ExistFile(path)) {
            self.bookPath = path;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [self initOpenCV];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.lw_capture start];
                });
            });
        }else{
            self.bookPath = nil;
        }
        
    }else{
        self.bookPath = nil;
    }
    [self.lw_capture.captureSession startRunning];
    
//    LWSelectTagView *select = [[LWSelectTagView alloc]initWithFrame:CGRectMake(0, 1000, 90, 15)];
//    select.selectImage = [UIImage imageNamed:@"选择标签.png"];
//    select.unSelectImage = [UIImage imageNamed:@"未选择.png"];
//    select.text = @"不再提醒";
//    select.textColor = [UIColor darkGrayColor];
//    select.textfont = [UIFont systemFontOfSize:11];
//    [self.view addSubview:select];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.bookPath) {
        [self.lw_capture.captureSession startRunning];
        [self.lw_capture start];
    }else{
        [self selectBook:nil];
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self scanlineGo];
}

-(void)viewWillDisappear:(BOOL)animated
{
    SetObject([self.bookPath substringFromIndex:[BOOK_PATH length]], @"ScanBookPath");
    [self.lw_capture stop];
    [self.lw_capture.captureSession stopRunning];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)scanlineGo
{
    [UIView animateWithDuration:5.0f animations:^(){
        CGRect frame = self.scanline.frame;
        if (frame.origin.y<=0) {
            frame.origin.y = self.view.frame.size.height;
        }else if (frame.origin.y>=self.view.frame.size.height){
            frame.origin.y = 0;
        }
        self.scanline.frame = frame;
    }completion:^(BOOL ber){
        if (self.navigationController.topViewController == self) {
            [self scanlineGo];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectBook:(UIButton *)btn
{
    if (self.bookArray.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"本地没有书籍可供选择" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if (!myCollectView) {
        [self.lw_capture stop];
        UICollectionViewFlowLayout *collectLayout = [[UICollectionViewFlowLayout alloc]init];
        collectLayout.minimumLineSpacing = 30;
        collectLayout.minimumInteritemSpacing = 30;
        collectLayout.itemSize = CGSizeMake(150, 208);
        collectLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        collectLayout.sectionInset = UIEdgeInsetsMake(64+40, 20, 0, 20);
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:collectLayout];
        myCollectView = collectionView;
        myCollectView.backgroundColor = [UIColor clearColor];
        UIView *background = [[UIView alloc]init];
        background.backgroundColor = [UIColor whiteColor];
        myCollectView.backgroundView = background;
        myCollectView.dataSource = self;
        myCollectView.delegate = self;
        [myCollectView registerClass:[BookCell class] forCellWithReuseIdentifier:@"TT_TT"];
        [self.view addSubview:myCollectView];
    }else{
        [myCollectView removeFromSuperview];
        if (self.bookPath) {
            [self.lw_capture start];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bookArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookCell *cell = [myCollectView dequeueReusableCellWithReuseIdentifier:@"TT_TT" forIndexPath:indexPath];
    cell.style = BookCellStateNormal;
    
    
    NSString *jsonPath = [NSString stringWithFormat:@"%@/bookConfig.txt",[BOOK_PATH stringByAppendingString:[self.bookArray objectAtIndex:indexPath.row]]];
    NSDictionary *bookJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingAllowFragments error:nil];
    NSString *imagePath = [NSString stringWithFormat:@"%@/page/%ld.jpg",[BOOK_PATH stringByAppendingString:[self.bookArray objectAtIndex:indexPath.row]],(long)[[bookJson objectForKey:@"homePage"] integerValue]];
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
    self.bookPath = [BOOK_PATH stringByAppendingString:[self.bookArray objectAtIndex:indexPath.row]];
    [myCollectView removeFromSuperview];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self initOpenCV];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.lw_capture start];
        });
    });
}

-(void)backgroundTap:(UITapGestureRecognizer *)tap
{
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}




-(void)initOpenCV
{
    NSString *jsonPath = [NSString stringWithFormat:@"%@/bookConfig.txt",self.bookPath];
    NSDictionary *bookJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingAllowFragments error:nil];
    int pageCount = [[bookJson objectForKey:@"page"]integerValue];
////    save.resize(pageCount);
//    save.clear();
//    for (int i = 0; i<pageCount; i++) {
//        UIImage *yuanImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/page/%d.jpg",self.bookPath,i+1]];
//        if (yuanImage) {
//            cv::Mat met = [yuanImage getDetectorExtractor];
//            save.push_back(met);
////            save[i] = met;
//        }else{
//            NSLog(@"少图片 %d",i+1);
//        }
//        
//    }
    
    NSString *xmlPath = [NSString stringWithFormat:@"%@/vocabulary.xml",self.bookPath];
    cv::FileStorage fs([xmlPath UTF8String], cv::FileStorage::READ);
    save.clear();
    for (int i = 0; i<pageCount; i++) {
        cv::Mat met;
        const char *vocabulary = [[NSString stringWithFormat:@"element%d",i]UTF8String];
        fs[vocabulary] >> met;
        save.push_back(met);
    }
    fs.release();
    NSLog(@"opencv get vector MAT");
}


-(void)LWImageCaptureGetImage:(UIImage *)captureImg
{
    [self matchPicture:captureImg];
}

-(void)matchPicture:(UIImage *)matchImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        int qualifiedDMatch = 0;
        NSInteger pagNum = 0;
        cv::Mat nowImage = [matchImage getDetectorExtractor];
        cv::vector<cv::DMatch> matchTemp;
        for (int i = 0; i<save.size(); i++) {
            cv::BruteForceMatcher<cv::Hamming>matcher;
            cv::vector<cv::DMatch> matches;
            if (save[i].cols==nowImage.cols) {
                matcher.match(nowImage,save[i],matches);
                
                int size = matches.size();
                int qualifiedTemp = 0;
                for (int i = 0; i<size; i++) {
                    if (matches[i].distance<QualifiedDistance) {
                        qualifiedTemp++;
                    }
                }
                if (qualifiedTemp>qualifiedDMatch) {
                    qualifiedDMatch = qualifiedTemp;
                    pagNum = i+1;
                    matchTemp = matches;
                }
            }
        }
        NSString *ssst = [NSString stringWithFormat:@"pag:%d--匹配点数:%d-总数:%lu-比率:%f",pagNum,qualifiedDMatch,matchTemp.size(),(float)qualifiedDMatch/(float)matchTemp.size()];
        NSLog(@"%@",ssst);
        float ratio = (float)qualifiedDMatch/(float)matchTemp.size();
        if (pagNum == self.pagNUM && ratio>QualifiedRatio&&pagNum!=0) {
            [self pushBookPageVC:pagNum];
        }
        self.pagNUM = pagNum;
    });
}

-(void)pushBookPageVC:(NSInteger)pagNum
{
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        @synchronized(@"match"){
            if (self.navigationController.topViewController == self) {
                [self.lw_capture stop];
                BookPageViewController *pageVC = [[BookPageViewController alloc]initWithNibName:nil bundle:nil pageIndex:pagNum];
                pageVC.bookPath = self.bookPath;
                [self.navigationController pushViewController:pageVC animated:YES];
            }
        }
    });
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

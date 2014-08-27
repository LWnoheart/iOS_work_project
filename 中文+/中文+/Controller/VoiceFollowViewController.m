//
//  VoiceFollowViewController.m
//  中文+
//
//  Created by tangce on 14-8-11.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "VoiceFollowViewController.h"
#import "MyDataBase.h"
#import "BookCaseViewController.h"
#import "PageVoiceView.h"
#import "BookPageViewController.h"
@interface VoiceFollowViewController ()<UIAlertViewDelegate>{
    UIControl *shadow;
    __weak VoiceCollectData *currentVoice;
}

@end

@implementation VoiceFollowViewController

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
    self.navigationItem.title = @"跟读记录";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    shadow = [[UIControl alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [shadow addTarget:self action:@selector(backGroundTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:shadow];
    
    UIImageView *bookCaseHeader = [[UIImageView alloc]initWithFrame:CGRectMake(0, -287, 768, 287)];
    bookCaseHeader.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"followHead" ofType:@"png"]];
    if (IOS_7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.mytableView.contentInset = UIEdgeInsetsMake(64+287, 0, 0, 0);
    }else{
        self.mytableView.contentInset = UIEdgeInsetsMake(287, 0, 0, 0);
    }
    [self.mytableView addSubview:bookCaseHeader];
    
    self.mytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self loadDataRemoveAll:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ----------------------------------
#pragma mark CustomTableViewMethods

- (NSInteger) mainTable:(UITableView *)mainTable numberOfItemsInSection:(NSInteger)section
{
    if (self.dataArray.count<7) {
        return 7;
    }else{
        return self.dataArray.count;
    }
    
}
- (NSInteger) mainTable:(UITableView *)mainTable numberOfSubItemsforItem:(SDGroupCell *)item atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<self.dataArray.count) {
        VoiceCollectData *data = [self.dataArray objectAtIndex:indexPath.row];
        return [[[MyDataBase shareMyDataBase]getSpliceVoiceByVoiceID:data.voiceID]count];
    }else{
        return 0;
    }
}

- (SDGroupCell *) mainTable:(UITableView *)mainTable setItem:(SDGroupCell *)item forRowAtIndexPath:(NSIndexPath *)indexPath
{
    VoiceCollectData *data = nil;
    if (indexPath.row<self.dataArray.count) {
        data = [self.dataArray objectAtIndex:indexPath.row];
    }
    item.itemText.text = data.name;
    item.firstLabel.text = data.bookName;
    if (data) {
        item.secondLabel.text = [NSString stringWithFormat:@"跟读%d次",data.readCount];
    }else{
        item.secondLabel.text = nil;
    }
    return item;
}
- (SDSubCell *) item:(SDGroupCell *)item setSubItem:(SDSubCell *)subItem forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    VoiceCollectData *data = [self.dataArray objectAtIndex:item.tag];
    VoiceCollectData *subData = [[[MyDataBase shareMyDataBase]getSpliceVoiceByVoiceID:data.voiceID]objectAtIndex:indexPath.row];
    subItem.itemText.text = [formatter stringFromDate:subData.readDate];
    return subItem;
}

- (void) mainTable:(UITableView *)mainTable itemDidChange:(SDGroupCell *)item
{
    VoiceCollectData *data = [self.dataArray objectAtIndex:item.tag];
    NSString *bookPath = [BOOK_PATH stringByAppendingString:data.bookPath];
    if (ExistFile(bookPath)) {
        BookPageViewController *pageVC = [[BookPageViewController alloc]initWithNibName:nil bundle:nil pageIndex:data.pageIndex];
        pageVC.bookPath = bookPath;
        [self.navigationController pushViewController:pageVC animated:YES];
    }else{
        currentVoice = data;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"本地没有书籍: %@,是否去书架下载！",data.bookName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
        alert.tag = 48683;
        [alert show];
    }
}

- (void) item:(SDGroupCell *)item subItemDidChange:(SDSelectableCell *)subItem
{
    VoiceCollectData *data = [self.dataArray objectAtIndex:item.tag];
    VoiceCollectData *subData = [[[MyDataBase shareMyDataBase]getSpliceVoiceByVoiceID:data.voiceID]objectAtIndex:subItem.tag];
    NSString *path = [RECORD_PATH stringByAppendingString:subData.splicePath];
    PageVoiceView *voiceView = [[PageVoiceView alloc]initWithFrame:CGRectMake(0, shadow.bounds.size.height-150, shadow.bounds.size.width, 150) path:path];
    if (voiceView) {
        [shadow addSubview:voiceView];
        [UIView animateWithDuration:0.3f animations:^(){
            CGRect frame = shadow.frame;
            frame.origin.y = 0;
            shadow.frame = frame;
        }completion:^(BOOL ber){
            [voiceView.audioPlayer play];
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"跟读音频已损坏!" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
    }
}


-(void)LWPullRefreshViewPullDownTriggerRefresh:(LWPullRefreshView *)view
{
    [self loadDataRemoveAll:YES];
    [self.mytableView reloadData];
    [view performSelector:@selector(tableViewDidFinishedLoading:) withObject:self.mytableView afterDelay:0.3];
}
-(void)LWPullRefreshViewPullUpTriggerRefresh:(LWPullRefreshView *)view
{
    [self loadDataRemoveAll:NO];
    [self.mytableView reloadData];
    [view performSelector:@selector(tableViewDidFinishedLoading:) withObject:self.mytableView afterDelay:0.3];
}

-(void)loadDataRemoveAll:(BOOL)remove
{
    if (remove) {
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:[[MyDataBase shareMyDataBase]getSpliceVoiceFrom:self.dataArray.count to:15]];
}

#pragma mark ----------------------------------
#pragma mark OtherMethods


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 48683) {
        if (buttonIndex == 1) {
            BookCaseViewController *bookCaseVC = [[BookCaseViewController alloc]initWithNibName:nil bundle:nil];
            bookCaseVC.downLoadBookID = currentVoice.bookID;
            [self.navigationController pushViewController:bookCaseVC animated:YES];
        }
    }
}


-(void)backGroundTap:(UIControl *)view
{
    [UIView animateWithDuration:0.3f animations:^(){
        CGRect frame = shadow.frame;
        frame.origin.y = frame.size.height;
        shadow.frame = frame;
    }completion:^(BOOL ber){
        for (UIView *view in shadow.subviews) {
            [view removeFromSuperview];
        }
    }];
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

//
//  VoiceRecordViewController.m
//  中文+
//
//  Created by tangce on 14-8-11.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "VoiceRecordViewController.h"
#import "VoiceRecordCell.h"
#import "MyDataBase.h"
#import "VoiceCollectData.h"
#import "PageVoiceView.h"
#import "BookCaseViewController.h"
#import "BookPageViewController.h"
@interface VoiceRecordViewController ()<UITableViewDataSource,UITableViewDelegate,VoiceRecordCellDelegate,UIAlertViewDelegate>{
    UIControl *shadow;
    __weak VoiceCollectData *currentVoice;
}


@end

@implementation VoiceRecordViewController

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
    self.mytableView.rowHeight = 100;
    self.mytableView.allowsSelection = NO;
    [self.mytableView registerClass:[VoiceRecordCell class] forCellReuseIdentifier:@"RECORD"];
    
    shadow = [[UIControl alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [shadow addTarget:self action:@selector(backGroundTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:shadow];
    
    UIImageView *bookCaseHeader = [[UIImageView alloc]initWithFrame:CGRectMake(0, -287, 768, 287)];
    
    if (self.style == RecordControllerStyleCollect) {
        self.navigationItem.title = @"我的收藏";
        bookCaseHeader.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"collectHead" ofType:@"png"]];
    }else if (self.style == RecordControllerStyleReaded){
        self.navigationItem.title = @"朗读记录";
        bookCaseHeader.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"langduHead" ofType:@"png"]];
    }
    
    if (IOS_7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.mytableView.contentInset = UIEdgeInsetsMake(64+287, 0, 0, 0);
    }else{
        self.mytableView.contentInset = UIEdgeInsetsMake(287, 0, 0, 0);
    }
    [self.mytableView addSubview:bookCaseHeader];
    
    [self loadDataRemoveAll:YES];
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count<7) {
        return 7;
    }else{
        return self.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.style == RecordControllerStyleCollect) {
        VoiceRecordCell *cell = [self.mytableView dequeueReusableCellWithIdentifier:@"RECORD" forIndexPath:indexPath];
        VoiceCollectData *data = nil;
        if (indexPath.row<self.dataArray.count) {
            data = [self.dataArray objectAtIndex:indexPath.row];
        }
        cell.voiceNameLabel.text = data.name;
        cell.bookNameLabel.text = data.bookName;
        cell.tag = indexPath.row;
        cell.delegate = self;
        return cell;
    }else if (self.style == RecordControllerStyleReaded){
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        VoiceRecordCell *cell = [self.mytableView dequeueReusableCellWithIdentifier:@"RECORD" forIndexPath:indexPath];
        VoiceCollectData *data = nil;
        if (indexPath.row<self.dataArray.count) {
            data = [self.dataArray objectAtIndex:indexPath.row];
        }
        cell.voiceNameLabel.text = data.name;
        cell.bookNameLabel.text = data.bookName;
        cell.timeLabel.text = [formatter stringFromDate:data.readDate];
        if (data) {
            cell.smallLabel.text = [NSString stringWithFormat:@"%d次",data.readCount];
        }else{
            cell.smallLabel.text = nil;
        }
        
        cell.tag = indexPath.row;
        cell.delegate = self;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)VoiceRecordCellPlay:(id)VRCell
{
    NSInteger index = [(UIView *)VRCell tag];
    VoiceCollectData *data = [self.dataArray objectAtIndex:index];
    PageVoiceView *voiceView = [[PageVoiceView alloc]initWithFrame:CGRectMake(0, shadow.bounds.size.height-150, shadow.bounds.size.width, 150) voiceData:data];
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
        currentVoice = data;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"本地没有书籍: %@,是否去书架下载！",data.bookName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
        alert.tag = 48683;
        [alert show];
    }
}

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
-(void)VoiceRecordCellBook:(id)VRCell
{
    NSInteger index = [(UIView *)VRCell tag];
    VoiceCollectData *data = [self.dataArray objectAtIndex:index];
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
    if (self.style == RecordControllerStyleCollect) {
        [self.dataArray addObjectsFromArray:[[MyDataBase shareMyDataBase]getCollectVoiceFrom:self.dataArray.count to:15]];
    }else if (self.style == RecordControllerStyleReaded){
        [self.dataArray addObjectsFromArray:[[MyDataBase shareMyDataBase]getReadedVoiceFrom:self.dataArray.count to:15]];
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

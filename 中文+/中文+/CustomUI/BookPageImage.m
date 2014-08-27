//
//  BookPageImage.m
//  中文+
//
//  Created by tangce on 14-7-2.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "BookPageImage.h"
#import "LWContextMenuView.h"
#import <MediaPlayer/MediaPlayer.h>
//#import <AVFoundation/AVFoundation.h>
//#import "RecordManager.h"
#import "PageVoiceView.h"

#import "UIView+frame.h"
#import "AppDelegate.h"


#define JUMP_HEIGHT 300
@interface BookPageImage ()<LWContextOverlayViewDataSource,LWContextOverlayViewDelegate>{
    UIProgressView *progressV;
    UIButton *playBtn;
}
@property (nonatomic, strong) NSArray *pageJson;
@property (nonatomic, strong) NSString *rootPath;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) UIControl *shadowControl;
//
@property (nonatomic, strong) NSMutableArray *btnArray;

//录音
@end

@implementation BookPageImage

- (id)initWithFrame:(CGRect)frame rootPath:(NSString *)rootPath pageIndex:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.rootPath = rootPath;
        self.pageIndex = index;
        self.btnArray = [[NSMutableArray alloc]init];
        
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:self.bounds];
        NSString *imagePath = [NSString stringWithFormat:@"%@/page/%ld.jpg",rootPath,(long)index];
        imageview.image = [UIImage imageWithContentsOfFile:imagePath];
        [self addSubview:imageview];
        //
        if (![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithFormat:@"%@/%ld",rootPath,(long)index]]) {
            return self;
        }
        NSString *jsonPath = [NSString stringWithFormat:@"%@/%ld/pageConfig.txt",rootPath,(long)index];
        self.pageJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@",self.pageJson);
        //
        for (NSDictionary *rootDic in self.pageJson) {
            NSArray *btnArray = [rootDic objectForKey:@"icoList"];
            float left = [[rootDic objectForKey:@"left"]floatValue]*frame.size.width;
            float top = [[rootDic objectForKey:@"top"]floatValue]*frame.size.height;
            if (btnArray.count>1) {
                LWContextMenuView *contextView = [[LWContextMenuView alloc]initWithFrame:CGRectMake(left, top, 35, 35)];
                contextView.dataSource = self;
                contextView.delegate = self;
                contextView.tag = [[rootDic objectForKey:@"id"]integerValue];
                [self addSubview:contextView];
                [self.btnArray addObject:contextView];
            }else if (btnArray.count == 1){
                NSDictionary *oneBtnDic = [btnArray objectAtIndex:0];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(left, top, 35, 35);
                [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"pagZS%ld",(long)[[oneBtnDic objectForKey:@"icoType"]integerValue]] ofType:@"png"]] forState:UIControlStateNormal];
                btn.tag = [[rootDic objectForKey:@"id"]integerValue];
                [btn addTarget:self action:@selector(oneButtonPress:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
                [self.btnArray addObject:btn];
            }
        }
        self.shadowControl = [[UIControl alloc]initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height)];
        self.shadowControl.tag = 0;
        [self.shadowControl addTarget:self action:@selector(shadowPress) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.shadowControl];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shanle) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shadowPress) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    return self;
}


# pragma mark - json methiods

-(NSDictionary *)getJsonNodeBy:(NSInteger)nodeID inJson:(NSArray *)jsonArray
{
    for (NSDictionary *dic in jsonArray) {
        if ([[dic objectForKey:@"id"]isEqualToNumber:[NSNumber numberWithInteger:nodeID]]) {
            return dic;
        }
    }
    return nil;
}

# pragma mark - ContextMenuView delegate

- (NSInteger) numberOfMenuItems:(LWContextMenuView *)ContextMenuView
{
    NSArray *btnArray = [[self getJsonNodeBy:ContextMenuView.tag inJson:self.pageJson]objectForKey:@"icoList"];
    return btnArray.count;
}

-(UIImage*) imageForItemAtIndex:(NSInteger)index ContextMenuView:(LWContextMenuView *)ContextMenuView
{
    NSArray *btnArray = [[self getJsonNodeBy:ContextMenuView.tag inJson:self.pageJson]objectForKey:@"icoList"];
    NSDictionary *btnInfo = [btnArray objectAtIndex:index];
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"pagZS%ld",(long)[[btnInfo objectForKey:@"icoType"]integerValue]] ofType:@"png"]];
//    return [UIImage imageNamed:[NSString stringWithFormat:@"%ld",(long)[[btnInfo objectForKey:@"icoType"]integerValue]]];
}

- (void) didSelectItemAtIndex:(NSInteger)selectedIndex ContextMenuView:(LWContextMenuView *)ContextMenuView
{
    NSDictionary *dic = [self getJsonNodeBy:ContextMenuView.tag inJson:self.pageJson];
    NSMutableDictionary *btnInfo = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"icoList"]objectAtIndex:selectedIndex]];
    [btnInfo setObject:[dic objectForKey:@"left"] forKey:@"left"];
    [btnInfo setObject:[dic objectForKey:@"top"] forKey:@"top"];
    NSString *fileType = [btnInfo objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"txt"]) {
        [self showTextBy:btnInfo];
    }else if ([fileType isEqualToString:@"pic"]){
        [self showPictureBy:btnInfo];
    }else if ([fileType isEqualToString:@"video"]){
        [self showVideoBy:btnInfo];
    }else if ([fileType isEqualToString:@"voice"]){
        [self showVoiceBy:btnInfo];
    }
    
}

# pragma mark - oneButtonPress
-(void)oneButtonPress:(UIButton *)button
{
    NSDictionary *dic = [self getJsonNodeBy:button.tag inJson:self.pageJson];
    NSMutableDictionary *btnInfo = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"icoList"]objectAtIndex:0]];
    [btnInfo setObject:[dic objectForKey:@"left"] forKey:@"left"];
    [btnInfo setObject:[dic objectForKey:@"top"] forKey:@"top"];
    NSString *fileType = [btnInfo objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"txt"]) {
        [self showTextBy:btnInfo];
    }else if ([fileType isEqualToString:@"pic"]){
        [self showPictureBy:btnInfo];
    }else if ([fileType isEqualToString:@"video"]){
        [self showVideoBy:btnInfo];
    }else if ([fileType isEqualToString:@"voice"]){
        [self showVoiceBy:btnInfo];
    }
}

# pragma mark - Show Infomation By Press

-(void)showTextBy:(NSDictionary *)jsonDic
{
    NSString *textPath = [NSString stringWithFormat:@"%@/%ld/%@",self.rootPath,(long)self.pageIndex,[jsonDic objectForKey:@"fileUri"]];
//    UITextView *textView = [[UITextView alloc]init];
//    textView.font = [UIFont systemFontOfSize:20];
//    textView.editable = NO;
//    textView.text = [NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil];
//    [self.shadowControl addSubview:textView];
    if ([[jsonDic objectForKey:@"showType"]integerValue] == 1) {
        UITextView *textView = [[UITextView alloc]init];
        textView.backgroundColor = [UIColor colorWithRed:222.0/255.0f green:222.0/255.0f blue:222.0/255.0f alpha:1];
        textView.font = [UIFont systemFontOfSize:20];
        textView.editable = NO;
        textView.text = [NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil];
        [self.shadowControl addSubview:textView];
        textView.frame = CGRectMake(0, self.frame.size.height-JUMP_HEIGHT, self.frame.size.width, JUMP_HEIGHT);
        [UIView animateWithDuration:0.3f animations:^(){
            CGRect frame = self.shadowControl.frame;
            frame.origin.y = 0;
            self.shadowControl.frame = frame;
        }];
    }else if ([[jsonDic objectForKey:@"showType"]integerValue] == 2){
        float x = [[jsonDic valueForKey:@"reLeft"]floatValue]*self.frame.size.width;
        float y = [[jsonDic valueForKey:@"reTop"]floatValue]*self.frame.size.height;
        float w = [[jsonDic valueForKey:@"right"]floatValue]*self.frame.size.width-x;
        float h = [[jsonDic valueForKey:@"bottom"]floatValue]*self.frame.size.height-y;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
        label.font = [UIFont systemFontOfSize:20];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil];
        [self.shadowControl addSubview:label];
//        textView.frame = CGRectMake(x, y, w, h);
        CGRect frame = self.shadowControl.frame;
        frame.origin.y = 0;
        self.shadowControl.frame = frame;
        self.shadowControl.tag = 1;
        for (UIView *btn in self.btnArray) {
            btn.hidden = YES;
        }
    }
}

-(void)showVoiceBy:(NSDictionary *)jsonDic
{
    
    PageVoiceView *voiceView = [[PageVoiceView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-150, self.frame.size.width, 150) rootPath:self.rootPath pageIndex:self.pageIndex json:jsonDic];
    
    [self.shadowControl addSubview:voiceView];
    [UIView animateWithDuration:0.3f animations:^(){
        CGRect frame = self.shadowControl.frame;
        frame.origin.y = 0;
        self.shadowControl.frame = frame;
    }completion:^(BOOL ber){
        [voiceView.audioPlayer play];
    }];
    //
}

-(void)showVideoBy:(NSDictionary *)jsonDic
{
    NSString *moviePath = [NSString stringWithFormat:@"%@/%ld/%@",self.rootPath,(long)self.pageIndex,[jsonDic objectForKey:@"fileUri"]];
    
    self.moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL fileURLWithPath:moviePath]];
    self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.backgroundView.backgroundColor = [UIColor colorWithRed:239/255.f green:239/255.f blue:239/255.f alpha:1];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer.view setFrame:CGRectMake(0, self.frame.size.height-JUMP_HEIGHT, self.frame.size.width, JUMP_HEIGHT)];
    [self.shadowControl addSubview:self.moviePlayer.view];
    [UIView animateWithDuration:0.3f animations:^(){
        CGRect frame = self.shadowControl.frame;
        frame.origin.y = 0;
        self.shadowControl.frame = frame;
    }completion:^(BOOL ber){
        [self.moviePlayer play];
    }];
}


-(void)shanle{
    AppDelegate *del = [UIApplication sharedApplication].delegate;
    for (UIView *view in [UIView getViewByClass:NSClassFromString(@"MPKnockoutButton") inView:del.window]) {
        if (view.frame.size.width == 32) {
            view.hidden = YES;
        }
    }
    
}
-(void)showPictureBy:(NSDictionary *)jsonDic
{
    NSString *textPath = [NSString stringWithFormat:@"%@/%ld/%@",self.rootPath,(long)self.pageIndex,[jsonDic objectForKey:@"fileUri"]];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:textPath]];
    [self.shadowControl addSubview:imageView];
    if ([[jsonDic objectForKey:@"showType"]integerValue] == 1) {
        float height = imageView.image.size.height*self.frame.size.width/imageView.image.size.width;
        imageView.frame = CGRectMake(0, self.frame.size.height-height, self.frame.size.width, height);
        [UIView animateWithDuration:0.3f animations:^(){
            CGRect frame = self.shadowControl.frame;
            frame.origin.y = 0;
            self.shadowControl.frame = frame;
        }];
    }else if ([[jsonDic objectForKey:@"showType"]integerValue] == 2){
        float x = [[jsonDic valueForKey:@"reLeft"]floatValue]*self.frame.size.width;
        float y = [[jsonDic valueForKey:@"reTop"]floatValue]*self.frame.size.height;
        float w = [[jsonDic valueForKey:@"right"]floatValue]*self.frame.size.width-x;
        float h = [[jsonDic valueForKey:@"bottom"]floatValue]*self.frame.size.height-y;
        imageView.frame = CGRectMake(x, y, w, h);
        CGRect frame = self.shadowControl.frame;
        frame.origin.y = 0;
        self.shadowControl.frame = frame;
        self.shadowControl.tag = 1;
        for (UIView *btn in self.btnArray) {
            btn.hidden = YES;
        }
    }
}


-(void)shadowPress
{
    if (self.shadowControl.tag == 0) {
        [UIView animateWithDuration:0.3f animations:^(){
            CGRect frame = self.shadowControl.frame;
            frame.origin.y = frame.size.height;
            self.shadowControl.frame = frame;
        }completion:^(BOOL ber){
            for (UIView *view in self.shadowControl.subviews) {
                [view removeFromSuperview];
            }
        }];
    }else{
        CGRect frame = self.shadowControl.frame;
        frame.origin.y = frame.size.height;
        self.shadowControl.frame = frame;
        for (UIView *view in self.shadowControl.subviews) {
            [view removeFromSuperview];
        }
        self.shadowControl.tag = 0;
    }
    if (self.moviePlayer) {
        [self.moviePlayer stop];
    }
    
    self.moviePlayer = nil;
    for (UIView *btn in self.btnArray) {
        btn.hidden = NO;
    }
}

-(void)removeFromSuperview
{
    if (self.moviePlayer) {
        [self.moviePlayer stop];
    }
    [super removeFromSuperview];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
//fileType:voice(voice,video,pic,txt)
//icoType:1,2,3,4(1,发音，2视频，3答案，4拓展)
//showType:1,2(下方弹出层，替换当前位置）
@end

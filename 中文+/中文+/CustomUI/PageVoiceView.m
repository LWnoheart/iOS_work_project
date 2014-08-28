//
//  PageVoiceView.m
//  中文+
//
//  Created by tangce on 14-8-7.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "PageVoiceView.h"
#import "MyDataBase.h"
#import "RecordManager.h"
#import "LWCircleProgressButton.h"
#import "lame.h"


typedef NS_ENUM(NSInteger, PageVoiceViewViewStyle) {
    PageVoiceViewViewStyleBook,
    PageVoiceViewViewStyleRecord,
    PageVoiceViewViewStyleFollow
};

@interface PageVoiceView ()<AVAudioPlayerDelegate,RecordManagerDelegate>{
    NSTimer *stimer;
}
@property (nonatomic,weak) LWCircleProgressButton *playBtn;
@property (nonatomic,weak) LWCircleProgressButton *recordPlayBtn;
@property (nonatomic,weak) LWCircleProgressButton *recordBtn;
@property (nonatomic,weak) UIProgressView *progressV;
@property (nonatomic,strong) VoiceCollectData *voiceData;
@property (nonatomic,strong)AVAudioPlayer *recordPlayer;
@end



@implementation PageVoiceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame rootPath:(NSString *)rootPath pageIndex:(NSInteger)pageIndex json:(NSDictionary *)jsonDic
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *voicePath = [NSString stringWithFormat:@"%@/%ld/%@",rootPath,(long)pageIndex,[jsonDic objectForKey:@"fileUri"]];
        
        NSString *jsonPath = [NSString stringWithFormat:@"%@/bookConfig.txt",rootPath];
        NSDictionary *bookJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingAllowFragments error:nil];
        self.voiceData = [[VoiceCollectData alloc]init];
        self.voiceData.path = [voicePath substringFromIndex:[BOOK_PATH length]];
        self.voiceData.bookName = [bookJson objectForKey:@"bookName"];
        self.voiceData.bookID = [[bookJson objectForKey:@"id"]integerValue];
        self.voiceData.voiceID = [[jsonDic objectForKey:@"id"]integerValue];
        self.voiceData.name = [jsonDic objectForKey:@"fileName"];
        self.voiceData.pageIndex = pageIndex;
        self.voiceData.bookPath = [rootPath substringFromIndex:[BOOK_PATH length]];
        self.voiceData.readDate = [NSDate date];
        [[MyDataBase shareMyDataBase]saveReadedVoice:self.voiceData];
        
        
        [self creatControlsByFrame:frame voicePath:voicePath Style:PageVoiceViewViewStyleBook];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame voiceData:(VoiceCollectData *)voiceData
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        self.voiceData = voiceData;
        NSString *voicePath = [NSString stringWithFormat:@"%@%@",BOOK_PATH,voiceData.path];
        if (!ExistFile(voicePath)) {
            return nil;
        }
        [self creatControlsByFrame:frame voicePath:voicePath Style:PageVoiceViewViewStyleRecord];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame path:(NSString *)path
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!ExistFile(path)) {
            return nil;
        }
        [self creatControlsByFrame:frame voicePath:path Style:PageVoiceViewViewStyleFollow];
        
    }
    return self;
}

-(void)creatControlsByFrame:(CGRect)frame voicePath:(NSString *)voicePath Style:(PageVoiceViewViewStyle)style
{
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:self.bounds];
    imageview.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"backb" ofType:@"png"]];
    [self addSubview:imageview];
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:voicePath] error:nil];
    self.audioPlayer.delegate = self;
    self.audioPlayer.volume = 3;
    [self.audioPlayer prepareToPlay];
    //播放
    LWCircleProgressButton *btn = [LWCircleProgressButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(40, (frame.size.height-120)/2, 120, 120);
    btn.annular = YES;
//    btn.progressTintColor = [UIColor blueColor];
    [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"暂停" ofType:@"png"]] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(voicePlayPress:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    self.playBtn = btn;
    
    if (style == PageVoiceViewViewStyleBook) {
        [RecordManager defaultManager].delegate = self;
        LWCircleProgressButton *btn2 = [LWCircleProgressButton buttonWithType:UIButtonTypeCustom];
        btn2.frame = CGRectMake(180, (frame.size.height-120)/2, 120, 120);
        [btn2 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"录音" ofType:@"png"]] forState:UIControlStateNormal];
        btn2.annular = YES;
//        [btn2 addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
        [btn2 addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn2];
        btn2.hidden = YES;
        self.recordBtn = btn2;
        
        LWCircleProgressButton *btn4 = [LWCircleProgressButton buttonWithType:UIButtonTypeCustom];
        btn4.frame = CGRectMake(320, (frame.size.height-120)/2, 120, 120);
        btn4.annular = YES;
        [btn4 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"播放录音" ofType:@"png"]] forState:UIControlStateNormal];
        [btn4 addTarget:self action:@selector(playRecordVoice:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn4];
        btn4.hidden = YES;
        self.recordPlayBtn = btn4;
    }
    
    if (style != PageVoiceViewViewStyleFollow) {
        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn3.frame = CGRectMake(600, 80, 120, 50);
        if ([[MyDataBase shareMyDataBase]whetherDatabaseHaveCollect:self.voiceData]) {
            [btn3 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"kkkl" ofType:@"png"]] forState:UIControlStateNormal];
        }else{
            [btn3 setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"kk_15" ofType:@"png"]] forState:UIControlStateNormal];
        }
        [btn3 addTarget:self action:@selector(collectVoice:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn3];
    }
    //
    stimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
}


-(void)voicePlayPress:(UIButton *)btn
{
    if (self.audioPlayer.isPlaying) {
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"播放" ofType:@"png"]] forState:UIControlStateNormal];
        [self.audioPlayer pause];
    }else{
        [_recordPlayer stop];
        self.recordPlayer.currentTime = 0;
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"暂停" ofType:@"png"]] forState:UIControlStateNormal];
        [self.audioPlayer play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.playBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"播放" ofType:@"png"]] forState:UIControlStateNormal];
    self.audioPlayer.currentTime = 0;
    self.recordBtn.hidden = NO;
}

- (void)playProgress
{
    //通过音频播放时长的百分比,给progressview进行赋值;
    self.playBtn.progress = self.audioPlayer.currentTime/self.audioPlayer.duration;
    self.recordPlayBtn.progress = self.recordPlayer.currentTime/self.recordPlayer.duration;
}


-(void)collectVoice:(UIButton *)btn
{
    
    if ([[MyDataBase shareMyDataBase]whetherDatabaseHaveCollect:self.voiceData]) {
        [[MyDataBase shareMyDataBase]deleteCollectVoice:self.voiceData];
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"kk_15" ofType:@"png"]] forState:UIControlStateNormal];
    }else{
        [[MyDataBase shareMyDataBase]saveCollectVoice:self.voiceData];
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"kkkl" ofType:@"png"]] forState:UIControlStateNormal];
    }
}



-(void)recordStart:(UIButton *)btn
{
    if (![RecordManager defaultManager].isRecord) {
        self.playBtn.userInteractionEnabled = NO;
        self.recordPlayBtn.userInteractionEnabled = NO;
        if (self.audioPlayer.isPlaying) {
            [self.audioPlayer stop];
            [self.playBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"播放" ofType:@"png"]] forState:UIControlStateNormal];
            self.audioPlayer.currentTime = 0;
        }
        if (self.recordPlayer.isPlaying) {
            [_recordPlayer stop];
            self.recordPlayer.currentTime = 0;
        }
        if (!ExistFile(RECORD_PATH)) {
            CreatFile(RECORD_PATH)
        }
        [self.recordBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"录音-停止" ofType:@"png"]] forState:UIControlStateNormal];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *path = [NSString stringWithFormat:@"%@%@(1).caf",RECORD_PATH,[formatter stringFromDate:[NSDate date]]];
        [[RecordManager defaultManager]startRecordVoiceToPath:path];
    }else{
        if ([[RecordManager defaultManager]stopRecordVoive]) {
            NSString *inPath = [RecordManager defaultManager].currentRecordPath;
            self.voiceData.splicePath = [inPath substringFromIndex:[RECORD_PATH length]];;
            self.voiceData.readDate = [NSDate date];
            [[MyDataBase shareMyDataBase]saveSpliceVoice:self.voiceData];
            self.recordPlayBtn.hidden = NO;
        }
        [self.recordBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"录音" ofType:@"png"]] forState:UIControlStateNormal];
        self.recordBtn.progress = 0;
        self.playBtn.userInteractionEnabled = YES;
        self.recordPlayBtn.userInteractionEnabled = YES;
    }
}


-(void)recordStop:(UIButton *)btn
{
    if ([[RecordManager defaultManager]stopRecordVoive]) {
        NSString *inPath = [RecordManager defaultManager].currentRecordPath;
        self.voiceData.splicePath = [inPath substringFromIndex:[RECORD_PATH length]];;
        self.voiceData.readDate = [NSDate date];
        [[MyDataBase shareMyDataBase]saveSpliceVoice:self.voiceData];
        self.recordPlayBtn.hidden = NO;
    }
    self.recordBtn.progress = 0;
    self.playBtn.userInteractionEnabled = YES;
    self.recordPlayBtn.userInteractionEnabled = YES;
}

-(void)recordVoiceDetection:(double)lowPassResults
{
    if (lowPassResults>1) {
        lowPassResults = 1;
    }
    self.recordBtn.progress = lowPassResults;
}

-(void)playRecordVoice:(UIButton *)btn
{
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        [self.playBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"播放" ofType:@"png"]] forState:UIControlStateNormal];
        self.audioPlayer.currentTime = 0;
    }
    if (!self.recordPlayer.isPlaying) {
        self.recordPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[RecordManager defaultManager].currentRecordPath] error:nil];
        self.recordPlayer.volume = 3;
        [self.recordPlayer prepareToPlay];
        [self.recordPlayer play];
    }
}




-(void)removeFromSuperview
{
    [_audioPlayer stop];
    [_recordPlayer stop];
    [stimer invalidate];
    [[RecordManager defaultManager]stopRecordVoive];
}


-(void)dealloc
{
    [_audioPlayer stop];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

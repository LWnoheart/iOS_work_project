//
//  RecordManager.m
//  中文+
//
//  Created by tangce on 14-7-4.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "RecordManager.h"
#import "AppDelegate.h"

@interface RecordManager (){
    NSMutableArray *audioMixParams;
    
    NSTimer *timer;
    __weak UIImageView *recorderImage;
}
@property (nonatomic, strong) AVAudioRecorder *recorderV;

@end


@implementation RecordManager
static RecordManager *myRecord = nil;
+(RecordManager *)defaultManager
{
    @synchronized(self){
        if(myRecord == nil){
            myRecord = [[RecordManager alloc] init];
        }
    }
    return myRecord;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if (!myRecord) {
            myRecord = [super allocWithZone:zone];
            myRecord.useVoiceDetection = NO;
            return myRecord;
        }
    }
    return myRecord;
}


# pragma mark - 录音
-(void)startRecordVoiceToPath:(NSString *)path
{
    if (self.useVoiceDetection) {
        AppDelegate *del = [UIApplication sharedApplication].delegate;
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 75, 110)];
        imageview.center = CGPointMake(del.window.bounds.size.width/2, del.window.bounds.size.height/2);
        [del.window addSubview:imageview];
        recorderImage = imageview;
    }
    
    
    _isRecord = YES;
    _currentRecordPath = path;
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryRecord error:nil];
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
//    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
//    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100#/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:96000] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16#、24、32
    [recordSetting setValue:[NSNumber numberWithInt:32] forKey:AVEncoderBitRateKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
    
    NSError *error;
    //初始化
    self.recorderV = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:path] settings:recordSetting error:&error];
    
    //开启音量检测
    self.recorderV.meteringEnabled = YES;
    [self.recorderV prepareToRecord];
    [self.recorderV record];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    
}


-(BOOL)stopRecordVoive
{
    if (!self.recorderV.isRecording) {
        return NO;
    }
    BOOL ber;
    if (self.recorderV.currentTime<1) {
        ber = NO;
    }else{
        ber = YES;
    }
    
    [timer invalidate];
    [[AVAudioSession sharedInstance]setActive:NO error:nil];
    [self.recorderV stop];
    if (self.useVoiceDetection) {
        [recorderImage removeFromSuperview];
    }
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    if (!ber) {
        [self removeRecordVoiceByPath:nil];
    }
    _isRecord = NO;
    return ber;
}

-(void)removeRecordVoiceByPath:(NSString *)path
{
    if (!path) {
        path = self.currentRecordPath;
    }
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
}


- (void)detectionVoice
{
    [self.recorderV updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [self.recorderV peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    if (self.delegate&&[self.delegate respondsToSelector:@selector(recordVoiceDetection:)]) {
        [self.delegate recordVoiceDetection:lowPassResults];
    }
    //最大50  0
    //图片 小-》大
    if (0<lowPassResults<=0.06) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<lowPassResults<=0.13) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<lowPassResults<=0.20) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<lowPassResults<=0.27) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<lowPassResults<=0.34) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<lowPassResults<=0.41) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<lowPassResults<=0.48) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<lowPassResults<=0.55) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<lowPassResults<=0.62) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<lowPassResults<=0.69) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<lowPassResults<=0.76) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<lowPassResults<=0.83) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<lowPassResults<=0.9) {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [recorderImage setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
    
}



# pragma mark - 音频合成
- (void) setUpAndAddAudioAtPath:(NSURL*)assetURL toComposition:(AVMutableComposition *)composition start:(CMTime)start dura:(CMTime)dura offset:(CMTime)offset{
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    NSError *error = nil;
    BOOL ok = NO;
    
    CMTime startTime = start;
    CMTime trackDuration = dura;
    CMTimeRange tRange = CMTimeRangeMake(startTime, trackDuration);
    
    //Set Volume
    AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [trackMix setVolume:0.8f atTime:startTime];
    [audioMixParams addObject:trackMix];
    
    //Insert audio into track  //offset CMTimeMake(0, 44100)
    ok = [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:offset error:&error];
}
- (void) exportSyntheticAudioM4AByPath:(NSString *)path1 Path:(NSString *)path2 outPath:(NSString *)outPath complete:(void (^)(void))handler
{
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    audioMixParams = [[NSMutableArray alloc] initWithObjects:nil];
    
    //Add Audio Tracks to Composition
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"倍儿爽" ofType:@"mp3"];
    NSURL *assetURL1 = [NSURL fileURLWithPath:path1];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL1 options:nil];
    CMTime startTime = CMTimeMakeWithSeconds(0, 1);
    CMTime trackDuration = songAsset.duration;
    
    [self setUpAndAddAudioAtPath:assetURL1 toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(14*44100, 44100)];
    
//    path = [[NSBundle mainBundle] pathForResource:@"愿得一人心" ofType:@"mp3"];
    NSURL *assetURL2 = [NSURL fileURLWithPath:path2];
    [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(0, 44100)];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithArray:audioMixParams];
    
    //If you need to query what formats you can export to, here's a way to find out
    NSLog (@"compatible presets for songAsset: %@",
           [AVAssetExportSession exportPresetsCompatibleWithAsset:composition]);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: composition
                                      presetName: AVAssetExportPresetAppleM4A];
    exporter.audioMix = audioMix;
    exporter.outputFileType = @"public.mp3";
//    NSString *fileName = @"someFilename";
//    NSString *exportFile = [NSHomeDirectory() stringByAppendingFormat: @"/%@.m4a", fileName];
    
    // set up export
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outPath error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:outPath];
    exporter.outputURL = exportURL;
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        NSInteger exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed:{
                NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                break;
            }
                
            case AVAssetExportSessionStatusCompleted: NSLog (@"AVAssetExportSessionStatusCompleted"); break;
            case AVAssetExportSessionStatusUnknown: NSLog (@"AVAssetExportSessionStatusUnknown"); break;
            case AVAssetExportSessionStatusExporting: NSLog (@"AVAssetExportSessionStatusExporting"); break;
            case AVAssetExportSessionStatusCancelled: NSLog (@"AVAssetExportSessionStatusCancelled"); break;
            case AVAssetExportSessionStatusWaiting: NSLog (@"AVAssetExportSessionStatusWaiting"); break;
            default:  NSLog (@"didn't get export status"); break;
        }
        handler();
    }];
    
    //    // start up the export progress bar
    //    progressView.hidden = NO;
    //    progressView.progress = 0.0;
    //    [NSTimer scheduledTimerWithTimeInterval:0.1
    //                                     target:self
    //                                   selector:@selector (updateExportProgress:)
    //                                   userInfo:exporter
    //                                    repeats:YES];
    
}



# pragma mark - 音频拼接

-(void)splicingVoiceByPath:(NSString *)path1 path:(NSString *)path2 outPath:(NSString *)outPath
{
    
    NSData *data1 = [NSData dataWithContentsOfFile:path1];
    
    NSData *data2 = [NSData dataWithContentsOfFile:path2];
    
    NSMutableData *sounds = [NSMutableData alloc];
    [sounds appendData:data1];
    [sounds appendData:data2];
    [sounds writeToFile:outPath atomically:YES];
}
@end

//
//  RootViewController.m
//  中文+
//
//  Created by tangce on 14-7-4.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "RootViewController.h"
#import "BookCaseViewController.h"
#import "ScanViewController.h"
#import "VoiceRecordViewController.h"
#import "VoiceFollowViewController.h"
#import "AboutViewController.h"

#import "MyDataBase.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
    self.navigationItem.title = @"首页";
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cameraPress:(UIButton *)sender {
    ScanViewController *scanVC = [[ScanViewController alloc]init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (IBAction)bookPress:(UIButton *)sender {
    BookCaseViewController *bookVC = [[BookCaseViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:bookVC animated:YES];
}
- (IBAction)readRecordPress:(UIButton *)sender {
    VoiceRecordViewController *collectVC = [[VoiceRecordViewController alloc]initWithNibName:nil bundle:nil];
    collectVC.style = RecordControllerStyleReaded;
    [self.navigationController pushViewController:collectVC animated:YES];
}
- (IBAction)followRecordPress:(id)sender {
    VoiceFollowViewController *followVC = [[VoiceFollowViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:followVC animated:YES];
}
- (IBAction)collectionPress:(UIButton *)sender {
    VoiceRecordViewController *collectVC = [[VoiceRecordViewController alloc]initWithNibName:nil bundle:nil];
    collectVC.style = RecordControllerStyleCollect;
    [self.navigationController pushViewController:collectVC animated:YES];
}
- (IBAction)aboutUsPress:(UIButton *)sender {
//    NSString *bookPath = [BOOK_PATH stringByAppendingString:@"02"];
//    if (!ExistFile(bookPath)) {
//        return;
//    }
//    static NSInteger badVoiceID = 0;
//    NSArray *array = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:bookPath error:nil];
//    for (NSString *ssPath in array) {
//        NSString *wenPath = [bookPath stringByAppendingPathComponent:ssPath];
//        NSArray *ssarray = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:wenPath error:nil];
//        for (NSString *tingPath in ssarray) {
//            if ([tingPath hasSuffix:@".mp3"]) {
//                VoiceCollectData *data = [[VoiceCollectData alloc]init];
//                data.path = [[wenPath stringByAppendingPathComponent:tingPath] substringFromIndex:[BOOK_PATH length]];
//                data.bookPath = [bookPath substringFromIndex:[BOOK_PATH length]];
//                data.pageIndex = ssPath.integerValue;
//                data.voiceID = badVoiceID;
//                data.name = tingPath;
//                NSLog(@"%@",ssPath);
//                [[MyDataBase shareMyDataBase]saveReadedVoice:data];
//                badVoiceID++;
//            }
//        }
//    }
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ewf" message:@"hehehehehe" delegate:nil cancelButtonTitle:@"fwwfewfv" otherButtonTitles:nil, nil];
//    [alert show];
//    RemoveFile(BOOK_PATH);
    AboutViewController *aboutVC = [[AboutViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:aboutVC animated:YES];
}
@end

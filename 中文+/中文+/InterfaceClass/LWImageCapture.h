//
//  LWImageCapture.h
//  草破库
//
//  Created by tangce on 14-8-1.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol LWImageCaptureDelegate;

@interface LWImageCapture : NSObject
@property (nonatomic, strong, readonly) AVCaptureSession* captureSession;
@property (nonatomic, strong, readonly) AVCaptureConnection* videoCaptureConnection;

@property (nonatomic, readonly) BOOL running;
//@property (nonatomic, readonly) BOOL captureSessionLoaded;

@property (nonatomic, assign) float defaultFPS;
@property (nonatomic, assign) AVCaptureDevicePosition defaultAVCaptureDevicePosition;
@property (nonatomic, assign) AVCaptureVideoOrientation defaultAVCaptureVideoOrientation;

@property (nonatomic, strong) NSString *const defaultAVCaptureSessionPreset;

@property (nonatomic, strong, readonly) UIView* parentView;

@property (nonatomic, strong, readonly) UIImage *captureImage;
@property (nonatomic, weak) id<LWImageCaptureDelegate>delegate;
- (void)start;
- (void)stop;
//- (void)switchCameras;

- (id)initWithParentView:(UIView*)parent;

@end

@protocol LWImageCaptureDelegate <NSObject>

-(void)LWImageCaptureGetImage:(UIImage *)captureImg;

@end

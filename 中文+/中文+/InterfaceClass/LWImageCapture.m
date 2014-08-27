//
//  LWImageCapture.m
//  草破库
//
//  Created by tangce on 14-8-1.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "LWImageCapture.h"



@interface LWImageCapture ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    NSTimer *timer;
}

@end

@implementation LWImageCapture


-(id)init
{
    self = [super init];
    if (self) {
        NSError *error;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //    device.flashMode = AVCaptureFlashModeOn;
        [device lockForConfiguration:nil];
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;//adjustingFocus
        }
        [device unlockForConfiguration];
        AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!captureInput)
        {
            NSLog(@"Error: %@", error);
        }
        
        // Update thanks to Jake Marsh who points out not to use the main queue
        dispatch_queue_t queue = dispatch_queue_create("com.myapp.tasks.grabcameraframes", NULL);
        AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        captureOutput.alwaysDiscardsLateVideoFrames = YES;
        [captureOutput setSampleBufferDelegate:self queue:queue];
//        dispatch_release(queue); // Will not work when uncommented -- apparently reference count is altered by setSampleBufferDelegate:queue:
        
        NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
        [captureOutput setVideoSettings:settings];
        
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession addInput:captureInput];
        [_captureSession addOutput:captureOutput];
        
        
        //
        self.defaultFPS = 1.0f;
        _running = NO;
    }
    return self;
}


-(id)initWithParentView:(UIView *)parent
{
    self = [self init];
    if (self) {
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession: _captureSession];
        preview.frame = parent.bounds;
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _parentView = [[UIView alloc]initWithFrame:parent.bounds];
        [_parentView.layer addSublayer:preview];
        [parent addSubview:_parentView];
    }
    return self;
}
# pragma mark - 录音
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool
    {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef newImage = CGBitmapContextCreateImage(context);
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        _captureImage = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
        
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        CGImageRelease(newImage);
        
    }
}
# pragma mark - 录音

-(void)start
{
//    [_captureSession startRunning];
    if (!self.running) {
        timer = [NSTimer scheduledTimerWithTimeInterval:self.defaultFPS target:self selector:@selector(captureAndReturnImage) userInfo:nil repeats:YES];
        _running = YES;
    }
}

-(void)stop
{
//    [_captureSession stopRunning];
    [timer invalidate];
    _running = NO;
}

-(void)captureAndReturnImage
{
    UIImage *newImage;
    CGSize parentSize = _parentView.frame.size;
    float zjl = 0;
    if (parentSize.height/parentSize.width<_captureImage.size.height/_captureImage.size.width) {
        zjl = _captureImage.size.height-(parentSize.height/parentSize.width*_captureImage.size.width);
    }else if (parentSize.height/parentSize.width>_captureImage.size.height/_captureImage.size.width){
        zjl = -(_captureImage.size.width-(parentSize.width/parentSize.height*_captureImage.size.height));
    }
    if (zjl==0) {
        newImage = _captureImage;
    }else{
        CGRect rect;
        if (zjl>0) {
            rect = CGRectMake(zjl/2, 0, _captureImage.size.height-zjl, _captureImage.size.width);
        }else{
            zjl = -zjl;
            rect = CGRectMake(0, zjl/2, _captureImage.size.height, _captureImage.size.width-zjl);
        }
        CGImageRef captureCG = [_captureImage CGImage];
        CGImageRef jianqieCG = CGImageCreateWithImageInRect(captureCG, rect);
        newImage = [UIImage imageWithCGImage:jianqieCG scale:1.0 orientation:UIImageOrientationRight];
//        CGImageRelease(captureCG);
        CGImageRelease(jianqieCG);
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(LWImageCaptureGetImage:)]) {
        [self.delegate LWImageCaptureGetImage:newImage];
    }
}
# pragma mark - 录音

-(void)setDefaultFPS:(float)defaultFPS
{
    if (self.running) {
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:defaultFPS target:self selector:@selector(captureAndReturnImage) userInfo:nil repeats:YES];
    }
    _defaultFPS = defaultFPS;
}


-(void)setDefaultAVCaptureDevicePosition:(AVCaptureDevicePosition)defaultAVCaptureDevicePosition
{
    
    [self.captureSession beginConfiguration];
    for (AVCaptureInput *input in self.captureSession.inputs) {
        [self.captureSession removeInput:input];
    }
    AVCaptureDevice *device;
    for (AVCaptureDevice *deviceT in [AVCaptureDevice devices]) {
        if (device.position == defaultAVCaptureDevicePosition) {
            device = deviceT;
        }
    }
    [device lockForConfiguration:nil];
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;//adjustingFocus
    }
    [device unlockForConfiguration];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if ([self.captureSession canAddInput:captureInput]) {
        [self.captureSession addInput:captureInput];
    }
    [self.captureSession commitConfiguration];
}

-(void)setDefaultAVCaptureSessionPreset:(NSString *)defaultAVCaptureSessionPreset
{
    
}
-(void)setDefaultAVCaptureVideoOrientation:(AVCaptureVideoOrientation)defaultAVCaptureVideoOrientation
{
    
}
@end

//
//  UIImage+OpenCV.h
//  中文+
//
//  Created by tangce on 14-8-5.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/core/core_c.h>
#import <opencv2/highgui/ios.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/features2d/features2d.hpp>
@interface UIImage (OpenCV)
+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;
-(UIImage *)getBySize:(CGSize)size;
-(cv::Mat)getDetectorExtractor;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;
@end

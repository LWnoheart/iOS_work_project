//
//  BookCell.m
//  中文+
//
//  Created by tangce on 14-6-30.
//  Copyright (c) 2014年 tangce. All rights reserved.
//

#import "BookCell.h"
#import "ASIProgressDelegate.h"


@interface BookCell ()<ASIProgressDelegate>{
    __weak UIView *GrayView;
    __weak UILabel *proportion;
}

@end


@implementation BookCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:self.image];
        //
        
        // Initialization code
    }
    return self;
}

-(void)setStyle:(BookCellState)style
{
    _style = style;
    switch (style) {
        case BookCellStateNormal:
        {
            [GrayView removeFromSuperview];
            [proportion removeFromSuperview];
        }
            break;
            case BookCellStateDownLoad:
        {
            if (!GrayView) {
                UIView *view = [[UIView alloc]init];
                GrayView = view;
                GrayView.alpha = 0.5;
                GrayView.backgroundColor = [UIColor blackColor];
                [self.contentView addSubview:GrayView];
            }
            GrayView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            if (!proportion) {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, self.frame.size.height-20, self.frame.size.width-60*2, 20)];
                proportion = label;
                proportion.font = [UIFont systemFontOfSize:14];
                proportion.backgroundColor = [UIColor blackColor];
                proportion.textColor = [UIColor whiteColor];
                proportion.textAlignment = NSTextAlignmentCenter;
                [self.contentView addSubview:proportion];
            }
            proportion.text = @"请稍候..";
        }
            break;
            case BookCellStateGray:
        {
            [proportion removeFromSuperview];
            if (!GrayView) {
                UIView *view = [[UIView alloc]init];
                GrayView = view;
                GrayView.alpha = 0.5;
                GrayView.backgroundColor = [UIColor blackColor];
                [self.contentView addSubview:GrayView];
            }
            GrayView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
        default:
            break;
    }
}


- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    float readBye = request.totalBytesRead/1000;
    float totalBye = request.contentLength/1000;
    int per = readBye/totalBye*100;
    NSString *labelStr = [NSString stringWithFormat:@"%d%%",per];
    if (per==100) {
        labelStr = @"解压中..";
    }
    proportion.text = labelStr;
    float kkl = self.frame.size.height*readBye/totalBye;
    GrayView.frame = CGRectMake(0, kkl, self.frame.size.width, self.frame.size.height-kkl);
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

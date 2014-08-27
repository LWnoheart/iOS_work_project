//
//  LWvcWithTableview.h
//  聚城生活
//
//  Created by 李巍 on 13-12-20.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, LWPullRefreshViewStyle) {
    LWPullRefreshViewStylePullDown,
    LWPullRefreshViewStylePullUp
};

@protocol LWPullRefreshViewDelegate;

@interface LWPullRefreshView : UIView

@property (nonatomic, weak) id <LWPullRefreshViewDelegate> delegate;
-(id)initWithFrame:(CGRect)frame style:(LWPullRefreshViewStyle)style;

-(void)refreshDateOfLastUpdated;
-(void)tableViewDidScroll:(UIScrollView *)scrollView;
-(void)tableViewDidEndDragging:(UIScrollView *)scrollView;
-(void)tableViewDidFinishedLoading:(UIScrollView *)scrollView;
@end



@interface LWvcWithTableview : UIViewController

@property (nonatomic, strong) UITableView *mytableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) LWPullRefreshView *refreshHeaderView;
@property (nonatomic, weak) LWPullRefreshView *refreshFooterView;

//-(void)creatRefreshView;
//-(void)deleteRefreshView;

@end


@protocol LWPullRefreshViewDelegate <NSObject>

-(void)LWPullRefreshViewPullDownTriggerRefresh:(LWPullRefreshView *)view;
-(void)LWPullRefreshViewPullUpTriggerRefresh:(LWPullRefreshView *)view;
@optional
- (NSDate*)LWPullRefreshViewDateOfLastUpdated:(LWPullRefreshView *)view;
- (BOOL)LWPullRefreshViewCanRefreshing:(LWPullRefreshView *)view;
@end
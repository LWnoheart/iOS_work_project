//
//  LWvcWithTableview.m
//  聚城生活
//
//  Created by 李巍 on 13-12-20.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import "LWvcWithTableview.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define TABLEVIEW_COLOR [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


typedef NS_ENUM(NSInteger, LWPullRefreshViewState) {
    LWPullRefreshViewCanRefresh,
    LWPullRefreshViewNormal,
    LWPullRefreshViewRefreshing
};


@interface LWPullRefreshView ()

@property (nonatomic, assign) LWPullRefreshViewState state;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) CALayer *statusImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) LWPullRefreshViewStyle style;
@property (nonatomic, assign) float offsetTemp;
@end

@implementation LWPullRefreshView

-(id)initWithFrame:(CGRect)frame style:(LWPullRefreshViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        //
        if (style != LWPullRefreshViewStylePullDown && style != LWPullRefreshViewStylePullUp) {
            return nil;
        }
        //65ff
		_dateLabel = [[UILabel alloc] init];
        if (style == LWPullRefreshViewStylePullDown) {
            _dateLabel.frame = CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f);
        }else{
            _dateLabel.frame = CGRectMake(0.0f, 35.0f, self.frame.size.width, 20.0f);
        }
		_dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_dateLabel.font = [UIFont systemFontOfSize:12.0f];
		_dateLabel.textColor = TEXT_COLOR;
		_dateLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		_dateLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_dateLabel.backgroundColor = [UIColor clearColor];
		_dateLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_dateLabel];
		
		_statusLabel = [[UILabel alloc] init];
        if (style == LWPullRefreshViewStylePullDown) {
            _statusLabel.frame = CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f);
        }else{
            _statusLabel.frame = CGRectMake(0.0f, 65-48, self.frame.size.width, 20.0f);
        }
		_statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		_statusLabel.textColor = TEXT_COLOR;
		_statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		_statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_statusLabel.backgroundColor = [UIColor clearColor];
		_statusLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_statusLabel];
		
		_statusImage = [CALayer layer];
		_statusImage.contentsGravity = kCAGravityResizeAspect;
        if (style == LWPullRefreshViewStylePullDown) {
            _statusImage.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
            _statusImage.contents = (id)[UIImage imageNamed:@"下拉箭头.png"].CGImage;
        }else{
            _statusImage.frame = CGRectMake(25.0f, 0, 30.0f, 55.0f);
            _statusImage.contents = (id)[UIImage imageNamed:@"上拉箭头.png"].CGImage;
        }
		
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			_statusImage.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:_statusImage];
		
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if (style == LWPullRefreshViewStylePullDown) {
            _activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        }else{
            _activityView.frame = CGRectMake(25.0f, 65 - 38.0f, 20.0f, 20.0f);
        }
		[self addSubview:_activityView];
		
		
		self.state = LWPullRefreshViewNormal;

    }
    return self;
}

-(void)setState:(LWPullRefreshViewState)state
{
    switch (state) {
        case LWPullRefreshViewCanRefresh:
        {
            if (self.style == LWPullRefreshViewStylePullDown) {
                _statusLabel.text = NSLocalizedString(@"松开刷新..", @"Release to refresh status");
            }else{
                _statusLabel.text = NSLocalizedString(@"松开加载更多..", @"Release to refresh status");
            }
            
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_statusImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
        }
            break;
        case LWPullRefreshViewNormal:
        {
            if (self.state == LWPullRefreshViewCanRefresh) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_statusImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			if (self.style == LWPullRefreshViewStylePullDown) {
                _statusLabel.text = NSLocalizedString(@"下拉刷新..", @"Pull down to refresh status");
            }else{
                _statusLabel.text = NSLocalizedString(@"上拉加载更多..", @"Pull down to refresh status");
            }
			
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_statusImage.hidden = NO;
			_statusImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
//			[self refreshDateOfLastUpdated];
        }
            break;
        case LWPullRefreshViewRefreshing:
        {
            if (self.style == LWPullRefreshViewStylePullDown) {
                _statusLabel.text = NSLocalizedString(@"刷新中...", @"Loading Status");
            }else{
                _statusLabel.text = NSLocalizedString(@"加载中...", @"Loading Status");
            }
            
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_statusImage.hidden = YES;
			[CATransaction commit];
        }
            break;
        default:
            break;
    }
    
    _state = state;
}



-(void)refreshDateOfLastUpdated
{
    if (self.delegate && [_delegate respondsToSelector:@selector(LWPullRefreshViewDateOfLastUpdated:)]) {
		
		NSDate *date = [_delegate LWPullRefreshViewDateOfLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
		[formatter setDateFormat:@"yyyy/MM/dd hh:mm:a"];
		_dateLabel.text = [NSString stringWithFormat:@"上次更新时间: %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_dateLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_dateLabel.text = nil;
		
	}
}

-(void)tableViewDidScroll:(UIScrollView *)scrollView
{
    if (self.state != LWPullRefreshViewRefreshing) {
		if (self.style == LWPullRefreshViewStylePullDown) {
            if (self.state == LWPullRefreshViewCanRefresh && scrollView.contentOffset.y > -65.0f-self.offsetTemp && scrollView.contentOffset.y < -self.offsetTemp) {
                [self setState:LWPullRefreshViewNormal];
            } else if (self.state == LWPullRefreshViewNormal && scrollView.contentOffset.y < -65.0f-self.offsetTemp) {
                [self setState:LWPullRefreshViewCanRefresh];
            }
        }else if (self.style == LWPullRefreshViewStylePullUp){
            if (self.state == LWPullRefreshViewCanRefresh && scrollView.contentOffset.y+scrollView.frame.size.height > scrollView.contentSize.height && scrollView.contentOffset.y+scrollView.frame.size.height <= (65.0f+scrollView.contentSize.height)) {
                [self setState:LWPullRefreshViewNormal];
            } else if (self.state == LWPullRefreshViewNormal && scrollView.contentOffset.y+scrollView.frame.size.height >(65.0f+scrollView.contentSize.height)) {
                [self setState:LWPullRefreshViewCanRefresh];
            }
        }
	}
}

-(void)tableViewDidEndDragging:(UIScrollView *)scrollView
{
    BOOL _loading = YES;
	if (self.delegate &&[self.delegate respondsToSelector:@selector(LWPullRefreshViewCanRefreshing:)]) {
		_loading = [self.delegate LWPullRefreshViewCanRefreshing:self];
	}
	if (self.style == LWPullRefreshViewStylePullDown && self.state ==LWPullRefreshViewCanRefresh && _loading && scrollView.contentOffset.y <= - 65.0f-self.offsetTemp) {
        
		if (self.delegate && [self.delegate respondsToSelector:@selector(LWPullRefreshViewPullDownTriggerRefresh:)]) {
			[self.delegate LWPullRefreshViewPullDownTriggerRefresh:self];
		}
		[self setState:LWPullRefreshViewRefreshing];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f+self.offsetTemp, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
        
    }else if (self.style == LWPullRefreshViewStylePullUp && self.state ==LWPullRefreshViewCanRefresh && _loading && scrollView.contentOffset.y+scrollView.frame.size.height >= (65.0f+scrollView.contentSize.height)){
        if (self.delegate && [self.delegate respondsToSelector:@selector(LWPullRefreshViewPullUpTriggerRefresh:)]) {
			[self.delegate LWPullRefreshViewPullUpTriggerRefresh:self];
		}
        [self setState:LWPullRefreshViewRefreshing];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(self.offsetTemp, 0.0f, 60.0f, 0.0f);
		[UIView commitAnimations];
    }
}

-(void)tableViewDidFinishedLoading:(UIScrollView *)scrollView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [scrollView setContentInset:UIEdgeInsetsMake(self.offsetTemp, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
	
	[self setState:LWPullRefreshViewNormal];
    [self refreshDateOfLastUpdated];
}

@end

















@interface LWvcWithTableview ()<UITableViewDataSource,UITableViewDelegate,LWPullRefreshViewDelegate>
@property (nonatomic,assign) NSInteger tableviewOffset;

@end

@implementation LWvcWithTableview
 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mytableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mytableView.delegate = self;
    self.mytableView.dataSource = self;
    self.mytableView.backgroundColor = TABLEVIEW_COLOR;
    self.mytableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    UIView *footView = [[UIView alloc]init];
    self.mytableView.tableFooterView = footView;
    [self.view addSubview:self.mytableView];
    
    
    [self.mytableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"tableviewOffset" options:NSKeyValueObservingOptionNew context:nil];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableviewOffset = self.mytableView.contentInset.top;
    self.refreshHeaderView.offsetTemp = self.tableviewOffset;
    self.refreshFooterView.offsetTemp = self.tableviewOffset;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        if (!self.refreshHeaderView) {
            LWPullRefreshView *refreshHeaderView = [[LWPullRefreshView alloc]initWithFrame:CGRectMake(0, -self.mytableView.frame.size.height, self.mytableView.frame.size.width, self.mytableView.frame.size.height) style:LWPullRefreshViewStylePullDown];
            refreshHeaderView.delegate = self;
            refreshHeaderView.offsetTemp = self.tableviewOffset;
            [self.mytableView addSubview:refreshHeaderView];
            self.refreshHeaderView = refreshHeaderView;
        }
        if (self.mytableView.frame.size.height-self.tableviewOffset<=self.mytableView.contentSize.height&&!self.refreshFooterView) {
            LWPullRefreshView *refreshFooterView = [[LWPullRefreshView alloc]initWithFrame:CGRectMake(0, self.mytableView.contentSize.height, self.mytableView.frame.size.width, self.mytableView.frame.size.height) style:LWPullRefreshViewStylePullUp];
            refreshFooterView.delegate = self;
            refreshFooterView.offsetTemp = self.tableviewOffset;
            [self.mytableView addSubview:refreshFooterView];
            self.refreshFooterView = refreshFooterView;
        }
        if (self.mytableView.frame.size.height-self.tableviewOffset<=self.mytableView.contentSize.height &&self.refreshFooterView) {
            self.refreshFooterView.frame = CGRectMake(0, self.mytableView.contentSize.height, self.mytableView.frame.size.width, self.mytableView.frame.size.height);
        }else{
            if (self.refreshFooterView) {
                [self.refreshFooterView removeFromSuperview];
            }
        }
    }else if ([keyPath isEqualToString:@"tableviewOffset"]){
        self.refreshHeaderView.frame = CGRectMake(0, -self.mytableView.frame.size.height-(self.tableviewOffset-64.f), self.mytableView.frame.size.width, self.mytableView.frame.size.height);
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"section:%ld_row:%ld",(long)indexPath.section,(long)indexPath.row];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshFooterView) {
        [_refreshFooterView tableViewDidScroll:scrollView];
    }
    if (_refreshHeaderView) {
        [_refreshHeaderView tableViewDidScroll:scrollView];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshFooterView tableViewDidEndDragging:scrollView];
    [_refreshHeaderView tableViewDidEndDragging:scrollView];
}

-(void)LWPullRefreshViewPullDownTriggerRefresh:(LWPullRefreshView *)view
{
    [view performSelector:@selector(tableViewDidFinishedLoading:) withObject:self.mytableView afterDelay:2];
}
-(void)LWPullRefreshViewPullUpTriggerRefresh:(LWPullRefreshView *)view
{
    [view performSelector:@selector(tableViewDidFinishedLoading:) withObject:self.mytableView afterDelay:2];
}

- (NSDate*)LWPullRefreshViewDateOfLastUpdated:(LWPullRefreshView *)view
{
    return [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.mytableView removeObserver:self forKeyPath:@"contentSize" context:nil];
    [self removeObserver:self forKeyPath:@"tableviewOffset" context:nil];
    self.mytableView.delegate = nil;
}

@end

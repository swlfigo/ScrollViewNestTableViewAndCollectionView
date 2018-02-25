//
//  ScrollViewHoldViewController.m
//  ScrollViewNestTableViewAndCollectionView
//
//  Created by Sylar on 2018/2/9.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "ScrollViewHoldViewController.h"
#import "SegmentSwipView.h"
#import "ScrollViewHoldHeaderView.h"

#import "ScrollViewCollectionSubViewController.h"
#import "ScrollViewTableSubViewController.h"

typedef void(^BottomRefresher)(UIScrollView *scrollview); //回调刷新Block

//最底部的ScrollView
@interface BackGroundNestScrollView:UIScrollView

@end

@implementation BackGroundNestScrollView
//防止手势冲突
//苹果以UIGestureRecognizerDelegate的形式，支持多个UIGestureRecognizer共存
//此方法返回YES时，手势事件会一直往下传递，不论当前层次是否对该事件进行响应。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end



@interface ScrollViewHoldViewController ()<UIScrollViewDelegate,SegmentSwipViewDelegate,SegmentSwipViewDataSource>

//App底部Tabbar高度
@property(nonatomic,assign)CGFloat tabBarHeight;

//底部ScrollView
@property(nonatomic,strong) BackGroundNestScrollView *bgScrollView;

//Swip
@property (nonatomic, strong)SegmentSwipView *segmentSwipView;

//底部刷新回调
@property (nonatomic, copy) BottomRefresher bottomRefresherBlock;

//Swip
@property (nonatomic,strong) SegmentSwipView *swipView;

//SegmentData
@property (nonatomic, strong)NSMutableArray *segmentData;

//Hold Header View
@property (nonatomic,strong) ScrollViewHoldHeaderView *headerHoldView;


//IPX
@property(nonatomic,assign)CGFloat iPhoneTopBarHeight;

//HeaderViewTotalHeight -- HeaderView总高度
@property(nonatomic,assign)CGFloat headerViewTotalHeight;

// scroll logic
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign) BOOL canScroll;

@property (nonatomic, assign) CGFloat scrollMinOffsetY;     // mainScrollView 滑动的最小的偏移量（小于这个值，开始滑动 tableView）

//唯一通知
@property(nonatomic,strong)NSString *ScrollViewNestControllerViewCanScrollKey;
@property(nonatomic,strong)NSString *ScrollViewNestControllerViewGoTopNotificationName;
@property(nonatomic,strong)NSString *ScrollViewNestControllerViewLeaveTopNotificationName;


//SubViewController
@property(nonatomic,strong)ScrollViewCollectionSubViewController *subCollectionViewController;

@property(nonatomic,strong)ScrollViewTableSubViewController *subTableViewController;

@end

@implementation ScrollViewHoldViewController


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (SL_isIphone375_812) {
            //ipX
            _iPhoneTopBarHeight = 88;
        }else{
            _iPhoneTopBarHeight = 64;
        }
        
        //App底部Tabbar高度
        _tabBarHeight = 0.0f;
        
        //默认_headerView高度
        _headerViewTotalHeight  = 220;
        
        _scrollMinOffsetY = -40;
        
        //唯一通知名
        _ScrollViewNestControllerViewCanScrollKey = [NSString stringWithFormat:@"ScrollViewNestControllerViewCanScrollKe%@",[NSUUID UUID].UUIDString];
        _ScrollViewNestControllerViewGoTopNotificationName = [NSString stringWithFormat:@"ScrollViewNestControllerViewGoTopNotificationName%@",[NSUUID UUID].UUIDString];
        _ScrollViewNestControllerViewLeaveTopNotificationName = [NSString stringWithFormat:@"ScrollViewNestControllerViewLeaveTopNotificationName%@",[NSUUID UUID].UUIDString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //添加通知
    [self addNotification];
    
    //下拉刷新回调
    self.bottomRefresherBlock =  ^(UIScrollView *scrollView){
        
        //用于下拉刷新回调
        
    };
    
    //ios11 ScrollView设置
    if (SL_isIphone375_812) {
        //ipX
        self.bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self configSubviews];
    [self optimizePanGesture];
    
    

}

-(void)configSubviews{
    [self createBGScrollView];
    [self configHeaderView];
    [self configSegmentSwipView];
    
    //update SubViews
    [self updateSubViews];
}

- (void)optimizePanGesture {
    [self.bgScrollView.panGestureRecognizer requireGestureRecognizerToFail:self.segmentSwipView.segmentSwipPanGestureRecognizer];
}


-(void)createBGScrollView{
    [self.view addSubview:self.bgScrollView];
    //初始化Insect为HeaderView高度
    _bgScrollView.contentSize = self.view.bounds.size;
    _bgScrollView.showsVerticalScrollIndicator = NO;
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.delegate = self;
    self.bgScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(topRefresh)];
    
    [self.bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(_iPhoneTopBarHeight, 0, _tabBarHeight, 0));
    }];
    
    
}

-(void)configHeaderView{
    
    //BannerView
    [self.bgScrollView addSubview:self.headerHoldView];

    [self.headerHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgScrollView.mas_top);
        make.centerX.mas_equalTo(self.bgScrollView.mas_centerX);
        make.width.mas_equalTo(self.bgScrollView.mas_width);
        make.height.mas_equalTo(_headerViewTotalHeight);
    }];

    
}

//切换View
-(void)configSegmentSwipView{

    
    self.segmentSwipView = [SegmentSwipView new];
    self.segmentSwipView.dataSource = self;
    self.segmentSwipView.delegate = self;
    self.segmentSwipView.baseViewController = self;
    [self.bgScrollView addSubview:self.segmentSwipView];
    
    
    // VIEW
    [self.segmentSwipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.bgScrollView.mas_width);
        make.height.mas_equalTo(self.bgScrollView.mas_height);
        make.top.mas_equalTo(self.headerHoldView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.bgScrollView.mas_bottom).offset(0);
    }];
    
    
}

-(void)updateSubViews{
    self.segmentData = [[NSMutableArray alloc]init];
    
    [self.segmentData addObject:self.subCollectionViewController];
    
    [self.segmentData addObject:self.subTableViewController];
    
    [self.segmentSwipView reloadData];
}


#pragma mark - Method
-(void)topRefresh{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bgScrollView.mj_header endRefreshing];
    });
}

#pragma mark - ProfileSegmentSwipView Delegate

-(NSInteger)numberOfItemsInSegmentSwipView:(SegmentSwipView *)segmentSwipView{
    return self.segmentData.count;
}

-(UIViewController *)segmentSwipView:(SegmentSwipView *)segmentSwipView itemAtIndex:(NSInteger)index{
    return self.segmentData[index];
}

-(void)segmentSwipView:(SegmentSwipView *)segmentSwipView didScrollToIndex:(NSInteger)index{
    if (index < self.segmentData.count) {

    }
}

#pragma mark - Notification
- (void)addNotification {
    //联动通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:_ScrollViewNestControllerViewLeaveTopNotificationName object:nil];
}

- (void)notificationAction:(NSNotification *)notification {
    if ([notification.name isEqualToString:_ScrollViewNestControllerViewLeaveTopNotificationName]) {
        if ([notification.userInfo[_ScrollViewNestControllerViewCanScrollKey] isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    }
}


#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bgScrollView) {
        //联动滑
        CGFloat offsetY = scrollView.contentOffset.y;
        self.isTopIsCanNotMoveTabViewPre = self.isTopIsCanNotMoveTabView;
        if (offsetY >= self.scrollMinOffsetY + _headerViewTotalHeight  ) {
            scrollView.contentOffset = CGPointMake(0,  _headerViewTotalHeight + self.scrollMinOffsetY);
            self.isTopIsCanNotMoveTabView = YES;
        }
        else {
            self.isTopIsCanNotMoveTabView = NO;
        }
        
        if (self.isTopIsCanNotMoveTabView != self.isTopIsCanNotMoveTabViewPre) {
            if (!self.isTopIsCanNotMoveTabViewPre && self.isTopIsCanNotMoveTabView) {
                [[NSNotificationCenter defaultCenter] postNotificationName:_ScrollViewNestControllerViewGoTopNotificationName object:nil userInfo:@{_ScrollViewNestControllerViewCanScrollKey : @"1"}];
                self.canScroll = NO;
            }
            
            if(self.isTopIsCanNotMoveTabViewPre && !self.isTopIsCanNotMoveTabView){
                if (!self.canScroll) {
                    scrollView.contentOffset = CGPointMake(0, _headerViewTotalHeight + self.scrollMinOffsetY);
                }
            }
        }
    }
    
}


#pragma mark - Lazy Load Getter
-(BackGroundNestScrollView *)bgScrollView{
    if (!_bgScrollView) {
        _bgScrollView = [[BackGroundNestScrollView alloc]initWithFrame:CGRectMake(0, 0, SL_SCREEN_WIDTH, SL_SCREEN_HEIGHT)];
    }
    return _bgScrollView;
}

-(ScrollViewHoldHeaderView *)headerHoldView{
    if (!_headerHoldView) {
        _headerHoldView = [[ScrollViewHoldHeaderView alloc]initWithFrame:CGRectMake(0, 0, SL_SCREEN_WIDTH, _headerViewTotalHeight)];
    }
    return _headerHoldView;
}

-(ScrollViewCollectionSubViewController *)subCollectionViewController{
    if (!_subCollectionViewController) {
        _subCollectionViewController = [ScrollViewCollectionSubViewController new];
        
        //需要设置 悬停距离进去,初始化CollectionView
        _subCollectionViewController.scrollMinOffSetY = fabs((_scrollMinOffsetY));
        
        _subCollectionViewController.bottomRefresherBlock = self.bottomRefresherBlock;
        
        //传入唯一的通知名
        _subCollectionViewController.ScrollViewNestControllerViewCanScrollKey = _ScrollViewNestControllerViewCanScrollKey;
        _subCollectionViewController.ScrollViewNestControllerViewGoTopNotificationName = _ScrollViewNestControllerViewGoTopNotificationName;
        _subCollectionViewController.ScrollViewNestControllerViewLeaveTopNotificationName = _ScrollViewNestControllerViewLeaveTopNotificationName;
    }
    return _subCollectionViewController;
}

-(ScrollViewTableSubViewController *)subTableViewController{
    if (!_subTableViewController) {
        _subTableViewController = [ScrollViewTableSubViewController new];
        
        //需要设置 悬停距离进去,初始化CollectionView
        _subTableViewController.scrollMinOffSetY = fabs((_scrollMinOffsetY));
        
        _subTableViewController.bottomRefresherBlock = self.bottomRefresherBlock;
        
        
        //传入唯一的通知名
        _subTableViewController.ScrollViewNestControllerViewCanScrollKey = _ScrollViewNestControllerViewCanScrollKey;
        _subTableViewController.ScrollViewNestControllerViewGoTopNotificationName = _ScrollViewNestControllerViewGoTopNotificationName;
        _subTableViewController.ScrollViewNestControllerViewLeaveTopNotificationName = _ScrollViewNestControllerViewLeaveTopNotificationName;
    }
    return _subTableViewController;
}
@end

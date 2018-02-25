//
//  ScrollViewTableSubViewController.m
//  ScrollViewNestTableViewAndCollectionView
//
//  Created by Sylar on 2018/2/23.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "ScrollViewTableSubViewController.h"

@interface ScrollViewTableSubViewController ()<UITableViewDelegate,UITableViewDataSource>

//Ipx的TopBar高度
@property(nonatomic,assign)CGFloat iPhoneTopBarHeight;

@end

@implementation ScrollViewTableSubViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (self) {
            if (SL_isIphone375_812) {
                //ipX
                _iPhoneTopBarHeight = 88;
            }else{
                _iPhoneTopBarHeight = 64;
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // notification
    [self addNotification];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mainTableView];
}


- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:_ScrollViewNestControllerViewGoTopNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:_ScrollViewNestControllerViewLeaveTopNotificationName object:nil];
    
    
}

#pragma mark - Notification
- (void)notificationAction:(NSNotification *)notification {
    if ([notification.name isEqualToString:_ScrollViewNestControllerViewGoTopNotificationName]) {
        if ([notification.userInfo[_ScrollViewNestControllerViewCanScrollKey] isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    }
    else if ([notification.name isEqualToString:_ScrollViewNestControllerViewLeaveTopNotificationName]) {
        self.mainTableView.contentOffset = CGPointZero;
        self.canScroll = NO;
    }
}

#pragma mark -Method
-(void)bottomRefresh{
    if (self.bottomRefresherBlock) {
        self.bottomRefresherBlock((UIScrollView*)self.mainTableView);
    }
    
    //模拟刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mainTableView.mj_footer endRefreshing];
    });
}

#pragma mark  - ScrollView Delegate;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == self.mainTableView) {
        if (!self.isCanScroll) {
            scrollView.contentOffset = CGPointZero;
        }
        
        if (scrollView.contentOffset.y < 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:_ScrollViewNestControllerViewLeaveTopNotificationName object:nil userInfo:@{_ScrollViewNestControllerViewCanScrollKey : @"1"}];
        }
    }
}



#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScrollViewTableSubViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第 %ld 行数据",indexPath.row];
    return cell;
}

#pragma mark - Lazy Load Getter
-(UITableView *)mainTableView{
    if (_mainTableView == nil) {
        
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - _iPhoneTopBarHeight - _tabarHeight - _scrollMinOffSetY) style:UITableViewStylePlain];
        [self.view addSubview:_mainTableView];
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.estimatedRowHeight = 0;
        _mainTableView.estimatedSectionHeaderHeight = 0;
        _mainTableView.estimatedSectionFooterHeight = 0;
        _mainTableView.showsVerticalScrollIndicator = NO;
        [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ScrollViewTableSubViewCell"];
        if (SL_isIphone375_812) {
            //ipX
            _mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _mainTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(bottomRefresh)];

        
    }
    return _mainTableView;
}

@end

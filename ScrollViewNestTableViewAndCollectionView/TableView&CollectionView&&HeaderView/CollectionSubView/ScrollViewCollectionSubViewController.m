//
//  ScrollViewCollectionSubViewController.m
//  ScrollViewNestTableViewAndCollectionView
//
//  Created by Sylar on 2018/2/23.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "ScrollViewCollectionSubViewController.h"
#import "MJRefresh.h"

@interface ScrollViewCollectionSubViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionView *mainCollectionView;

//Ipx的TopBar高度
@property(nonatomic,assign)CGFloat iPhoneTopBarHeight;

@end

@implementation ScrollViewCollectionSubViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //ipx
        if (SL_isIphone375_812) {
            //ipX
            _iPhoneTopBarHeight = 88;
        }else{
            _iPhoneTopBarHeight = 64;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addNotification];
    
    [self.view addSubview:self.mainCollectionView];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:_ScrollViewNestControllerViewGoTopNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:_ScrollViewNestControllerViewLeaveTopNotificationName object:nil];
}


#pragma  mark - Notification Method
- (void)notificationAction:(NSNotification *)notification {
    if ([notification.name isEqualToString:_ScrollViewNestControllerViewGoTopNotificationName]) {
        if ([notification.userInfo[_ScrollViewNestControllerViewCanScrollKey] isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    }
    else if ([notification.name isEqualToString:_ScrollViewNestControllerViewLeaveTopNotificationName]) {
        self.mainCollectionView.contentOffset = CGPointZero;
        self.canScroll = NO;
    }
    
}

#pragma mark - CollectionView Delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 90;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScrollViewCollectionSubViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 130);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15;
}

#pragma mark  - ScrollView Delegate;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == self.mainCollectionView) {
        if (!self.isCanScroll) {
            scrollView.contentOffset = CGPointZero;
        }
        
        if (scrollView.contentOffset.y < 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:_ScrollViewNestControllerViewLeaveTopNotificationName object:nil userInfo:@{_ScrollViewNestControllerViewCanScrollKey : @"1"}];
        }
    }
}

 
#pragma mark -Method
-(void)bottomRefresh{
    if (self.bottomRefresherBlock) {
        self.bottomRefresherBlock((UIScrollView*)self.mainCollectionView);
    }
    
    //模拟刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mainCollectionView.mj_footer endRefreshing];
    });
}


#pragma mark - Lazy Load Getter
-(UICollectionView *)mainCollectionView{
    if (_mainCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        
        //App底部可能存在Tabbar，Demo中考虑到的这一点
        //如果存在Tabbar可以在外面设置进来
        _mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - _iPhoneTopBarHeight - _tabarHeight - _scrollMinOffSetY) collectionViewLayout:layout];
        _mainCollectionView.backgroundColor = [UIColor lightGrayColor];
        [_mainCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ScrollViewCollectionSubViewCell"];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        _mainCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(bottomRefresh)];
        if (SL_isIphone375_812) {
            //ipX
            _mainCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
    }
    return _mainCollectionView;
}



@end

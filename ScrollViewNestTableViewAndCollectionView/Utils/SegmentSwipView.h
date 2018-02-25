//
//  SegmentView.h
//  ScrollViewNestTableViewAndCollectionView
//
//  Created by Sylar on 2018/2/9.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import <UIKit/UIKit.h>

//用于下部分切换 TableView 与 CollectionView
@protocol SegmentSwipViewDataSource;
@protocol SegmentSwipViewDelegate;

@interface SegmentSwipView : UIView
@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, weak) id <SegmentSwipViewDataSource> dataSource;
@property (nonatomic, weak) id <SegmentSwipViewDelegate> delegate;

// 根控制器
@property (nonatomic, weak) UIViewController *baseViewController;

// 当前页面
@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *segmentSwipPanGestureRecognizer;

/**
 调用该方法指定滑动到 index 处的分页
 
 @param index index
 @param animated 是否有动画
 */
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

/**
 刷新当前页面数据
 */
- (void)reloadData;

@end

@protocol SegmentSwipViewDataSource<NSObject>
@required
- (NSInteger)numberOfItemsInSegmentSwipView:(SegmentSwipView *)segmentSwipView;
- (UIViewController *)segmentSwipView:(SegmentSwipView *)segmentSwipView itemAtIndex:(NSInteger)index;
@end

@protocol SegmentSwipViewDelegate<NSObject>
- (void)segmentSwipView:(SegmentSwipView *)segmentSwipView didScrollToIndex:(NSInteger)index;
@end

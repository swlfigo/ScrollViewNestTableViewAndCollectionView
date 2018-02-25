//
//  SegmentView.m
//  ScrollViewNestTableViewAndCollectionView
//
//  Created by Sylar on 2018/2/9.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SegmentSwipView.h"

@interface SegmentSwipView()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation SegmentSwipView

- (void)dealloc {
#if defined(DEBUG) && DEBUG
    NSLog(@"SegmentSwipView %@", NSStringFromSelector(_cmd));
#endif
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
#if defined(DEBUG) && DEBUG
    NSLog(@"SegmentSwipView %@", NSStringFromSelector(_cmd));
#endif
    
    NSAssert([self.dataSource respondsToSelector:@selector(numberOfItemsInSegmentSwipView:)], @"you must override numberOfItemsInSegmentSwipView dataSource methods");
    NSAssert([self.dataSource respondsToSelector:@selector(segmentSwipView:itemAtIndex:)], @"you must override segmentSwipView:itemAtIndex: dataSource methods");
    
    NSInteger itemsCount = [self.dataSource numberOfItemsInSegmentSwipView:self];
    
    // set contentSize
    CGFloat mainScrollViewW = CGRectGetWidth(self.mainScrollView.bounds);
    
    self.mainScrollView.contentSize = CGSizeMake(mainScrollViewW * itemsCount, CGRectGetHeight(self.mainScrollView.bounds));
    self.mainScrollView.frame = self.bounds;
    
    for (NSInteger index = 0; index < itemsCount; index++) {
        UIViewController *vc = [self.dataSource segmentSwipView:self itemAtIndex:index];
        [self.mainScrollView addSubview:vc.view];
        [self.baseViewController addChildViewController:vc];
        [vc didMoveToParentViewController:self.baseViewController];
        
        CGRect viewFrame = vc.view.frame;
        viewFrame.origin.x = index * mainScrollViewW;
        viewFrame.origin.y = 0;
        vc.view.frame = viewFrame;
  
    }
}

#pragma mark - Initialize

- (void)configUI {
    _mainScrollView = [UIScrollView new];
    _mainScrollView.delegate = self;
    _mainScrollView.bounces = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.pagingEnabled = YES;
    [self addSubview:_mainScrollView];
}

#pragma mark - Public Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    self.currentPage = index;
    
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            self.mainScrollView.contentOffset = CGPointMake(index * CGRectGetWidth(self.mainScrollView.bounds), 0);
        }];
    }
    else {
        self.mainScrollView.contentOffset = CGPointMake(index * CGRectGetWidth(self.mainScrollView.bounds), 0);
    }
}

- (void)reloadData {
    // clear
    [self.mainScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    if ([self.delegate respondsToSelector:@selector(segmentSwipView:didScrollToIndex:)]) {
        [self.delegate segmentSwipView:self didScrollToIndex:scrollView.contentOffset.x / scrollView.bounds.size.width];
    }
}

#pragma mark - Getter

- (UIPanGestureRecognizer *)segmentSwipPanGestureRecognizer {
    return self.mainScrollView.panGestureRecognizer;
}

@end

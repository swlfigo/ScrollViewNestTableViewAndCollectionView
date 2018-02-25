//
//  ScrollViewTableSubViewController.h
//  ScrollViewNestTableViewAndCollectionView
//
//  Created by Sylar on 2018/2/23.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BottomRefresher)(UIScrollView *scrollview);  //CallBackBlock

@interface ScrollViewTableSubViewController : UIViewController

//App可能存在Tabbar
@property(nonatomic,assign) CGFloat tabarHeight;

//父视图悬停高度
@property(nonatomic,assign) CGFloat scrollMinOffSetY;

//CanScroll
@property (nonatomic, assign, getter=isCanScroll) BOOL canScroll;

//CallBackBlock
@property (nonatomic, copy) BottomRefresher bottomRefresherBlock;


@property (nonatomic,strong)UITableView *mainTableView;

//唯一通知
@property(nonatomic,strong)NSString *ScrollViewNestControllerViewCanScrollKey;
@property(nonatomic,strong)NSString *ScrollViewNestControllerViewGoTopNotificationName;
@property(nonatomic,strong)NSString *ScrollViewNestControllerViewLeaveTopNotificationName;

@end

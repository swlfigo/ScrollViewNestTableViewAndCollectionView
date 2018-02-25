//
//  ScrollViewHoldHeaderView.m
//  ScrollViewNestTableViewAndCollectionView
//
//  Created by Sylar on 2018/2/23.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "ScrollViewHoldHeaderView.h"

//悬停时候显示的HeaderView,供显示使用

@interface ScrollViewHoldHeaderView()
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *holdTitleLabel;
@end

@implementation ScrollViewHoldHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"ScrollView悬停展示的HeaderView";
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom).with.offset(-40);
        }];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        
        UIView *backGroundView = [UIView new];
        backGroundView.backgroundColor = [UIColor redColor];
        [self addSubview:backGroundView];
        [backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_titleLabel.mas_bottom);
            make.left.right.bottom.mas_equalTo(self);
        }];
        
        
        _holdTitleLabel = [UILabel new];
        _holdTitleLabel.text = @"ScrollView悬停View区域,高度为40";
        _holdTitleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_holdTitleLabel];
        [_holdTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_titleLabel.mas_bottom);
            make.left.right.bottom.mas_equalTo(self);
        }];
        
        
        
        _holdTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end

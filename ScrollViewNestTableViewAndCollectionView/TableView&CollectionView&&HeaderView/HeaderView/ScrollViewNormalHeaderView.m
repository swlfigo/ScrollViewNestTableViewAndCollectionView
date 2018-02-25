//
//  ScrollViewNormalHeaderView.m
//  ScrollViewNestTableViewAndCollectionView
//
//  Created by Sylar on 2018/2/25.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "ScrollViewNormalHeaderView.h"

@interface ScrollViewNormalHeaderView()

@property(nonatomic,strong)UILabel *titleLabel;

@end

@implementation ScrollViewNormalHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"ScrollView展示的HeaderView";
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom).with.offset(0);
        }];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end

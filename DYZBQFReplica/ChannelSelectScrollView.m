//
//  ChannelSelectScrollView.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/23.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "ChannelSelectScrollView.h"

@interface ChannelSelectScrollView ()
{
    void(^_channelSelectCallbackBlock)(NSInteger index);
    BOOL _indicatorAnimating;
}

@property (nonatomic) UIScrollView * mainScrollView;
@property (nonatomic) UIView * indicatorView;
@property (nonatomic) NSArray * channelBtns;

@end

@implementation ChannelSelectScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.scrollsToTop = NO;
    [self addSubview:self.mainScrollView];
    self.mainScrollView.bounces = NO;
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 2, 35, 2)];
    self.indicatorView.backgroundColor = [UIColor orangeColor];
    [self.mainScrollView addSubview:self.indicatorView];
}

- (void)setChannelTitles:(NSArray *)titles {
    for (UIView * view in self.channelBtns) {
        [view removeFromSuperview];
    }
    NSMutableArray * btns = [NSMutableArray array];
    self.channelBtns = btns;
    CGFloat offset = 0;
    NSInteger index = 0;
    for (NSString * title in titles) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(channelSelected:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:title forState:UIControlStateNormal];
        CGSize btnSize = CGSizeMake(80, self.frame.size.height);
        if (self.btnWidth > 0) {
            btnSize.width = self.btnWidth;
        } else {
            [btn sizeToFit];
            btnSize = btn.frame.size;
            btnSize.width += 20;
            btnSize.height = self.frame.size.height;
        }
        btn.frame = CGRectMake(offset, 0, btnSize.width, btnSize.height);
        offset += btnSize.width;
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        [btns addObject:btn];
        [self.mainScrollView addSubview:btn];
        if (index == self.selectedIndex) {
            btn.selected = YES;
            CGRect frame = btn.frame;
            frame.origin.y = self.frame.size.height - 2;
            frame.size.height = 2;
            self.indicatorView.frame = frame;
        }
        index++;
    }
    self.mainScrollView.contentSize = CGSizeMake(offset, self.mainScrollView.frame.size.height);
}

- (void)channelSelected:(UIButton *)btn {
    NSInteger index = [self.channelBtns indexOfObject:btn];
    [self setSelectedIndex:index];
    if (_channelSelectCallbackBlock) {
        _channelSelectCallbackBlock(index);
    }
}

- (void)setChannelSelectCallbackBlock:(void(^)(NSInteger index))block {
    _channelSelectCallbackBlock = block;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    UIButton * oldSelect = self.channelBtns[_selectedIndex];
    oldSelect.selected = NO;
    UIButton * newSelect = self.channelBtns[selectedIndex];
    newSelect.selected = YES;
    _selectedIndex = selectedIndex;
    CGRect frame = newSelect.frame;
    frame.origin.y = self.frame.size.height - 2;
    frame.size.height = 2;
    CGPoint contentOffset = self.mainScrollView.contentOffset;
    if (newSelect.frame.origin.x < contentOffset.x) {
        contentOffset.x = newSelect.frame.origin.x;
    }
    if (newSelect.frame.origin.x + newSelect.frame.size.width > contentOffset.x + self.mainScrollView.bounds.size.width) {
        contentOffset.x = newSelect.frame.origin.x - self.mainScrollView.bounds.size.width + newSelect.frame.size.width;
    }
    [self.mainScrollView setContentOffset:contentOffset animated:YES];
    _indicatorAnimating = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.indicatorView.frame = frame;
    } completion:^(BOOL finished) {
        _indicatorAnimating = NO;
    }];
}

- (void)setScrollPercent:(CGFloat)percent ToNext:(BOOL)next {
    if (_indicatorAnimating) {
        return;
    }
    CGRect frame = self.indicatorView.frame;
    UIButton * fromBtn = self.channelBtns[self.selectedIndex];
    CGFloat fromX = fromBtn.frame.origin.x;
    CGFloat fromWidth = fromBtn.frame.size.width;
    NSInteger index = next ? self.selectedIndex + 1:self.selectedIndex - 1;
    if (self.channelBtns.count <= index) {
        return;
    }
    UIButton * toBtn = self.channelBtns[index];
    CGFloat toX = toBtn.frame.origin.x;
    CGFloat toWidth = toBtn.frame.size.width;
    CGFloat newX = (toX - fromX) * percent + fromX;
    frame.origin.x = newX;
    CGFloat newWidth = (toWidth - fromWidth) * percent + fromWidth;
    frame.size.width = newWidth;
    self.indicatorView.frame = frame;
}

@end

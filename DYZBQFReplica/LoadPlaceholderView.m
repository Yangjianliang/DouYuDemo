//
//  LoadPlaceholderView.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/23.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "LoadPlaceholderView.h"

@interface LoadPlaceholderView ()
{
    void(^_reloadBlock)(void);
}

@property (nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *loadFailedView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
- (IBAction)reloadAction:(UIButton *)sender;

@end

@implementation LoadPlaceholderView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [self initUI];
}

- (void)initUI {
    [[NSBundle mainBundle] loadNibNamed:@"LoadPlaceholderView" owner:self options:nil];
    [self addSubview:self.contentView];
    // 关闭AutoresizingMask, 以便使用AutoLayout
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    // 添加约束条件使内容大小随self改变
    NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self addConstraints:@[top, left, bottom, right]];
    
    self.loadingImageView.animationImages = @[[UIImage imageNamed:@"img_loading_1"], [UIImage imageNamed:@"img_loading_2"]];
    self.loadingImageView.animationDuration = 1;
    [self.loadingImageView startAnimating];
}

- (void)setReloadBlock:(void(^)(void))block {
    _reloadBlock = block;
}

- (IBAction)reloadAction:(UIButton *)sender {
    if (_reloadBlock) {
        _reloadBlock();
    }
    [self setLoadFailed:NO];
}

- (void)setLoadFailed:(BOOL)failed {
    if (failed) {
        self.loadingView.hidden = YES;
        self.loadFailedView.hidden = NO;
    } else {
        self.loadingView.hidden = NO;
        self.loadFailedView.hidden = YES;
    }
}

@end

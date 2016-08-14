//
//  BaseViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化占位视图并添加约束使其与self.view位置大小相同
    _loadPlaceholderView = [[LoadPlaceholderView alloc] init];
    _loadPlaceholderView.hidden = YES;
    [self.view addSubview:_loadPlaceholderView];
    _loadPlaceholderView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_loadPlaceholderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:_loadPlaceholderView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:_loadPlaceholderView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:_loadPlaceholderView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraints:@[top, left, bottom, right]];
    
    //设置统一的后退按钮样式
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //确保占位视图显示在最前边
    [self.view bringSubviewToFront:_loadPlaceholderView];
}

- (BOOL)shouldAutorotate {
    return YES;
}

//默认视图控制器只支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

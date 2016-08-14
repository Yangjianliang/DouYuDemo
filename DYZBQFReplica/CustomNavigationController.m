//
//  CustomNavigationController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/16.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.backIndicatorImage = [UIImage new];
    self.navigationBar.backIndicatorTransitionMaskImage = [UIImage new];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

//设定该导航控制器支持屏幕方向为当前最上层视图控制器的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

@end

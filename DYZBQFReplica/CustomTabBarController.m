//
//  CustomTabBarController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/16.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "CustomTabBarController.h"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.selectedIndex = 3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}

//设定该标签控制器支持屏幕方向为当前选中子视图控制器的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end

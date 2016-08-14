//
//  IndexViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "IndexViewController.h"
#import "ScrollPageController.h"
#import "RecommendViewController.h"

@interface IndexViewController () <ScrollPageControllerDelegate>
{
    ScrollPageController * _scrollPageViewController;
}

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollPageViewController = [[ScrollPageController alloc] init];
    _scrollPageViewController.totalCount = 2;
    _scrollPageViewController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [_scrollPageViewController setupParentView:self.view andParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    if (index == 0 || index == 1) {
        RecommendViewController * rvc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecommendVC"];
        return rvc;
    }
    return nil;
}

@end

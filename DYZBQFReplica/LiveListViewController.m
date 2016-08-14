//
//  LiveListViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "LiveListViewController.h"
#import "ChannelSelectScrollView.h"
#import "NetworkToolkits.h"
#import "ChannelModel.h"
#import "CommonSubChannelViewController.h"
#import "ScrollPageController.h"
#import "CategoryListViewController.h"

#define URLSTRING_Live @"/api/v1/getColumnList"

@interface LiveListViewController () <ScrollPageControllerDelegate>
{
    ChannelSelectScrollView * _channelSelectScrollView; //导航条上的频道选择栏
    AFHTTPSessionManager * _manager;
    NSMutableArray * _channels; //直播分类的数据源
    ScrollPageController * _scrollPageViewController; //滚动视图控制器
}

@end

@implementation LiveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭滚动视图内容位置自动调整功能，后面会手动设置保留的位置。
    self.automaticallyAdjustsScrollViewInsets = NO;
    //初始化数据源中固定的两个数据
    _channels = [NSMutableArray array];
    ChannelModel * cm1 = [[ChannelModel alloc] init];
    cm1.cate_name = @"常用";
    [_channels addObject:cm1];
    ChannelModel * cm2 = [[ChannelModel alloc] init];
    cm2.cate_name = @"全部";
    [_channels addObject:cm2];
    //初始化频道选择视图
    _channelSelectScrollView = [[ChannelSelectScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 30, 44)];
    [_channelSelectScrollView setChannelTitles:@[@"常用", @"全部"]];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:_channelSelectScrollView];
    //将频道选择视图显示到导航条上
    self.navigationItem.leftBarButtonItem = item;
    //初始化滚动视图控制器
    _scrollPageViewController = [[ScrollPageController alloc] init];
    [_scrollPageViewController setupParentView:self.view andParentViewController:self];
    _scrollPageViewController.totalCount = _channels.count;
    _scrollPageViewController.delegate = self;
    _scrollPageViewController.currentIndex = 1;
    _channelSelectScrollView.selectedIndex = 1;
    __weak typeof(_scrollPageViewController) weakScroll = _scrollPageViewController;
    //设置频道选择视图选中后滚动视图滚动到对应位置
    [_channelSelectScrollView setChannelSelectCallbackBlock:^(NSInteger index) {
        [weakScroll setCurrentIndex:index animated:YES newViewController:nil];
    }];
    //加载其他频道网络数据
    [self loadChannelData];
}

- (void)loadChannelData {
    _manager = [NetworkToolkits defaultHTTPSessionManager];
    
    NSMutableDictionary * params = [NetworkToolkits commonUrlParameters];
    
    [_manager GET:URLSTRING_Live parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * datas = nil;
        @try {
            datas = responseObject[@"data"];
        } @catch (NSException *exception) {
            NSLog(@"%@\nresponseObject错误", exception);
        }
        //如果数据加载成功
        if (datas.count) {
            NSArray * channelModels = [ChannelModel arrayOfModelsFromDictionaries:datas error:nil];
            [_channels addObjectsFromArray:channelModels];
            NSMutableArray * names = [NSMutableArray array];
            for (ChannelModel * m in _channels) {
                [names addObject:m.cate_name];
            }
            //刷新频道栏显示
            [_channelSelectScrollView setChannelTitles:names];
            _scrollPageViewController.totalCount = _channels.count;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
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
    if (index < 0 || index >= _channels.count) {
        return nil;
    }
    if (index == 0) {
        CommonSubChannelViewController * cvc = [[CommonSubChannelViewController alloc] init];
        [cvc setSelectCallbackBlock:^(ChannelSubTypeModel *model) {
            CategoryListViewController * cateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryListVC"];
            NSInteger i = 0;
            for (; i < _channels.count; i++) {
                ChannelModel * channelModel = _channels[i];
                if ([model.cate_id isEqualToString:channelModel.cate_id]) {
                    cateVC.channelModel = channelModel;
                    cateVC.tagId = model.tag_id;
                    break;
                }
            }
            [_scrollPageViewController setCurrentIndex:i animated:YES newViewController:cateVC];
        }];
        return cvc;
    }
    CategoryListViewController * cateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryListVC"];
    cateVC.channelModel = _channels[index];
    return cateVC;
}

- (void)scrollPageScrollPercent:(CGFloat)percent toNext:(BOOL)next {
    [_channelSelectScrollView setScrollPercent:percent ToNext:next];
}

- (void)scrollPageDidScrollTo:(NSInteger)index {
    _channelSelectScrollView.selectedIndex = index;
}

@end

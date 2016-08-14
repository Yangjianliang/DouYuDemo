//
//  RecommendViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "RecommendViewController.h"
#import "NetworkToolkits.h"
#import "RoomListModel.h"
#import "RoomItemCell.h"
#import "UIImageView+AFNetworking.h"
#import "DefaultCollectionHeaderView.h"
#import "LiveViewController.h"
#import "CustomTabBarController.h"
#import "CategoryListViewController.h"
#import "RecommendTopHeader.h"
#import "SlideRoomModel.h"

#define URLSTRING_Recommend @"/api/v1/getCustomRoom"
#define URLSTRING_Slide @"/api/v1/slide/6"
#define URLSTRING_BigDataHotRoom @"/api/v1/getbigDataHotRoom"

@interface RecommendViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    AFHTTPSessionManager * _manager;
    NSArray * _dataArray;//数据源
    NSArray * _hotArray;
    NSArray * _slideArray;
    __weak IBOutlet UICollectionView *_collectionView;//storyboard创建的collectionView
}

@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
    //注册组头
    [_collectionView registerNib:[UINib nibWithNibName:@"DefaultCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DefaultCollectionHeaderView"];
    //注册组尾
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"RoomItemCell" bundle:nil] forCellWithReuseIdentifier:@"RoomItemCell"];
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 30)/2;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth * 3 / 4);
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 10, 10);
    
    //添加刷新控件
    MJRefreshGifHeader * header = [NetworkToolkits refreshHeader:^{
        [self loadData];
    }];
    _collectionView.mj_header = header;
    
    __weak typeof(self) weakSelf = self;
    [self.loadPlaceholderView setReloadBlock:^{
        [weakSelf loadData];
    }];
    self.loadPlaceholderView.hidden = NO;
    
    //下载数据
    _manager = [NetworkToolkits defaultHTTPSessionManager];
    [self loadData];
    [self loadSlideData];
    [self loadHotData];
}

- (void)loadData {
    NSMutableDictionary * params = [NetworkToolkits commonUrlParameters];
    [params setObject:@"133_2_" forKey:@"tagIds"];
    
    [_manager GET:URLSTRING_Recommend parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * datas = nil;
        @try {
            datas = responseObject[@"data"];
        } @catch (NSException *exception) {
            NSLog(@"%@\nresponseObject错误", exception);
        }
        //如果数据加载成功
        if (datas.count) {
            self.loadPlaceholderView.hidden = YES;
            //数据转换为模型
            _dataArray = [[RoomListModel arrayOfModelsFromDictionaries:datas error:nil] mutableCopy];
            //刷新collectionView显示
            [_collectionView.mj_header endRefreshing];
            [_collectionView reloadData];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        self.loadPlaceholderView.hidden = NO;
        [self.loadPlaceholderView setLoadFailed:YES];
    }];
}

- (void)loadSlideData {
    NSMutableDictionary * params = [NetworkToolkits commonUrlParameters];
    [params setObject:@"2.10" forKey:@"version"];
    
    [_manager GET:URLSTRING_Slide parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * datas = nil;
        @try {
            datas = responseObject[@"data"];
        } @catch (NSException *exception) {
            NSLog(@"%@\nresponseObject错误", exception);
        }
        //如果数据加载成功
        if (datas.count) {
            //数据转换为模型
            _slideArray = [SlideRoomModel arrayOfModelsFromDictionaries:datas error:nil];
            //刷新collectionView显示
            [_collectionView reloadData];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (error.code == -1001) {
            [self loadSlideData];
        }
    }];
}

- (void)loadHotData {
    NSMutableDictionary * params = [NetworkToolkits commonUrlParameters];
    
    [_manager GET:URLSTRING_BigDataHotRoom parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * datas = nil;
        @try {
            datas = responseObject[@"data"];
        } @catch (NSException *exception) {
            NSLog(@"%@\nresponseObject错误", exception);
        }
        //如果数据加载成功
        if (datas.count) {
            //数据转换为模型
            _hotArray = [RoomModel arrayOfModelsFromDictionaries:datas error:nil];
            //刷新collectionView显示
            [_collectionView reloadData];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (error.code == -1001) {
            [self loadHotData];
        }
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

#pragma mark - collectionView数据源和代理
// 返回collectionView的组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataArray.count;
}

// 返回collectionView每组的cell数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    RoomListModel * model = _dataArray[section];
    if ([model.tag_name isEqualToString:@"最热"] && _hotArray.count) {
        return _hotArray.count;
    }
    return model.room_list.count;
}

// 返回cell视图
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //复用池中获取
    RoomItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RoomItemCell" forIndexPath:indexPath];
    
    //获取数据
    RoomListModel * listM = _dataArray[indexPath.section];
    RoomModel * model = listM.room_list[indexPath.item];
    if ([listM.tag_name isEqualToString:@"最热"] && _hotArray.count) {
        model = _hotArray[indexPath.item];
    }
    //设置文字图片
    cell.roomTitleLabel.text = model.room_name;
    cell.nickNameLabel.text = model.nickname;
    if (model.online < 10000) {
        cell.onlineNumberLabel.text = [NSString stringWithFormat:@"%ld", model.online];
    } else {
        cell.onlineNumberLabel.text = [NSString stringWithFormat:@"%.1f万", model.online/10000.0];
    }
    
    
    NSURL * url = [NSURL URLWithString:model.room_src];
    [cell.photoView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Img_default"]];
    
    return cell;
}

// 设置组头的高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(100, 260);
    }
    return CGSizeMake(100, 45);
}

// 设置组尾的高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(100, 1);
}

// 返回组头组尾内容
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    //如果需要组头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DefaultCollectionHeaderView * view = nil;
        RoomListModel * listM = _dataArray[indexPath.section];
        if (indexPath.section == 0) {
            RecommendTopHeader * top = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"RecommendTopHeader" forIndexPath:indexPath];
            NSMutableArray * channelArray = [_dataArray mutableCopy];
            [channelArray removeObjectAtIndex:0];
            RoomListModel * rlm = [RoomListModel new];
            rlm.tag_name = @"更多";
            [channelArray addObject:rlm];
            top.channelArray = channelArray;
            [top setChannelSelectCallback:^(NSInteger index) {
                if (index == channelArray.count - 1) {
                    CustomTabBarController * tabVC = (CustomTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    tabVC.selectedIndex = 1;
                } else {
                    CategoryListViewController * cateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryListVC"];
                    RoomListModel * m = channelArray[index];
                    cateVC.tagId = m.tag_id;
                    cateVC.title = m.tag_name;
                    cateVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:cateVC animated:YES];
                }
            }];
            top.slideBannerView.totalCount = _slideArray.count;
            top.slideBannerView.placeholderImage = [UIImage imageNamed:@"Img_default"];
            if (_slideArray.count > 1) {
                top.slideBannerView.isLoop = YES;
                top.slideBannerView.autoSlideTimeInterval = 3;
            }
            [top.slideBannerView setImageUrlStringDataSourceBlock:^NSString *(NSInteger index) {
                SlideRoomModel * slideRoomModel = _slideArray[index];
                return slideRoomModel.pic_url;
            }];
            [top.slideBannerView setSelectIndexCallbackBlock:^(NSInteger index) {
                //创建新页面赋值并显示
                LiveViewController * lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveVC"];
                
                SlideRoomModel * slideRoomModel = _slideArray[index];
                RoomModel * model = slideRoomModel.room;
                lvc.roomModel = model;
                
                [self.navigationController pushViewController:lvc animated:YES];
            }];
            view = top;
        } else {
            view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"DefaultCollectionHeaderView" forIndexPath:indexPath];
        }
        view.titleLabel.text = listM.tag_name;
        if ([listM.tag_name isEqualToString:@"最热"]) {
            view.iconImageView.image = [UIImage imageNamed:@"home_header_hot"];
            //设置更多跳转
            [view setMoreActionBlock:^{
                
                CustomTabBarController * tabVC = (CustomTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                tabVC.selectedIndex = 1;
                
            }];
        } else {
            view.iconImageView.image = [UIImage imageNamed:@"home_header_normal"];
            [view setMoreActionBlock:^{
                
                CategoryListViewController * cateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryListVC"];
                cateVC.tagId = listM.tag_id;
                cateVC.title = listM.tag_name;
                cateVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:cateVC animated:YES];
                
            }];
        }
        return view;
    } else {//需要组尾
        UICollectionReusableView * view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        return view;
    }
}

// 选中某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //创建新页面赋值并显示
    LiveViewController * lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveVC"];
    
    RoomListModel * listM = _dataArray[indexPath.section];
    RoomModel * model = listM.room_list[indexPath.item];
    lvc.roomModel = model;
    
    [self.navigationController pushViewController:lvc animated:YES];
    
}

@end

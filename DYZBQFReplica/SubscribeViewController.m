//
//  SubscribeViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "SubscribeViewController.h"
#import "NetworkToolkits.h"
#import "RoomItemCell.h"
#import "UIImageView+AFNetworking.h"
#import "DefaultCollectionHeaderView.h"
#import "LiveViewController.h"
#import "UserManager.h"

#define URLSTRING_Subscribe_UnLogin @"/api/v1/nologinrecommroom"

@interface SubscribeViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
{
    AFHTTPSessionManager * _manager;
    NSArray * _dataArray;//数据源
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)loginAction:(UIButton *)sender;

@end

@implementation SubscribeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![UserManager defaultManager].isLogin) {
        [self loginAction:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData {
    _manager = [NetworkToolkits defaultHTTPSessionManager];
    
    NSMutableDictionary * params = [NetworkToolkits commonUrlParameters];
    
    [_manager GET:URLSTRING_Subscribe_UnLogin parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * datas = nil;
        @try {
            datas = responseObject[@"data"][@"new_bie"];
        } @catch (NSException *exception) {
            NSLog(@"%@\nresponseObject错误", exception);
        }
        //如果数据加载成功
        if (datas.count) {
            self.loadPlaceholderView.hidden = YES;
            //数据转换为模型
            _dataArray = [RoomModel arrayOfModelsFromDictionaries:datas error:nil];
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

#pragma mark - collectionView数据源和代理
// 返回collectionView的组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 返回collectionView每组的cell数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

// 返回cell视图
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //复用池中获取
    RoomItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RoomItemCell" forIndexPath:indexPath];
    
    //获取数据
    RoomModel * model = _dataArray[indexPath.item];
    
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
        
        DefaultCollectionHeaderView * view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"DefaultCollectionHeaderView" forIndexPath:indexPath];
        view.titleLabel.text = @"推荐直播";
        
        
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
    
    RoomModel * model = _dataArray[indexPath.item];
    lvc.roomModel = model;
    
    [self.navigationController pushViewController:lvc animated:YES];
    
}


- (IBAction)loginAction:(UIButton *)sender {
    [[UserManager defaultManager] loginWithCallback:^(UserInfoModel *userInfo) {
        
    } onViewController:self];
}

@end

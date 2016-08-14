//
//  CommonSubChannelViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/24.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "CommonSubChannelViewController.h"
#import "NetworkToolkits.h"
#import "ChannelCell.h"
#import "UIImageView+AFNetworking.h"

#define URLSTRING_CommonSubChannel @"/api/v1/getColumnDetail"

@interface CommonSubChannelViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    AFHTTPSessionManager * _manager;
    NSArray * _channelSubTypeModels;
    void(^_selectCallbackBlock)(ChannelSubTypeModel * model);
}

@property (nonatomic) UICollectionView * collectionView;

@end

@implementation CommonSubChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 2)/3;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraints:@[top, left, bottom, right]];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ChannelCell" bundle:nil] forCellWithReuseIdentifier:@"ChannelCell"];
    
    //添加刷新控件
    MJRefreshGifHeader * header = [NetworkToolkits refreshHeader:^{
        [self loadData];
    }];
    self.collectionView.mj_header = header;
    
    __weak typeof(self) weakSelf = self;
    [self.loadPlaceholderView setReloadBlock:^{
        [weakSelf loadData];
    }];
    self.loadPlaceholderView.hidden = NO;
    
    [self loadData];
}

- (void)loadData {
    _manager = [NetworkToolkits defaultHTTPSessionManager];
    
    NSMutableDictionary * params = [NetworkToolkits commonUrlParameters];
    
    [_manager GET:URLSTRING_CommonSubChannel parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * datas = nil;
        @try {
            datas = responseObject[@"data"];
        } @catch (NSException *exception) {
            NSLog(@"%@\nresponseObject错误", exception);
        }
        //如果数据加载成功
        if (datas.count) {
            _channelSubTypeModels = [ChannelSubTypeModel arrayOfModelsFromDictionaries:datas error:nil];
            //刷新collectionView显示
            [_collectionView.mj_header endRefreshing];
            [self.collectionView reloadData];
        }
        self.loadPlaceholderView.hidden = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        self.loadPlaceholderView.hidden = NO;
        [self.loadPlaceholderView setLoadFailed:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _channelSubTypeModels.count < 15 ?:15;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChannelSubTypeModel * m = _channelSubTypeModels[indexPath.row];
    ChannelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChannelCell" forIndexPath:indexPath];
    [cell.iconImageView setImageWithURL:[NSURL URLWithString:m.icon_url] placeholderImage:[UIImage imageNamed:@"Image_column_default"]];
    cell.nameLabel.text = m.tag_name;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectCallbackBlock) {
        ChannelSubTypeModel * m = _channelSubTypeModels[indexPath.row];
        _selectCallbackBlock(m);
    }
}

- (void)setSelectCallbackBlock:(void(^)(ChannelSubTypeModel * model))block {
    _selectCallbackBlock = block;
}

@end

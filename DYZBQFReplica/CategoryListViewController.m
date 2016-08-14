//
//  CategoryListViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/28.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "CategoryListViewController.h"
#import "RoomItemCell.h"
#import "NetworkToolkits.h"
#import "RoomModel.h"
#import "UIImageView+AFNetworking.h"
#import "LiveViewController.h"
#import "SubChannelSelectView.h"
#import "ChannelSubTypeModel.h"

#define URLSTRING_Live @"/api/v1/live/%@" //limit=20&offset=0
#define URLSTRING_ColumnRoom @"/api/v1/getColumnRoom/%@"
#define URLSTRING_SubChannel @"/api/v1/getColumnDetail" //shortName=game

@interface CategoryListViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray * _subChannelsArray;
    NSMutableArray * _dataArray;
    AFHTTPSessionManager * _manager;
    NSInteger _offset;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *subChannelsView;
@property (weak, nonatomic) IBOutlet SubChannelSelectView *subChannelSelectView;

@end

@implementation CategoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    _subChannelsArray = [NSMutableArray array];
    ChannelSubTypeModel * subM = [[ChannelSubTypeModel alloc] init];
    subM.tag_name = @"全部";
    [_subChannelsArray addObject:subM];
    [_subChannelSelectView setSelectChannelCallbackBlock:^(ChannelSubTypeModel *model) {
        _tagId = model.tag_id;
        _offset = 0;
        [self loadData];
    }];
    
    _manager = [NetworkToolkits defaultHTTPSessionManager];
    
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 30)/2;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth * 3 / 4);
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 10, 10);
    
    if (!_tagId) {
        CGFloat topOffset = 64;
        _collectionView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0);
    }
    
    //注册cell
    [_collectionView registerNib:[UINib nibWithNibName:@"RoomItemCell" bundle:nil] forCellWithReuseIdentifier:@"RoomItemCell"];
    
    //添加刷新控件
    MJRefreshGifHeader * header = [NetworkToolkits refreshHeader:^{
        _offset = 0;
        [self loadData];
    }];
    _collectionView.mj_header = header;
    
    //加载更多
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _offset = _dataArray.count;
        [self loadData];
    }];
    _collectionView.mj_footer = footer;
    
    __weak typeof(self) weakSelf = self;
    [self.loadPlaceholderView setReloadBlock:^{
        [weakSelf loadData];
    }];
    self.loadPlaceholderView.hidden = NO;
    
    //下载数据
    [self loadData];
    
    if (_channelModel.cate_id) {
        [self loadSubChannelsData];
    }
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popAction:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadSubChannelsData {
    //shortName=game
    NSMutableDictionary * params = [NetworkToolkits commonUrlParameters];
    [params setObject:_channelModel.short_name forKey:@"shortName"];
    
    [_manager GET:URLSTRING_SubChannel parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * datas = nil;
        @try {
            datas = responseObject[@"data"];
        } @catch (NSException *exception) {
            NSLog(@"%@\nresponseObject错误", exception);
        }
        //如果数据加载成功
        if (datas.count) {
            //数据转换为模型
            NSArray * modelArray = [ChannelSubTypeModel arrayOfModelsFromDictionaries:datas error:nil];
            [_subChannelsArray addObjectsFromArray:modelArray];
            //刷新显示
            _subChannelsView.hidden = NO;
            _subChannelSelectView.dataArray = _subChannelsArray;
            [_subChannelSelectView reloadData];
            _subChannelSelectView.tagId = _tagId;
            CGFloat topOffset = 64;
            if (_channelModel.cate_id) {
                topOffset += 40;
            }
            _collectionView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0);
            if (_dataArray.count > 0) {
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (error.code == -1001) {
            [self loadSubChannelsData];
        }
    }];
}

- (void)loadData {
    
    //limit=20&offset=0
    NSMutableDictionary * params = [NetworkToolkits commonUrlParameters];
    [params setObject:@(20) forKey:@"limit"];
    [params setObject:@(_offset) forKey:@"offset"];
    
    NSString * urlString = nil;
    if (_tagId) {
        urlString = [NSString stringWithFormat:URLSTRING_Live, _tagId];
    } else if (_channelModel.cate_id) {
        urlString = [NSString stringWithFormat:URLSTRING_ColumnRoom, _channelModel.cate_id];
    } else {
        urlString = [NSString stringWithFormat:URLSTRING_Live, @""];
    }
    
    [_manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * datas = nil;
        @try {
            datas = responseObject[@"data"];
        } @catch (NSException *exception) {
            NSLog(@"%@\nresponseObject错误", exception);
        }
        //如果数据加载成功
        if (datas.count) {
            //数据转换为模型
            NSArray * modelArray = [RoomModel arrayOfModelsFromDictionaries:datas error:nil];
            if (_offset == 0) {
                [_dataArray removeAllObjects];
            }
            [_dataArray addObjectsFromArray:modelArray];
            //刷新collectionView显示
            [_collectionView.mj_header endRefreshing];
            if (modelArray.count < 20) {
                [_collectionView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [_collectionView.mj_footer endRefreshing];
            }
            [self.collectionView reloadData];
        }
        self.loadPlaceholderView.hidden = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        self.loadPlaceholderView.hidden = NO;
        [self.loadPlaceholderView setLoadFailed:YES];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
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

// 选中某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //创建新页面赋值并显示
    LiveViewController * lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveVC"];
    
    //获取数据
    RoomModel * model = _dataArray[indexPath.item];
    lvc.roomModel = model;
    
    [self.navigationController pushViewController:lvc animated:YES];
    
}

@end

//
//  RecommendTopHeader.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "RecommendTopHeader.h"
#import "ChannelCell.h"
#import "RoomListModel.h"
#import "UIImageView+AFNetworking.h"

@interface RecommendTopHeader () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    void (^_channelSelectCallback)(NSInteger index);
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation RecommendTopHeader

- (void)awakeFromNib {
    [_collectionView registerNib:[UINib nibWithNibName:@"ChannelCell" bundle:nil] forCellWithReuseIdentifier:@"ChannelCell"];
    _collectionView.scrollsToTop = NO;
}

- (void)setChannelArray:(NSArray *)channelArray {
    _channelArray = channelArray;
    [_collectionView reloadData];
}

- (void)setChannelSelectCallback:(void (^)(NSInteger index))block {
    _channelSelectCallback = block;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _channelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChannelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChannelCell" forIndexPath:indexPath];
    RoomListModel * listM = _channelArray[indexPath.item];
    [cell.iconImageView setImageWithURL:[NSURL URLWithString:listM.icon_url] placeholderImage:[UIImage imageNamed:@"Image_column_default"]];
    cell.nameLabel.text = listM.tag_name;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_channelSelectCallback) {
        _channelSelectCallback(indexPath.item);
    }
}

@end

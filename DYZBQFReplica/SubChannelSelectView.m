//
//  SubChannelSelectView.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/1.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "SubChannelSelectView.h"
#import "SubChannelCell.h"

@interface SubChannelSelectView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    void(^_selectChannelCallbackBlock)(ChannelSubTypeModel * model);
}

@end

@implementation SubChannelSelectView

- (void)awakeFromNib {
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.dataSource = self;
    self.delegate = self;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SubChannelCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SubChannelCell" forIndexPath:indexPath];
    ChannelSubTypeModel * model = _dataArray[indexPath.item];
    [cell.titleButton setTitle:model.tag_name forState:UIControlStateNormal];
    cell.titleButton.selected = NO;
    if (!_tagId) {
        if (0 == indexPath.item) {
            cell.titleButton.selected = YES;
        }
    } else {
        if ([self.tagId isEqualToString:model.tag_id]) {
            cell.titleButton.selected = YES;
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChannelSubTypeModel * model = _dataArray[indexPath.item];
    return CGSizeMake(model.nameWidth + 30, self.bounds.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ChannelSubTypeModel * model = _dataArray[indexPath.item];
    _tagId = model.tag_id;
    if (_selectChannelCallbackBlock) {
        _selectChannelCallbackBlock(model);
    }
    [collectionView reloadData];
}

- (void)setSelectChannelCallbackBlock:(void(^)(ChannelSubTypeModel * model))block {
    _selectChannelCallbackBlock = block;
}

- (void)setTagId:(NSString *)tagId {
    _tagId = tagId;
    [self reloadData];
    for (NSInteger i = 0; i < _dataArray.count; i++) {
        ChannelSubTypeModel * model = _dataArray[i];
        if ([model.tag_id isEqualToString:_tagId]) {
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
    }
}

@end

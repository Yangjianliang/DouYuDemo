//
//  SubChannelSelectView.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/1.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelSubTypeModel.h"

@interface SubChannelSelectView : UICollectionView

@property (nonatomic) NSString * tagId;
@property (nonatomic) NSMutableArray * dataArray;

- (void)setSelectChannelCallbackBlock:(void(^)(ChannelSubTypeModel * model))block;

@end

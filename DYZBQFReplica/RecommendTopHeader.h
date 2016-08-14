//
//  RecommendTopHeader.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "DefaultCollectionHeaderView.h"
#import "SlideBannerView.h"

@interface RecommendTopHeader : DefaultCollectionHeaderView

@property (weak, nonatomic) IBOutlet SlideBannerView *slideBannerView;
@property (nonatomic) NSArray * channelArray;

- (void)setChannelSelectCallback:(void(^)(NSInteger index))block;

@end

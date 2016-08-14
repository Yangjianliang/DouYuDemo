//
//  ChannelModel.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/24.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseJSONModel.h"

@interface ChannelModel : BaseJSONModel

@property (nonatomic) NSString * cate_id;
@property (nonatomic) NSString * cate_name;
@property (nonatomic) NSString * short_name;
@property (nonatomic) NSString * orderdisplay;
@property (nonatomic) NSString * is_relate;
@property (nonatomic) NSString * is_del;
@property (nonatomic) NSString * push_ios;
@property (nonatomic) NSString * push_show;
@property (nonatomic) NSString * push_vertical_screen;

@end

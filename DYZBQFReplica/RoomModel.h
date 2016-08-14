//
//  RoomModel.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseJSONModel.h"

@protocol RoomModel <NSObject>

@end

@interface RoomModel : BaseJSONModel

@property (nonatomic) NSString * room_id;
@property (nonatomic) NSString * room_src;
@property (nonatomic) NSString * vertical_src;
@property (nonatomic) NSInteger isVertical;
@property (nonatomic) NSString * cate_id;
@property (nonatomic) NSString * room_name;
@property (nonatomic) NSString * show_status;
@property (nonatomic) NSString * subject;
@property (nonatomic) NSString * show_time;
@property (nonatomic) NSString * owner_uid;
@property (nonatomic) NSString * specific_catalog;
@property (nonatomic) NSString * specific_status;
@property (nonatomic) NSString * vod_quality;
@property (nonatomic) NSString * nickname;
@property (nonatomic) NSInteger online;
@property (nonatomic) NSString * child_id;
@property (nonatomic) NSString * avatar;
@property (nonatomic) NSInteger ranktype;

@property (nonatomic) NSString * credit_illegal;
@property (nonatomic) NSString * is_white_list;
@property (nonatomic) NSString * cur_credit;
@property (nonatomic) NSString * low_credit;
@property (nonatomic) NSString * url;
@property (nonatomic) NSString * game_url;
@property (nonatomic) NSString * game_name;
@property (nonatomic) NSString * game_icon_url;
@property (nonatomic) NSString * rtmp_url;
@property (nonatomic) NSString * rtmp_live;
@property (nonatomic) NSString * rtmp_cdn;
@property (nonatomic) NSString * hls_url;
@property (nonatomic) NSString * use_p2p;
@property (nonatomic) NSInteger room_dm_delay;
@property (nonatomic) NSString * show_details;
@property (nonatomic) NSString * owner_avatar;
@property (nonatomic) NSString * owner_weight;
@property (nonatomic) NSString * fans;

@end

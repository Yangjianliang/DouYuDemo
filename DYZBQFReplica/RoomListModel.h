//
//  RoomListModel.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseJSONModel.h"
#import "RoomModel.h"

@interface RoomListModel : BaseJSONModel

@property (nonatomic) NSArray<RoomModel> * room_list;
@property (nonatomic) NSString * tag_name;
@property (nonatomic) NSString * tag_id;
@property (nonatomic) NSString * icon_url;

@end

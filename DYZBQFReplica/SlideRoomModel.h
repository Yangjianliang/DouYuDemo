//
//  SlideRoomModel.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/14.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseJSONModel.h"
#import "RoomModel.h"

@interface SlideRoomModel : BaseJSONModel

@property (nonatomic) NSInteger id;
@property (nonatomic) NSString * title;
@property (nonatomic) NSString * pic_url;
@property (nonatomic) NSString * tv_pic_url;
@property (nonatomic) RoomModel * room;

@end

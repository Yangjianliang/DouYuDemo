//
//  UserInfoAvatarModel.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/15.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseJSONModel.h"

@protocol UserInfoAvatarModel
@end

@interface UserInfoAvatarModel : BaseJSONModel

@property (nonatomic) NSString * small;
@property (nonatomic) NSString * middle;
@property (nonatomic) NSString * big;

@end

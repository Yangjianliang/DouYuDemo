//
//  UserInfoModel.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/15.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseJSONModel.h"
#import "UserInfoAvatarModel.h"

@interface UserInfoModel : BaseJSONModel

@property (nonatomic) NSString * uid;
@property (nonatomic) NSString * username;
@property (nonatomic) NSString * nickname;
@property (nonatomic) NSString * email;
@property (nonatomic) NSString * qq;
@property (nonatomic) NSString * mobile_phone;
@property (nonatomic) NSString * phone_status;
@property (nonatomic) NSString * email_status;
@property (nonatomic) NSString * lastlogin;
@property (nonatomic) UserInfoAvatarModel * avatar;
@property (nonatomic) NSString * has_room;
@property (nonatomic) NSString * groupid;
@property (nonatomic) NSString * is_own_room;
@property (nonatomic) NSString * gold1;
@property (nonatomic) NSString * score;
@property (nonatomic) NSDictionary * level;
@property (nonatomic) NSDictionary * userlevel;
@property (nonatomic) NSString * follow;
@property (nonatomic) NSInteger ios_gold_switch;
@property (nonatomic) NSString * gold;
@property (nonatomic) NSString * ident_status;
@property (nonatomic) NSString * token;
@property (nonatomic) NSInteger token_exp;

@end

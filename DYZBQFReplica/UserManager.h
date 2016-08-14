//
//  UserManager.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/15.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"

@interface UserManager : NSObject

@property (nonatomic) UserInfoModel * userInfo;
@property (nonatomic) NSDictionary * expImages;

+ (instancetype)defaultManager;

- (BOOL)isLogin;

- (void)loginWithCallback:(void(^)(UserInfoModel * userInfo))block onViewController:(UIViewController *)viewController;

- (void)logoutWithCallback:(void(^)(void))block;

- (NSString *)getExpImageWith:(NSInteger)level;

- (void)updateUserInfo:(void(^)(void))block;

@end

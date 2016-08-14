//
//  LoginView.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/15.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LoginType) {
    LoginTypeNone,
    LoginTypeDouyu,
    LoginTypeWeChat,
    LoginTypeQQ,
    LoginTypeUseAgreement
};

@interface LoginView : UIView

- (void)setCloseCallback:(void(^)(LoginType loginType))block;

@end

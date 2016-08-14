//
//  LoginView.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/15.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "LoginView.h"

@implementation LoginView
{
    void(^_closeCallback)(LoginType loginType);
}

- (void)setCloseCallback:(void(^)(LoginType loginType))block {
    _closeCallback = block;
}

- (IBAction)closeAction:(UIButton *)sender {
    if (_closeCallback) {
        _closeCallback(LoginTypeNone);
    }
}

- (IBAction)weChatLoginAction:(UIButton *)sender {
    if (_closeCallback) {
        _closeCallback(LoginTypeWeChat);
    }
}

- (IBAction)qqLoginAction:(UIButton *)sender {
    if (_closeCallback) {
        _closeCallback(LoginTypeQQ);
    }
}

- (IBAction)douyuLoginAction:(UIButton *)sender {
    if (_closeCallback) {
        _closeCallback(LoginTypeDouyu);
    }
}

- (IBAction)showUseAgreementAction:(UIButton *)sender {
    if (_closeCallback) {
        _closeCallback(LoginTypeUseAgreement);
    }
}

@end

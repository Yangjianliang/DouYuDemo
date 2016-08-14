//
//  UserManager.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/15.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "UserManager.h"
#import "NetworkToolkits.h"
#import "LoginView.h"
#import "W3BouncesView.h"
#import "LoginViewController.h"
#import "InsideWebViewController.h"
#import "CustomNavigationController.h"

#define M_UserInfoPath [NSString stringWithFormat:@"%@/Library/userInfo.plist", NSHomeDirectory()]

@implementation UserManager
{
    void(^_loginCallback)(UserInfoModel * userInfo);
    void(^_logoutCallback)(void);
    void(^_updateUserInfoBlcok)(void);
    AFHTTPSessionManager * _sessionManager;
    W3BouncesView * _bouncesView;
}

+ (instancetype)defaultManager {
    static UserManager * um = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        um = [[UserManager alloc] init];
    });
    return um;
}

- (instancetype)init {
    if (self = [super init]) {
        _sessionManager = [NetworkToolkits defaultHTTPSessionManager];
        _userInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:M_UserInfoPath];
        [self loadExpImages];
    }
    return self;
}

- (void)loadExpImages {
    NSDictionary * paras = [NetworkToolkits commonUrlParameters];
    [_sessionManager GET:@"/api/v1/getExpRule" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * data = responseObject[@"data"];
        if (data) {
            self.expImages = data;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (void)setUserInfo:(UserInfoModel *)userInfo {
    _userInfo = userInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSKeyedArchiver archiveRootObject:_userInfo toFile:M_UserInfoPath];
    });
}

- (BOOL)isLogin {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (self.userInfo && self.userInfo.token_exp > now) {
        return YES;
    } else {
        return NO;
    }
}

- (void)loginWithCallback:(void(^)(UserInfoModel * userInfo))block onViewController:(UIViewController *)viewController {
    _loginCallback = block;
    LoginView * loginView = [[[NSBundle mainBundle] loadNibNamed:@"LoginView" owner:nil options:nil] lastObject];
    if (_bouncesView) {
        [_bouncesView hide:nil];
        _bouncesView = nil;
    }
    _bouncesView = [[W3BouncesView alloc] initWithParentView:viewController.view andContentView:loginView];
    [loginView setCloseCallback:^(LoginType loginType) {
        switch (loginType) {
            case LoginTypeWeChat:
                
                break;
            case LoginTypeQQ:
                
                break;
            case LoginTypeDouyu:
                [self loginWithDouyuAccount];
                break;
            case LoginTypeUseAgreement:
                [self showUseAgreement];
                break;
                
            default:
                break;
        }
        [_bouncesView hide:nil];
        _bouncesView = nil;
    }];
    [_bouncesView show:nil];
}

- (void)logoutWithCallback:(void(^)(void))block {
    _logoutCallback = block;
    if (self.userInfo) {
        _userInfo.token_exp = 0;
        _userInfo.token = nil;
        self.userInfo = _userInfo;
    }
    if (_logoutCallback) {
        _logoutCallback();
    }
}

- (void)loginWithDouyuAccount {
    LoginViewController * loginVC = [[LoginViewController alloc] init];
    [loginVC setLoginActionBlock:^(NSDictionary *infoDic) {
        UserInfoModel * model = [[UserInfoModel alloc] initWithDictionary:infoDic error:nil];
        if (model) {
            self.userInfo = model;
        }
        if (_loginCallback) {
            _loginCallback(_userInfo);
        }
    }];
    CustomNavigationController * nav = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    
}

- (void)showUseAgreement {
    InsideWebViewController * insideVC = [[InsideWebViewController alloc] init];
    insideVC.urlString = @"http://www.douyu.com/protocal/client";
    CustomNavigationController * nav = [[CustomNavigationController alloc] initWithRootViewController:insideVC];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (NSString *)getExpImageWith:(NSInteger)level {
    if (self.expImages) {
        NSString * levelStr = [NSString stringWithFormat:@"%ld", level];
        NSDictionary * dic = self.expImages[levelStr];
        if (dic) {
            return dic[@"mpic"];
        }
    }
    return nil;
}

- (void)updateUserInfo:(void(^)(void))block {
    _updateUserInfoBlcok = block;
    NSMutableDictionary * paras = [NetworkToolkits commonUrlParameters];
    if (!_userInfo.token) {
        return;
    }
    [paras setObject:_userInfo.token forKey:@"token"];
    [_sessionManager GET:@"/api/v1/my_info" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * data = responseObject[@"data"];
        if (data) {
            UserInfoModel * model = [[UserInfoModel alloc] initWithDictionary:data error:nil];
            if (model) {
                model.token = _userInfo.token;
                model.token_exp = _userInfo.token_exp;
                self.userInfo = model;
                if (_updateUserInfoBlcok) {
                    _updateUserInfoBlcok();
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

@end

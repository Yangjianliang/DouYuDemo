//
//  LoginViewController.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/17.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

- (void)setLoginActionBlock:(void(^)(NSDictionary * infoDic))block;

@end

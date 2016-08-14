//
//  CommonSubChannelViewController.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/24.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseViewController.h"
#import "ChannelSubTypeModel.h"

@interface CommonSubChannelViewController : BaseViewController

- (void)setSelectCallbackBlock:(void(^)(ChannelSubTypeModel * model))block;

@end

//
//  NetworkToolkits.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "MJRefresh.h"

/**
 *  网络工具类
 */
@interface NetworkToolkits : NSObject

// 获取默认的网络请求管理器
+ (AFHTTPSessionManager *)defaultHTTPSessionManager;

// 获取url上通用参数
+ (NSMutableDictionary *)commonUrlParameters;

//刷新控件
+ (MJRefreshGifHeader *)refreshHeader:(MJRefreshComponentRefreshingBlock)refreshingBlock;

@end

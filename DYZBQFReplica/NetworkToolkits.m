//
//  NetworkToolkits.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "NetworkToolkits.h"

//#define URLString_Base @"http://www.douyu.com"
#define URLString_Base @"http://capi.douyucdn.cn"

@implementation NetworkToolkits

+ (AFHTTPSessionManager *)defaultHTTPSessionManager {
    static AFHTTPSessionManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration * conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        conf.timeoutIntervalForRequest = 5;
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:URLString_Base] sessionConfiguration:conf];
        [manager.requestSerializer setValue:@"DYZB (iPhone; iOS 9.3.2; Scale/2.00)" forHTTPHeaderField:@"User-Agent"];
    });
    
    return manager;
}

+ (NSMutableDictionary *)commonUrlParameters {
    NSString * timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    return [@{@"aid":@"ios", @"client_sys":@"ios", @"time":timestamp} mutableCopy];
}

+ (MJRefreshGifHeader *)refreshHeader:(MJRefreshComponentRefreshingBlock)refreshingBlock {
    //添加刷新控件
    MJRefreshGifHeader * header = [MJRefreshGifHeader headerWithRefreshingBlock:refreshingBlock];
    header.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    [header setImages:@[[UIImage imageNamed:@"img_mj_stateIdle"]] forState:MJRefreshStateIdle];
    [header setImages:@[[UIImage imageNamed:@"img_mj_statePulling"]] forState:MJRefreshStatePulling];
    [header setImages:@[[UIImage imageNamed:@"img_mj_stateRefreshing_01"], [UIImage imageNamed:@"img_mj_stateRefreshing_02"], [UIImage imageNamed:@"img_mj_stateRefreshing_03"], [UIImage imageNamed:@"img_mj_stateRefreshing_04"]] forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    return header;
}

@end

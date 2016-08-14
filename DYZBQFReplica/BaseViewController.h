//
//  BaseViewController.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadPlaceholderView.h"

/**
 *  视图控制器基类
 */
@interface BaseViewController : UIViewController

@property (nonatomic) LoadPlaceholderView * loadPlaceholderView; //加载状态占位视图

@end

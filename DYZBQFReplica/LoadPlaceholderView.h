//
//  LoadPlaceholderView.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/23.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadPlaceholderView : UIView

- (void)setReloadBlock:(void(^)(void))block;

- (void)setLoadFailed:(BOOL)failed;

@end

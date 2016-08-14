//
//  ChannelSelectScrollView.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/23.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelSelectScrollView : UIView

@property (nonatomic) CGFloat btnWidth;
@property (nonatomic) NSInteger selectedIndex;

- (void)setChannelTitles:(NSArray *)titles;

- (void)setChannelSelectCallbackBlock:(void(^)(NSInteger index))block;

- (void)setScrollPercent:(CGFloat)percent ToNext:(BOOL)next;

@end

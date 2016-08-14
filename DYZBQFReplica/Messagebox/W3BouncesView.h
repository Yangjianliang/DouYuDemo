//
//  W3BouncesView.h
//  W30126YouXiang
//
//  Created by qianfeng on 15/1/31.
//  Copyright (c) 2015年 W3. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^W3BouncesViewShowCompleted)(void);
typedef void(^W3BouncesViewHideCompleted)(void);

@interface W3BouncesView : NSObject

@property (nonatomic) UIView * contentView;

- (id)initWithParentView:(UIView *)parentView andContentView:(UIView *)contentView;

- (void)show:(W3BouncesViewShowCompleted)block;

- (void)hide:(W3BouncesViewHideCompleted)block;

@end

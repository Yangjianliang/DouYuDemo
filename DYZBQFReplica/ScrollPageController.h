//
//  ScrollPageController.h
//  ScrollPageController
//
//  Created by 王博 on 16/5/1.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollPageControllerDelegate <NSObject>

/**
 *  返回指定的位置将要显示的视图控制器
 *
 *  @param index 在滚动视图控制器中对应位置的序号
 *
 *  @return 视图控制器
 */
- (UIViewController *)viewControllerAtIndex:(NSInteger)index;

@optional
/**
 *  视图控制器滚动的百分比信息
 *
 *  @param percent 完成一次滚动的百分比
 *  @param next    是否是向后滚动：YES表示向后，NO表示向前
 */
- (void)scrollPageScrollPercent:(CGFloat)percent toNext:(BOOL)next;
/**
 *  视图控制器滚动到位置
 *
 *  @param index 当前位置序号
 */
- (void)scrollPageDidScrollTo:(NSInteger)index;

@end

/**
 *  通用的滚动视图控制器
 */
@interface ScrollPageController : UIViewController

@property (nonatomic) NSInteger currentIndex; //当前页序号
@property (nonatomic) NSUInteger totalCount; //总页数
@property (nonatomic, weak) id<ScrollPageControllerDelegate> delegate;

/**
 *  视图加载方法，初始化对象后使用该方法将滚动视图显示到目标位置
 *
 *  @param view                 要显示的位置的视图
 *  @param parentViewController 要显示的位置的视图所在的视图控制器
 */
- (void)setupParentView:(UIView *)view andParentViewController:(UIViewController *)parentViewController;

/**
 *  指定滚动到目标序号的视图
 *
 *  @param currentIndex 目标序号
 *  @param animated     是否动画
 *  @param vc           新的视图控制器，nil表示使用代理方法获取
 */
- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated newViewController:(UIViewController *)vc;

@end

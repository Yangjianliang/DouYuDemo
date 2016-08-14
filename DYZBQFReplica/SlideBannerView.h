//
//  SlideBannerView.h
//  SlideBannerView
//
//  Created by 王博 on 16/5/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideBannerView : UIView

@property (nonatomic) NSInteger totalCount;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) UIImage * placeholderImage;
@property (nonatomic) BOOL isLoop;
@property (nonatomic) NSTimeInterval autoSlideTimeInterval;

- (void)reloadData;
- (void)setImageUrlStringDataSourceBlock:(NSString *(^)(NSInteger index))block;
- (void)setSelectIndexCallbackBlock:(void(^)(NSInteger index))block;
- (void)setSlideIndexCallbackBlock:(void(^)(NSInteger index))block;

@end

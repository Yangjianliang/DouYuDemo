//
//  W3BouncesView.m
//  W30126YouXiang
//
//  Created by qianfeng on 15/1/31.
//  Copyright (c) 2015年 W3. All rights reserved.
//

#import "W3BouncesView.h"
#import "UIImage+ImageEffects.h"

@interface W3BouncesView () <UIGestureRecognizerDelegate>

@end

@implementation W3BouncesView
{
    UIView * _parentView;
    UIImageView * _backgroundView;
    CGFloat _backgroundOpacity;
}

- (id)initWithParentView:(UIView *)parentView andContentView:(UIView *)contentView
{
    if (self = [super init]) {
        if (parentView) {
            _parentView = parentView;
            _backgroundView = [[UIImageView alloc] initWithFrame:parentView.bounds];
        } else {
            _parentView = [[UIApplication sharedApplication].delegate window];
            _backgroundView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        [self makeBlurBackground];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
        tap.delegate = self;
        _backgroundView.userInteractionEnabled = YES;
        [_backgroundView addGestureRecognizer:tap];
        self.contentView = contentView;
    }
    return self;
}

- (void)bounces
{
    [UIView animateWithDuration:0.1 animations:^{
        if (self.contentView) {
            self.contentView.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                                 CGAffineTransformMakeScale(0.9f, 0.9f));
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            if (self.contentView) {
                self.contentView.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                                     CGAffineTransformMakeScale(1.0f, 1.0f));
            }
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)show:(W3BouncesViewShowCompleted)block
{
    if (self.contentView) {
        [_backgroundView addSubview:self.contentView];
        self.contentView.center = _backgroundView.center;
        self.contentView.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                              CGAffineTransformMakeScale(0.1f, 0.1f));
    }
    [_parentView addSubview:_backgroundView];
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = _backgroundOpacity;
        if (self.contentView) {
            self.contentView.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                                 CGAffineTransformMakeScale(1.0f, 1.0f));
        }
    } completion:^(BOOL finished) {
        [self bounces];
        if (block) {
            block();
        }
    }];
}

- (void)hide:(W3BouncesViewHideCompleted)block
{
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
        self.contentView = nil;
        [_backgroundView removeFromSuperview];
    }];
}

- (void)makeShadowBackground
{
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.7f;
    _backgroundOpacity = 0.7f;
}

- (void)makeBlurBackground
{
    UIImage *image = [UIImage convertViewToImage];
    UIImage *blurSnapshotImage = [image applyBlurWithRadius:5.0f
                                                  tintColor:[UIColor colorWithWhite:0.2f
                                                                              alpha:0.7f]
                                      saturationDeltaFactor:1.8f
                                                  maskImage:nil];
    
    _backgroundView.image = blurSnapshotImage;
    _backgroundView.alpha = 0.0f;
    _backgroundOpacity = 1.0f;
}

- (void)makeTransparentBackground
{
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundView.backgroundColor = [UIColor clearColor];
    _backgroundView.alpha = 0.0f;
    _backgroundOpacity = 1.0f;
}

- (void)tapBackground:(UITapGestureRecognizer *)tap
{
    if (![self.contentView hitTest:[tap locationInView:self.contentView] withEvent:nil]) {
        [self hide:nil];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //NSLog(@"%@", touch.view);
    if (touch.view != _backgroundView) {
        return NO;
    }
    return YES;
}

@end

//
//  DanMuCellLabel.m
//  DanMuView
//
//  Created by 王博 on 16/4/23.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "DanMuCellLabel.h"

@implementation DanMuCellLabel

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 1, 1)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textColor = [UIColor whiteColor];
        [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"attributedText" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"text"];
    [self removeObserver:self forKeyPath:@"attributedText"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [self sizeToFit];
    //NSLog(@"sizeToFit:%@", NSStringFromCGRect(self.frame));
}

@end

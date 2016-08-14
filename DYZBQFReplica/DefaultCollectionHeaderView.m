//
//  DefaultCollectionHeaderView.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "DefaultCollectionHeaderView.h"

@implementation DefaultCollectionHeaderView
{
    void(^_block)(void);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)moreAction:(UIButton *)sender {
    if (_block) {
        _block();
    }
}

- (void)setMoreActionBlock:(void(^)(void))block {
    _block = block;
}

@end

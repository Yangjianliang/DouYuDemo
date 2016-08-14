//
//  ChannelSubTypeModel.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/24.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "ChannelSubTypeModel.h"
#import <UIKit/UIKit.h>

@implementation ChannelSubTypeModel

- (NSInteger)nameWidth {
    if (!_nameWidth) {
        CGSize size = [_tag_name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]}];
        _nameWidth = size.width;
    }
    return _nameWidth;
}

@end

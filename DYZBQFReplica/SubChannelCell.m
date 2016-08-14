//
//  SubChannelCell.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/1.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "SubChannelCell.h"

@implementation SubChannelCell

- (void)awakeFromNib {
    self.titleButton.layer.cornerRadius = self.titleButton.bounds.size.height/2;
}

@end

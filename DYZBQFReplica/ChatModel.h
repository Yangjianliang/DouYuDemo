//
//  ChatModel.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "BaseJSONModel.h"

@interface ChatModel : BaseJSONModel

@property (nonatomic) NSString * type;
@property (nonatomic) NSString * txt;
@property (nonatomic) NSString * nn;
@property (nonatomic) float txtHeight;
@property (nonatomic) NSMutableAttributedString * attrMsg;
@property (nonatomic) NSMutableAttributedString * attrTxt;

@end

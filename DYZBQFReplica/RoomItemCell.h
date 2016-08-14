//
//  RoomItemCell.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

//房间cell
@interface RoomItemCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;//显示直播截图
@property (weak, nonatomic) IBOutlet UILabel *roomTitleLabel;//显示房间标题
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineNumberLabel;

@end

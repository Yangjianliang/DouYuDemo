//
//  LiveChatViewController.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomModel.h"
#import "DanMuView.h"

@interface LiveChatViewController : UIViewController

@property (nonatomic) RoomModel * model;
@property (nonatomic, weak) DanMuView * danMuView;

- (void)contectChatServerWithRoomModel:(RoomModel *)model;

- (void)hideKeyboard;

@end

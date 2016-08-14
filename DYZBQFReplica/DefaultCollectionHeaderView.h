//
//  DefaultCollectionHeaderView.h
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DefaultCollectionHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

- (IBAction)moreAction:(UIButton *)sender;

- (void)setMoreActionBlock:(void(^)(void))block;

@end

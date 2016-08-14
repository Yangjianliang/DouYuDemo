//
//  UserInfoViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "UserInfoViewController.h"
#import "InsideWebViewController.h"
#import "UserInfoAvatarCell.h"
#import "UserManager.h"
#import "UIImageView+AFNetworking.h"

@interface UserInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)logoutAction:(UIButton *)sender;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"个人信息";
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)popAction:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutAction:(UIButton *)sender {
    [[UserManager defaultManager] logoutWithCallback:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 7;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 80.0;
    }
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL nicknameIndex = indexPath.section == 0 && indexPath.row == 1;
    BOOL expIndex = indexPath.section == 1 && indexPath.row == 0;
    BOOL yuwanIndex = indexPath.section == 1 && indexPath.row == 1;
    if (indexPath.section == 0 && indexPath.row == 0) {
        UserInfoAvatarCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UserInfoAvatarCell" forIndexPath:indexPath];
        NSString * avatar = [UserManager defaultManager].userInfo.avatar.big;
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"Image_head"]];
        return cell;
    } else if (nicknameIndex || expIndex || yuwanIndex) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NoIndicatorCell" forIndexPath:indexPath];
        if (nicknameIndex) {
            cell.textLabel.text = @"昵称";
            cell.detailTextLabel.text = [UserManager defaultManager].userInfo.nickname;
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        if (expIndex) {
            cell.textLabel.text = @"经验值";
            NSNumber * cur_score = [UserManager defaultManager].userInfo.userlevel[@"cur_score"];
            NSNumber * next_level_score = [UserManager defaultManager].userInfo.userlevel[@"cur_score"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld/%ld", [cur_score integerValue], [next_level_score integerValue]];
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        }
        if (yuwanIndex) {
            cell.textLabel.text = @"鱼丸";
            cell.detailTextLabel.text = [UserManager defaultManager].userInfo.gold1;
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        }
        return cell;
    } else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
        if (indexPath.section == 1 && indexPath.row == 2) {
            cell.textLabel.text = @"鱼翅";
            cell.detailTextLabel.text = [UserManager defaultManager].userInfo.gold;
            cell.detailTextLabel.textColor = [UIColor orangeColor];
        }
        if (indexPath.section == 0) {
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            if (indexPath.row == 2) {
                cell.textLabel.text = @"实名认证";
                if ([[UserManager defaultManager].userInfo.ident_status isEqualToString:@"0"]) {
                    cell.detailTextLabel.text = @"未认证";
                } else {
                    cell.detailTextLabel.text = @"已认证";
                }
            }
            if (indexPath.row == 3) {
                cell.textLabel.text = @"密码";
                cell.detailTextLabel.text = @"修改";
                cell.detailTextLabel.textColor = [UIColor orangeColor];
            }
            if (indexPath.row == 4) {
                cell.textLabel.text = @"邮箱";
                if ([[UserManager defaultManager].userInfo.email_status isEqualToString:@"0"]) {
                    cell.detailTextLabel.text = @"未绑定";
                } else {
                    cell.detailTextLabel.text = [UserManager defaultManager].userInfo.email;
                }
            }
            if (indexPath.row == 5) {
                cell.textLabel.text = @"手机号";
                if ([[UserManager defaultManager].userInfo.phone_status isEqualToString:@"0"]) {
                    cell.detailTextLabel.text = @"未绑定";
                } else {
                    cell.detailTextLabel.text = [UserManager defaultManager].userInfo.mobile_phone;
                }
            }
            if (indexPath.row == 6) {
                cell.textLabel.text = @"QQ";
                if ([UserManager defaultManager].userInfo.qq.length < 1) {
                    cell.detailTextLabel.text = @"未填写";
                } else {
                    cell.detailTextLabel.text = [UserManager defaultManager].userInfo.qq;
                }
            }
        }
        return cell;
    }
}

@end

//
//  AboutMeViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "AboutMeViewController.h"
#import "UserManager.h"
#import "UIImageView+AFNetworking.h"
#import "UserInfoViewController.h"

@interface AboutMeViewController ()

@property (nonatomic) UserManager * userManager; //用户信息管理器
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView; //用户头像视图
@property (weak, nonatomic) IBOutlet UIButton *loginButton; //登录按钮
@property (weak, nonatomic) IBOutlet UILabel *nameLabel; //昵称按钮
@property (weak, nonatomic) IBOutlet UIImageView *levelImageView; //等级视图
@property (weak, nonatomic) IBOutlet UILabel *yuchiLabel; //鱼翅标签
@property (weak, nonatomic) IBOutlet UILabel *yuwanLabel; //鱼丸标签

- (IBAction)loginAction:(UIButton *)sender;
@end

@implementation AboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self reloadUI];
    [self.userManager updateUserInfo:^{
        [self reloadUI];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UserManager *)userManager {
    return [UserManager defaultManager];
}

- (void)reloadUI {
    if (self.userManager.isLogin) {
        self.nameLabel.text = self.userManager.userInfo.nickname;
        NSString * avatarUrlStr = self.userManager.userInfo.avatar.big;
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"Image_head"]];
        NSDictionary * level = self.userManager.userInfo.userlevel;
        NSInteger levelIndex = [level[@"lv"] integerValue];
        NSString * levelImage = [self.userManager getExpImageWith:levelIndex];
        [self.levelImageView setImageWithURL:[NSURL URLWithString:levelImage] placeholderImage:[UIImage imageNamed:@"等级默认图"]];
        self.yuwanLabel.text = self.userManager.userInfo.gold1;
        self.yuchiLabel.text = self.userManager.userInfo.gold;
    } else {
        self.nameLabel.text = @"请登录";
        self.avatarImageView.image = [UIImage imageNamed:@"Image_head"];
        self.levelImageView.image = [UIImage imageNamed:@"等级默认图"];
        self.yuwanLabel.text = @"0";
        self.yuchiLabel.text = @"0";
    }
}

- (IBAction)loginAction:(UIButton *)sender {
    if (self.userManager.isLogin) {
        [self performSegueWithIdentifier:@"ToUserInfoVC" sender:sender];
    } else {
        [self.userManager loginWithCallback:^(UserInfoModel *userInfo) {
            [self reloadUI];
        } onViewController:self];
    }
}

@end

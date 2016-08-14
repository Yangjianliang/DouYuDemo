//
//  LoginViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/17.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkToolkits.h"
#import "CocoaSecurity.h"
#import "MBProgressHUD.h"
#import "InsideWebViewController.h"

@interface LoginViewController ()
{
    void(^_loginActionBlock)(NSDictionary * infoDic);
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)loginAction:(UIButton *)sender;
- (IBAction)registAction:(UIButton *)sender;
- (IBAction)forgetPasswordAction:(UIButton *)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * dismissItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_dismiss"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissAction:)];
    self.navigationItem.rightBarButtonItem = dismissItem;
    self.navigationItem.title = @"登录";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissAction:(UIBarButtonItem *)item {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setLoginActionBlock:(void(^)(NSDictionary * infoDic))block {
    _loginActionBlock = block;
}

- (IBAction)loginAction:(UIButton *)sender {
    sender.enabled = NO;
    NSString * nickname = _nameTextField.text;
    NSString * password = _passwordTextField.text;
    CocoaSecurityResult * result = [CocoaSecurity md5:password];
    password = result.hexLower;
    NSMutableDictionary * paras = [NetworkToolkits commonUrlParameters];
    [paras setObject:nickname forKey:@"username"];
    [paras setObject:password forKey:@"password"];
    [paras setObject:@"md5" forKey:@"type"];
    [[NetworkToolkits defaultHTTPSessionManager] GET:@"/api/v1/login" parameters:paras progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"error"] integerValue] > 0) {
            NSString * err = responseObject[@"data"];
            [self showAlertInfo:err];
            sender.enabled = YES;
        } else {
            NSDictionary * dic = responseObject[@"data"];
            if (dic && _loginActionBlock) {
                _loginActionBlock(dic);
            }
            [self dismissAction:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        [self showAlertInfo:@"网络错误"];
        sender.enabled = YES;
    }];
}

- (void)openWebContent:(NSString *)urlString {
    InsideWebViewController * insideVC = [[InsideWebViewController alloc] init];
    insideVC.urlString = urlString;
    [self.navigationController pushViewController:insideVC animated:YES];
}

- (IBAction)registAction:(UIButton *)sender {
    [self openWebContent:@"http://www.douyu.com/member/register?mobile=true&hide=login&client=ios"];
}

- (IBAction)forgetPasswordAction:(UIButton *)sender {
    [self openWebContent:@"http://www.douyu.com/member/findpassword?mobile=true&client=ios"];
}

- (void)showAlertInfo:(NSString *)message {
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    [hud hide:YES afterDelay:1.5];
}

@end

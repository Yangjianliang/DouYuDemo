//
//  InsideWebViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/5/20.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "InsideWebViewController.h"
#import "UIWebView+AFNetworking.h"

@interface InsideWebViewController () <UIWebViewDelegate>
{
    UIWebView * _webView;
    UIProgressView * _progressView;
}

@end

@implementation InsideWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
    _webView.delegate = self;
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
    _progressView.hidden = YES;
    [self.view addSubview:_progressView];
    
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_task_refresh"] style:UIBarButtonItemStyleDone target:self action:@selector(refreshAction:)];
    self.navigationItem.rightBarButtonItem = right;
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    __weak typeof(self) weakSelf = self;
    [self.loadPlaceholderView setReloadBlock:^{
        [weakSelf loadContent];
    }];
    self.loadPlaceholderView.hidden = NO;
    
    [self loadContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popAction:(UIBarButtonItem *)item {
    if (self.navigationController.viewControllers[0] == self) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)refreshAction:(UIBarButtonItem *)item {
    [self loadContent];
}

- (void)loadContent {
    NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    NSProgress * progress = nil;
    [_webView loadRequest:req progress:&progress success:^NSString * _Nonnull(NSHTTPURLResponse * _Nonnull response, NSString * _Nonnull HTML) {
        _progressView.hidden = YES;
        self.loadPlaceholderView.hidden = YES;
        return HTML;
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        _progressView.hidden = YES;
        self.loadPlaceholderView.hidden = NO;
        [self.loadPlaceholderView setLoadFailed:YES];
    }];
    if (progress) {
        _progressView.hidden = NO;
        //[_progressView setObservedProgress:progress];
        [progress addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSProgress class]]) {
        NSProgress * progress = object;
        CGFloat progressValue = progress.completedUnitCount/(CGFloat)progress.totalUnitCount;
        [_progressView setProgress:progressValue animated:YES];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"navigationType:%ld\nto:%@", navigationType, request);
    if ([request.URL.absoluteString isEqualToString:@"http://www.douyu.com/"]) {
        [self popAction:nil];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    NSLog(@"didFailLoadWithError:%@", error);
}
@end

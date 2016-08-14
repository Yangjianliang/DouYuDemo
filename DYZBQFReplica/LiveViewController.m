//
//  LiveViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "LiveViewController.h"
#import "NetworkToolkits.h"
#import "CocoaSecurity.h"
#import <AVFoundation/AVFoundation.h>
#import "LiveAnchorViewController.h"
#import "LiveChatViewController.h"
#import "DanMuView.h"
#import "ScrollPageController.h"
#import "ChannelSelectScrollView.h"
#import "DevoteRankViewController.h"

#define URLSTRING_Room @"/api/v1/room/%@?aid=android&clientsys=android&time=%ld&auth=%@"

@interface LiveViewController () <ScrollPageControllerDelegate>
{
    AFHTTPSessionManager * _manager;
    AVPlayer * _player;
    AVPlayerLayer * _playerLayer;
    NSTimer * _playerStatusTimer;
    NSDate * _userLastTouchDate;
    NSInteger _videoKeepUpCounter;
    ScrollPageController * _scrollPageViewController;
    ChannelSelectScrollView * _channelSelectScrollView;
    NSArray * _subViewControllers;
    BOOL _statusBarHidden;
    NSURLSessionDataTask * _loadTask;
}

@property (weak, nonatomic) IBOutlet UIView *livePlayView;
@property (weak, nonatomic) IBOutlet UIView *noLiveCoverView;
@property (weak, nonatomic) IBOutlet UIView *playerUIPortraitView;
@property (weak, nonatomic) IBOutlet UIView *playerUILandscapeView;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *onlineBoxView;
@property (weak, nonatomic) IBOutlet UILabel *landscapeTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIView *channelContentView;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet DanMuView *danMuView;
@property (weak, nonatomic) IBOutlet UIButton *danMuToggleButton;

- (IBAction)backAction:(UIButton *)sender;
- (IBAction)fullScreenAction:(id)sender;
- (IBAction)playPauseAction:(id)sender;
- (IBAction)userTouchPlayerView:(id)sender;
- (IBAction)userTouchOnPortraitUIAction:(UITapGestureRecognizer *)sender;
- (IBAction)userTouchOnLandscapeUIAction:(UITapGestureRecognizer *)sender;
- (IBAction)portraitScreenAction:(UIButton *)sender;
- (IBAction)danmuToggleAction:(UIButton *)sender;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingImageView.animationImages = @[[UIImage imageNamed:@"image_loading_player01"], [UIImage imageNamed:@"image_loading_player02"], [UIImage imageNamed:@"image_loading_player03"]];
    self.loadingImageView.animationDuration = 1;
    
    [self loadScrollContentView];
    
    [self loadData];
    
    [self.livePlayView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)loadScrollContentView {
    LiveChatViewController * view1 = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveChatVC"];
    LiveAnchorViewController * view2 = [self.storyboard instantiateViewControllerWithIdentifier:@"LiveAnchorVC"];
    DevoteRankViewController * view3 = [self.storyboard instantiateViewControllerWithIdentifier:@"DevoteRankVC"];
    
    _subViewControllers = @[view1, view2, view3];
    _scrollPageViewController = [[ScrollPageController alloc] init];
    [_scrollPageViewController setupParentView:self.scrollContentView andParentViewController:self];
    _scrollPageViewController.totalCount = 3;
    _scrollPageViewController.delegate = self;
    
    _channelSelectScrollView = [[ChannelSelectScrollView alloc] initWithFrame:self.channelContentView.bounds];
    _channelSelectScrollView.btnWidth = ([UIScreen mainScreen].bounds.size.width - 80) / 3;
    [_channelSelectScrollView setChannelTitles:@[@"聊天", @"主播", @"贡献榜"]];
    
    __weak typeof(_scrollPageViewController) weakScroll = _scrollPageViewController;
    [_channelSelectScrollView setChannelSelectCallbackBlock:^(NSInteger index) {
        [weakScroll setCurrentIndex:index animated:YES newViewController:nil];
    }];
    [self.channelContentView addSubview:_channelSelectScrollView];
}

- (void)roomSetting {
    self.onlineLabel.text = [NSString stringWithFormat:@"人气:%ld", self.roomModel.online];
    self.roomNumberLabel.text = [NSString stringWithFormat:@"房间号:%@", self.roomModel.room_id];
    self.onlineBoxView.hidden = NO;
    self.landscapeTitleLabel.text = self.roomModel.room_name;
    self.fansLabel.text = self.roomModel.fans;
    if ([self.roomModel.show_status isEqualToString:@"1"]) {
        self.noLiveCoverView.hidden = YES;
    } else {
        self.noLiveCoverView.hidden = NO;
    }
}

- (void)loadData {
    _manager = [NetworkToolkits defaultHTTPSessionManager];
    
    NSString * roomInfoUrlString = [self getAuthUrlWith:_roomModel.room_id];
    NSLog(@"%@", roomInfoUrlString);
    _loadTask = [_manager GET:roomInfoUrlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"loadTask");
        if (!_loadTask) {
            return;
        }
        _loadTask = nil;
        NSDictionary * data = responseObject[@"data"];
        if (data) {
            RoomModel * newModel = [[RoomModel alloc] initWithDictionary:data error:nil];
            if (newModel) {
                NSLog(@"得到播放地址");
                self.roomModel = newModel;
                [self roomSetting];
                if ([newModel.show_status isEqualToString:@"1"]) {
                    [self livePlay];
                } else {
                    [self hideLoadingVideoView];
                }
                LiveAnchorViewController * avc = _subViewControllers[1];
                avc.model = newModel;
                LiveChatViewController * cvc = _subViewControllers[0];
                cvc.danMuView = self.danMuView;
                [cvc contectChatServerWithRoomModel:newModel];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (error.code == -1001) {
            [self loadData];
        }
    }];
}

- (void)livePlay {
    if (self.roomModel.hls_url.length == 0) {
        [self showLoadingVideoFail];
        return;
    }
    NSURL * url = [NSURL URLWithString:self.roomModel.hls_url];
    [self livePlayerWithUrl:url];
}

- (NSString *)getAuthUrlWith:(NSString *)roomId {
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString * roomStr = [NSString stringWithFormat:@"room/%@?aid=android&clientsys=android&time=%ld1231", roomId, (NSInteger)time];
    //NSLog(@"%@", roomStr);
    CocoaSecurityResult * res = [CocoaSecurity md5:roomStr];
    //NSLog(@"%@", res.hexLower);
    return [NSString stringWithFormat:URLSTRING_Room, roomId, (NSInteger)time, res.hexLower];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    if (_loadTask) {
        [_loadTask cancel];
        _loadTask = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [self.livePlayView removeObserver:self forKeyPath:@"bounds"];
    [_player removeObserver:self forKeyPath:@"status"];
    _player = nil;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    [self showPlayerUIView:NO];
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (IBAction)backAction:(UIButton *)sender {
    
    [_playerStatusTimer invalidate];
    _playerStatusTimer = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)fullScreenAction:(id)sender {
    [self updateViewDirection:UIDeviceOrientationLandscapeLeft];
}

- (IBAction)playPauseAction:(UIButton *)sender {
    if (sender.selected) {
        [_player pause];
    } else {
        [self livePlay];
    }
    sender.selected = !sender.selected;
}

- (IBAction)userTouchPlayerView:(id)sender {
    [self showPlayerUIView:NO];
    LiveChatViewController * cvc = _subViewControllers[0];
    [cvc hideKeyboard];
}

- (IBAction)userTouchOnPortraitUIAction:(UITapGestureRecognizer *)sender {
    [self hidePlayerUIView:YES];
    LiveChatViewController * cvc = _subViewControllers[0];
    [cvc hideKeyboard];
}

- (IBAction)userTouchOnLandscapeUIAction:(UITapGestureRecognizer *)sender {
    [self hidePlayerUIView:YES];
    LiveChatViewController * cvc = _subViewControllers[0];
    [cvc hideKeyboard];
}

- (IBAction)portraitScreenAction:(UIButton *)sender {
    [self updateViewDirection:UIDeviceOrientationPortrait];
}

- (IBAction)danmuToggleAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    _danMuView.hidden = sender.selected;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    if (index > 2) {
        return nil;
    }
    return _subViewControllers[index];
}

- (void)scrollPageScrollPercent:(CGFloat)percent toNext:(BOOL)next {
    [_channelSelectScrollView setScrollPercent:percent ToNext:next];
    LiveChatViewController * cvc = _subViewControllers[0];
    [cvc hideKeyboard];
}

- (void)scrollPageDidScrollTo:(NSInteger)index {
    _channelSelectScrollView.selectedIndex = index;
}

- (void)livePlayerWithUrl:(NSURL *)url {
    
    if (_playerStatusTimer) {
        [_playerStatusTimer invalidate];
        _playerStatusTimer = nil;
    }
    
    if (_player) {
        [_player removeObserver:self forKeyPath:@"status"];
        _player  = nil;
    }
    if (_playerLayer) {
        [_playerLayer removeFromSuperlayer];
    }
    
    _player = [AVPlayer playerWithURL:url];
    
    if (!_player.currentItem) {
        [self showLoadingVideoFail];
        return;
    }
    
    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.livePlayView.bounds;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.livePlayView.layer addSublayer:_playerLayer];
    
    NSLog(@"开始播放");
    [_player play];
    
    [self showLoadingVideoView];
    
    _userLastTouchDate = [NSDate date];
    
    //记得在退出页面前销毁_playerStatusTimer，否则影响页面释放
    _playerStatusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playerStatusCheck) userInfo:nil repeats:YES];
    
//    __weak typeof(self) weakSelf = self;
//    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
    //只在播放时调用，播放错误无法处理
//        [weakSelf playerStatusCheck];
//    }];
}

- (void)playerStatusCheck {
    if (_player.currentItem.playbackLikelyToKeepUp) {
        _videoKeepUpCounter = 0;
        [self hideLoadingVideoView];
    } else {
        _videoKeepUpCounter++;
        //NSLog(@"KeepUpCounter %ld", _videoKeepUpCounter);
        if (_videoKeepUpCounter > 2 && _videoKeepUpCounter < 6) {
            [self showLoadingVideoView];
        }
        if (_videoKeepUpCounter > 5) {
            _videoKeepUpCounter = 0;
            [self livePlay];
        }
    }
    //NSLog(@"%f", [_userLastTouchDate timeIntervalSinceDate:[NSDate date]]);
    if ([_userLastTouchDate timeIntervalSinceDate:[NSDate date]] < -5) {
        [self hidePlayerUIView:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (object == self.livePlayView) {
        CGRect frame = [change[@"new"] CGRectValue];
        _playerLayer.frame = frame;
        self.danMuView.hidden = YES;
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            if (!_danMuToggleButton.selected) {
                self.danMuView.hidden = NO;
            }
        }
        LiveChatViewController * cvc = _subViewControllers[0];
        [cvc hideKeyboard];
    } else if (object == _player) {
        if (_player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"播放准备就绪");
        } else if (_player.status == AVPlayerStatusFailed) {
            NSLog(@"播放错误:%@", _player.error);
            [_playerStatusTimer invalidate];
            [self showLoadingVideoFail];
        }
    }
}

- (void)showLoadingVideoView {
    self.loadingLabel.text = @"加载中...";
    self.loadingLabel.hidden = NO;
    [self.loadingImageView startAnimating];
    self.loadingImageView.hidden = NO;
}

- (void)showLoadingVideoFail {
    self.loadingLabel.text = @"加载失败";
    self.loadingLabel.hidden = NO;
    [self.loadingImageView stopAnimating];
    self.loadingImageView.hidden = NO;
}

- (void)hideLoadingVideoView {
    self.loadingLabel.hidden = YES;
    self.loadingImageView.hidden = YES;
}

- (void)hidePlayerUIView:(BOOL)animated {
    UIView * view = nil;
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        view = self.playerUIPortraitView;
    } else {
        view = self.playerUILandscapeView;
    }
    if (view.hidden == YES) {
        return;
    }
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            view.hidden = YES;
            view.alpha = 1;
        }];
    } else {
        view.hidden = YES;
    }
    _statusBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)showPlayerUIView:(BOOL)animated {
    _userLastTouchDate = [NSDate date];
    UIView * view = nil;
    UIView * otherView = nil;
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        view = self.playerUIPortraitView;
        otherView = self.playerUILandscapeView;
    }
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        view = self.playerUILandscapeView;
        otherView = self.playerUIPortraitView;
    }
    otherView.hidden = YES;
    if (animated) {
        view.alpha = 0;
        view.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1;
        } completion:nil];
    } else {
        view.hidden = NO;
    }
    _statusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)updateViewDirection:(UIDeviceOrientation)direction {
    
    [[UIDevice currentDevice] setValue:@(direction) forKey:@"orientation"];
}

@end

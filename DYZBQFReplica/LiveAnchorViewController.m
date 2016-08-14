//
//  LiveAnchorViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/19.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "LiveAnchorViewController.h"
#import "UIImageView+AFNetworking.h"

@interface LiveAnchorViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *anchorImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *anchorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *showDetailsTextView;

@end

@implementation LiveAnchorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fillData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setModel:(RoomModel *)model {
    _model = model;
    [self fillData];
}

- (void)fillData {
    [self.anchorImageView setImageWithURL:[NSURL URLWithString:_model.owner_avatar]];
    self.titleLabel.text = _model.room_name;
    self.anchorNameLabel.text = _model.nickname;
    self.ownerWeightLabel.text = _model.owner_weight;
    self.gameNameLabel.text = _model.game_name;
    self.showDetailsTextView.text = _model.show_details;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

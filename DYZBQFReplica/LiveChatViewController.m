//
//  LiveChatViewController.m
//  DYZBQFReplica
//
//  Created by 王博 on 16/4/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "LiveChatViewController.h"
#import "ChatInfoCell.h"
#import "ChatMessageCell.h"
#import "LiveChatManager.h"
#import "ChatModel.h"

#define UIColor_000128255 [UIColor colorWithRed:0.0 green:128/255.0 blue:1.0 alpha:1.0]

@interface LiveChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) NSDictionary * emotionDict;
@property (nonatomic) BOOL showing;
@property (nonatomic) BOOL scrolling;
@property (nonatomic) NSMutableArray * dataArray;
@property (nonatomic) LiveChatManager * liveChatManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *toScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
- (IBAction)toScrollAction:(UIButton *)sender;

@end

@implementation LiveChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrolling = YES;
    _dataArray = [NSMutableArray array];
    NSString * dicPath = [[NSBundle mainBundle] pathForResource:@"expressionImage_custom" ofType:@"plist"];
    if (dicPath) {
        _emotionDict = [NSDictionary dictionaryWithContentsOfFile:dicPath];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAction:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
    _showing = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _showing = NO;
    [self.chatTextField resignFirstResponder];
}

- (void)dealloc {
    [_liveChatManager stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard {
    [self.chatTextField resignFirstResponder];
}

- (void)keyboardAction:(NSNotification *)notification {
    //NSLog(@"%@", notification);
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGFloat bottom = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        [UIView animateWithDuration:duration animations:^{
            self.bottomLayoutConstraint.constant = bottom;
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.bottomLayoutConstraint.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatModel * m = _dataArray[indexPath.row];
    
    if ([m.type isEqualToString:@"sysInfo"]) {
        ChatInfoCell * infoCell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
        infoCell.infoLabel.text = m.txt;
        return infoCell;
    } else if ([m.type isEqualToString:@"uenter"]) {
        ChatInfoCell * infoCell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
        infoCell.infoLabel.text = [NSString stringWithFormat:@"%@ 进入房间", m.nn];
        return infoCell;
    } else {
        ChatMessageCell * msgCell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
        
        msgCell.messageLabel.attributedText = m.attrMsg;
        
        return msgCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatModel * model = _dataArray[indexPath.row];
    return model.txtHeight ? model.txtHeight + 6 : 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.chatTextField resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.chatTextField resignFirstResponder];
    self.scrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat bottomOffset = self.tableView.contentSize.height - self.tableView.contentOffset.y - self.tableView.bounds.size.height;
    //NSLog(@"%f", bottomOffset);
    if (bottomOffset < 20) {
        self.scrolling = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        NSString * msg = textField.text;
        [_liveChatManager sendChatMessage:msg];
        textField.text = nil;
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)toScrollAction:(UIButton *)sender {
    self.toScrollView.hidden = YES;
    self.scrolling = YES;
    NSIndexPath * lastIndexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)contectChatServerWithRoomModel:(RoomModel *)model {
    if (!model) {
        return;
    }
    _model = model;
    _liveChatManager = [[LiveChatManager alloc] init];
    _showing = YES;
    __weak typeof(self) weakSelf = self;
    //注意该Block中的循环引用会导致聊天接口不能释放
    void(^block)(STTModel *model) = ^(STTModel *model) {
        
        ChatModel * chatModel = [[ChatModel alloc] init];
        chatModel.txt = model.txt;
        chatModel.nn = model.nn;
        chatModel.type = model.type;
        
        if ([model.type isEqualToString:@"chatmsg"]) {
            NSMutableAttributedString * aStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:", model.nn] attributes:@{NSForegroundColorAttributeName:UIColor_000128255}];
            NSMutableString * mixString = [model.txt mutableCopy];
            if ([mixString containsString:@"[emot:"]) {
                NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"\\[emot:[a-z0-9]*]" options:NSRegularExpressionCaseInsensitive error:nil];
                NSArray * results = [regex matchesInString:mixString options:0 range:NSMakeRange(0, mixString.length)];
                //倒序替换表情，正序会破环其他获取到的range值的有效性
                for (NSInteger i = results.count - 1; i >= 0; i--) {
                    NSTextCheckingResult * result = results[i];
                    NSString * key = [mixString substringWithRange:result.range];
                    if (key) {
                        NSString * name = weakSelf.emotionDict[key];
                        if (name) {
                            NSURL * imgUrl = [[NSBundle mainBundle] URLForResource:name withExtension:@"png" subdirectory:@"DouyuEmotion"];
                            NSString * replace = [NSString stringWithFormat:@"<img src=\"%@\" width=\"20\"></img>", imgUrl.absoluteString];
                            [mixString replaceCharactersInRange:result.range withString:replace];
                            //NSLog(@"%@,%@", NSStringFromRange(result.range), replace);
                        }
                    }
                }
            }
            
            NSMutableAttributedString * bStr = [[NSMutableAttributedString alloc] initWithData:[mixString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            
            static NSShadow * shadow = nil;
            if (!shadow) {
                shadow = [[NSShadow alloc] init];
                shadow.shadowBlurRadius = 5;
                shadow.shadowColor = [UIColor blackColor];
            }
            [bStr addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                  NSFontAttributeName:[UIFont systemFontOfSize:16],
                                  NSShadowAttributeName:shadow
                                  } range:NSMakeRange(0, bStr.length)];
            chatModel.attrTxt = bStr;
            
            NSMutableAttributedString * cStr = [[NSMutableAttributedString alloc] initWithData:[mixString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            [cStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, cStr.length)];
            [aStr appendAttributedString:cStr];
            [aStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, aStr.length)];
            
            CGRect frame = [aStr boundingRectWithSize:CGSizeMake(weakSelf.tableView.frame.size.width - 20, 999) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
            
            chatModel.txtHeight = frame.size.height;
            chatModel.attrMsg = aStr;
            
            if (!weakSelf.danMuView.hidden) {
                [weakSelf.danMuView addTextOnView:chatModel.attrTxt];
            }
        }
        if ([model.type isEqualToString:@"uenter"]) {
            //TODO:
        }
        
        [weakSelf.dataArray addObject:chatModel];
        if (weakSelf.dataArray.count > 9999) {
            [weakSelf.dataArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5000)]];
            [weakSelf.tableView reloadData];
        } else {
            NSIndexPath * lastIndexPath = [NSIndexPath indexPathForRow:weakSelf.dataArray.count - 1 inSection:0];
            if (weakSelf.showing && weakSelf.tableView.frame.size.height > 20) {
                [weakSelf.tableView insertRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                if (weakSelf.scrolling) {
                    [weakSelf.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                } else {
                    CGFloat bottomOffset = weakSelf.tableView.contentSize.height - weakSelf.tableView.contentOffset.y - weakSelf.tableView.bounds.size.height;
                    if (bottomOffset > 20) {
                        weakSelf.toScrollView.hidden = NO;
                    }
                }
            }
        }
    };
    [_liveChatManager setInfoCallbackBlock:block];
    [_liveChatManager setMessageReceiveBlock:block];
    [_liveChatManager sysInfoCallback:@"房间连接中..."];
    [_liveChatManager sysInfoCallback:[NSString stringWithFormat:@"欢迎来到%@的直播间", self.model.room_name]];
    [_liveChatManager connectWithRoomID:self.model.room_id groupId:@"-9999"];
}
@end

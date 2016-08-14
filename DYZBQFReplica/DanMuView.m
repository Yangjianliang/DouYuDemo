//
//  DanMuView.m
//  DanMuView
//
//  Created by 王博 on 16/4/23.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "DanMuView.h"
#import "DanMuCellLabel.h"

@interface DanMuView ()

@property (nonatomic) NSTimer * loopTimer;
@property (nonatomic) NSMutableSet * onViewSet;
@property (nonatomic) NSMutableSet * reuseSet;
@property (nonatomic) NSMutableArray * textQueueArray;

@end

@implementation DanMuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    //初始化消息队列
    self.textQueueArray = [NSMutableArray array];
    //初始化重用池
    self.reuseSet = [NSMutableSet set];
    //初始化显示中的集合
    self.onViewSet = [NSMutableSet set];
    //启动一个定时器，定时刷新所有视图的位置
    self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self selector:@selector(processDanMuPostion) userInfo:nil repeats:YES];
}

- (void)dealloc {
    [self.loopTimer invalidate];
    self.loopTimer = nil;
}

- (void)addTextOnView:(NSAttributedString *)text {
    //把消息添加到消息队列
    [self.textQueueArray addObject:text];
}

- (DanMuCellLabel *)danMuCellLabelWithText:(NSAttributedString *)text {
    DanMuCellLabel * cell = [self.reuseSet anyObject];
    if (cell) {
        [self.reuseSet removeObject:cell];
    } else {
        cell = [[DanMuCellLabel alloc] init];
        if (self.font) {
            cell.font = self.font;
        }
    }
    cell.attributedText = text;
    return cell;
}

- (void)processDanMuPostion {
    //统计所有行的偏移量
    NSMutableArray * lineOffsetArray = [NSMutableArray array];
    //计算出视图中可以显示的行数
    NSInteger lineNumber = self.frame.size.height/(self.font ? self.font.lineHeight + 4 : 21.0);
    //初始化所有偏移量是0
    for (NSInteger i = 0; i < lineNumber; i++) {
        [lineOffsetArray addObject:@(0.0)];
    }
    
    for (DanMuCellLabel * cell in self.onViewSet) {
        CGRect frame = cell.frame;
        frame.origin.x -= 2 + cell.speed * 0.7;
        //移动屏幕上的文字
        cell.frame = frame;
        
        CGFloat newOffset = frame.origin.x+frame.size.width;
        
        if (newOffset <= 0) {
            [cell removeFromSuperview];
            [self.reuseSet addObject:cell];
        }
        NSInteger line = frame.origin.y/(self.font ? self.font.lineHeight + 4 : 21.0);
        if (lineOffsetArray.count > line) {
            CGFloat oldOffset = [lineOffsetArray[line] floatValue];
            if (newOffset > oldOffset) {
                [lineOffsetArray replaceObjectAtIndex:line withObject:@(newOffset)];
            }
        }
    }
    for (DanMuView * cell in self.reuseSet) {
        [self.onViewSet removeObject:cell];
    }
    
    for (NSInteger i = 0; i < lineOffsetArray.count; i++) {
        CGFloat offset = [lineOffsetArray[i] floatValue];
        //如果屏幕右侧已经有空间并且消息队列中有数据
        if (offset <= self.frame.size.width - 40 && self.textQueueArray.count > 0) {
            //从复用池中获取一个cell并且消息添加上去
            DanMuCellLabel * cell = [self danMuCellLabelWithText:self.textQueueArray[0]];
            //把消息队列中的数据前移
            [self.textQueueArray removeObjectAtIndex:0];
            //设置消息的位置
            CGRect frame = cell.frame;
            frame.origin.x = self.frame.size.width + 5;
            frame.origin.y = (self.font ? self.font.lineHeight + 4 : 21.0) * i;
            cell.frame = frame;
            //NSLog(@"%@", NSStringFromCGRect(frame));
            //添加了一个随机的速度
            cell.speed = arc4random()%2 + i * 0.3;
            //消息添加到视图上显示
            [self addSubview:cell];
            //消息添加到在显示的集合中
            [self.onViewSet addObject:cell];
        }
    }
}

@end

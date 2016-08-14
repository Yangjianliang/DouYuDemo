//
//  SlideBannerView.m
//  SlideBannerView
//
//  Created by 王博 on 16/5/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "SlideBannerView.h"
#import "UIImageView+AFNetworking.h"

@interface SlideBannerViewCell : UICollectionViewCell

@property (nonatomic) UIImageView * imageView;

@end

@implementation SlideBannerViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        [self.contentView addConstraints:@[top, left, bottom, right]];
    }
    return self;
}

@end

@interface SlideBannerView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSString *(^_imageUrlStringDataSourceBlock)(NSInteger index);
    void(^_selectIndexCallbackBlock)(NSInteger index);
    void(^_slideIndexCallbackBlock)(NSInteger index);
}

@property (nonatomic) UICollectionView * collectionView;
@property (nonatomic) NSTimer * timer;

@end

@implementation SlideBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [self initSetup];
}

- (void)initSetup {
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.sectionInset = UIEdgeInsetsZero;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:_collectionView];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self addConstraints:@[top, left, bottom, right]];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[SlideBannerViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_collectionView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
    _collectionView.bounces = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.scrollsToTop = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc {
    [_collectionView removeObserver:self forKeyPath:@"contentOffset"];
    [_collectionView removeObserver:self forKeyPath:@"contentInset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentInset"]) {
        if (_collectionView.contentInset.top != 0 || _collectionView.contentInset.bottom != 0 ) {
            _collectionView.contentInset = UIEdgeInsetsZero;
        }
        return;
    }
    
    CGFloat offsetX = _collectionView.contentOffset.x;
    CGFloat width = _collectionView.bounds.size.width;
    CGFloat percent = (NSInteger)offsetX%(NSInteger)width/width;
    NSInteger index = (NSInteger)offsetX/(NSInteger)width;
    //NSLog(@"%ld %f", index, percent);
    CGPoint velocity = [_collectionView.panGestureRecognizer velocityInView:_collectionView];
    //NSLog(@"%@", NSStringFromCGPoint(velocity));
    if (percent == 0 && velocity.x == 0) {
        if (_isLoop && _totalCount > 1) {
            if (index == 0) {
                _currentIndex = _totalCount - 1;
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_totalCount inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            } else if (index == _totalCount + 1) {
                _currentIndex = 0;
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            } else {
                _currentIndex = index - 1;
            }
        } else {
            _currentIndex = index;
        }
        if (_slideIndexCallbackBlock) {
            _slideIndexCallbackBlock(_currentIndex);
        }
        //NSLog(@"currentIndex:%ld", _currentIndex);
        return;
    }
}

- (void)setTotalCount:(NSInteger)totalCount {
    _totalCount = totalCount;
    //显示内容前刷新布局，不然cell大小是错误的
    [self layoutIfNeeded];
    [_collectionView reloadData];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    NSInteger index = currentIndex;
    if (_isLoop && _totalCount > 1) {
        index = currentIndex + 1;
    }
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)setIsLoop:(BOOL)isLoop {
    _isLoop = isLoop;
    if (isLoop) {
        _collectionView.bounces = YES;
        if (_totalCount > 1) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
    } else {
        _collectionView.bounces = NO;
    }
}

- (void)setAutoSlideTimeInterval:(NSTimeInterval)autoSlideTimeInterval {
    if (_timer) {
        [_timer invalidate];
    }
    _autoSlideTimeInterval = autoSlideTimeInterval;
    if (autoSlideTimeInterval) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_autoSlideTimeInterval target:self selector:@selector(autoScroll:) userInfo:nil repeats:YES];
    }
}

- (void)autoScroll:(NSTimer *)timer {
    NSInteger total = _totalCount;
    if (_isLoop && _totalCount > 1) {
        total = _totalCount + 2;
    }
    if (!_isLoop && _totalCount - 1 == _currentIndex) {
        _currentIndex = 0;
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    if (_currentIndex < total - 1) {
        NSInteger index = _currentIndex + 1;
        if (_isLoop) {
            index = _currentIndex + 2;
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void)reloadData {
    [_collectionView reloadData];
}

- (void)setImageUrlStringDataSourceBlock:(NSString *(^)(NSInteger index))block {
    _imageUrlStringDataSourceBlock = block;
}

- (void)setSelectIndexCallbackBlock:(void(^)(NSInteger index))block {
    _selectIndexCallbackBlock = block;
}

- (void)setSlideIndexCallbackBlock:(void(^)(NSInteger index))block {
    _slideIndexCallbackBlock = block;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_isLoop && _totalCount > 1) {
        return _totalCount+2;
    }
    return _totalCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width;
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    CGFloat height = collectionView.bounds.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom - layout.sectionInset.top - layout.sectionInset.bottom;
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SlideBannerViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = _placeholderImage;
    NSInteger index = indexPath.item;
    if (_isLoop && _totalCount > 1) {
        if (index == 0) {
            index = _totalCount - 1;
        } else if (index == _totalCount + 1) {
            index = 0;
        } else {
            index = index - 1;
        }
    }
    if (_imageUrlStringDataSourceBlock) {
        NSString * imgUrlStr = _imageUrlStringDataSourceBlock(index);
        [cell.imageView setImageWithURL:[NSURL URLWithString:imgUrlStr]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectIndexCallbackBlock) {
        NSInteger index = indexPath.item;
        if (_isLoop) {
            index = indexPath.item - 1;
        }
        _selectIndexCallbackBlock(index);
    }
}

@end

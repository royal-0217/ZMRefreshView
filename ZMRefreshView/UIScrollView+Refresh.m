//
//  UIScrollView+Refresh.m
//  ZMRefreshView
//
//  Created by Leo on 15/8/3.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <objc/runtime.h>

static CGFloat MaxOffsetY = 60.0f;

static NSString* KVO_ContentOffset = @"contentOffset";
static NSString* KVO_ContentSize = @"contentSize";

@implementation UIScrollView(Refresh)

+ (void)load {
    
    Method dealloc = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method refresh_dealloc = class_getInstanceMethod([self class], @selector(refresh_dealloc));
    method_exchangeImplementations(dealloc, refresh_dealloc);
}

- (void)refresh_dealloc {
    
//    if ([self refreshValue]) {
//        [self removeObserver: self forKeyPath: KVO_ContentOffset];
//        [self removeObserver: self forKeyPath: KVO_ContentSize];
//        [self setRefreshDelegate: nil];
//    }
//    
//    [self.headerRefreshView removeFromSuperview];
//    [self.footerRefreshView removeFromSuperview];
    
    [self refresh_dealloc];
}

#pragma mark -
#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString: KVO_ContentOffset]) {
        
        id<UIScrollViewRefreshDelegate> refreshDelgate = self.refreshDelegate;
        
        if (![self isDragging] && UIEdgeInsetsEqualToEdgeInsets(self.contentInset, [self settingInset])) {
            
            if (![refreshDelgate respondsToSelector: @selector(scrollViewWillRefreshWithDirection:)] || ![refreshDelgate respondsToSelector: @selector(scrollviewDidRefreshWithDirection:)]) {
                return;
            }
            
            NSValue* newPointValue = [change valueForKey: NSKeyValueChangeNewKey];
            CGFloat offsetY = [newPointValue CGPointValue].y;
            
            if (offsetY < -(MaxOffsetY + self.settingInset.top)) {
                
                BOOL refresh = [refreshDelgate scrollViewWillRefreshWithDirection: RefreshDirectionIsReload];
                if (!refresh) {
                    return;
                }
                [self setContentInset: UIEdgeInsetsMake(MaxOffsetY + self.settingInset.top, 0, 0, 0)];
                [self.topView startLoading];
                [refreshDelgate scrollviewDidRefreshWithDirection: RefreshDirectionIsReload];
            }
            else if (offsetY > (self.contentSize.height - CGRectGetHeight(self.bounds) + MaxOffsetY) && self.contentSize.height > CGRectGetHeight(self.bounds)) {
                
                if ([self.bottomView isLoading]) {
                    return;
                }
                
                BOOL refresh = [refreshDelgate scrollViewWillRefreshWithDirection: RefreshDirectionIsLoadMore];
                if (!refresh) {
                    return;
                }
                
                NSLog(@"dfsdf");
                
                [self.bottomView startLoading];
                [refreshDelgate scrollviewDidRefreshWithDirection: RefreshDirectionIsLoadMore];
            }
        }
    }
    else if ([keyPath isEqualToString: KVO_ContentSize]) {
        
        NSValue* contentSize = [change valueForKey: NSKeyValueChangeNewKey];
        CGFloat height = [contentSize CGSizeValue].height;
        
        self.bottomView.hidden = height > CGRectGetHeight(self.bounds) ? NO : YES;
        [self.bottomView setCenter: CGPointMake(CGRectGetWidth(self.bottomView.bounds)/2, height + CGRectGetHeight(self.bottomView.bounds)/2)];
    }
}

#pragma mark -
#pragma mark - Public methods
- (void)reloadRefreshData {
    
    [self.bottomView stopLoading];
    [self.topView stopLoading];
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.contentInset, [self settingInset])) {
        
        [UIView animateWithDuration: 0.25 animations:^{
            [self setContentInset: [self settingInset]];
        }completion:^(BOOL finished) {
            if ([self respondsToSelector: @selector(reloadData)]) {
                [self reloadData];
            }
        }];
    }
    else {
        if ([self respondsToSelector: @selector(reloadData)]) {
            [self reloadData];
        }
    }
}

#pragma mark - Private methods
- (void)reloadData {
    //  次类不实现功能,让子类去完成对应的操作
}

- (void)onTap:(UITapGestureRecognizer*)tapper {
    
    UIView* target = [tapper view];
    if (target == self.bottomView) {
        
        NSLog(@"loading more data");
        
        if ([self.bottomView isLoading]) {
            return;
        }
        
        BOOL refresh = [self.refreshDelegate scrollViewWillRefreshWithDirection: RefreshDirectionIsLoadMore];
        if (!refresh) {
            return;
        }
        [self.bottomView startLoading];
        [self.refreshDelegate scrollviewDidRefreshWithDirection: RefreshDirectionIsLoadMore];

        return;
    }
}

#pragma mark - setter refreshDelegate methodss

static const void *UIScrollViewRefreshDelegateValue = &UIScrollViewRefreshDelegateValue;

@dynamic refreshDelegate;
- (id<UIScrollViewRefreshDelegate>)refreshDelegate {
    return objc_getAssociatedObject(self, UIScrollViewRefreshDelegateValue);
}

- (void)setRefreshDelegate:(id<UIScrollViewRefreshDelegate>)refreshDelegate {
    
    id<UIScrollViewRefreshDelegate> scrollViewRefreshDelegateValue = [self refreshDelegate];
    
    if (scrollViewRefreshDelegateValue == nil && refreshDelegate) {
        
        [self addObserver: self forKeyPath: KVO_ContentOffset options: NSKeyValueObservingOptionNew context: nil];
        [self addObserver: self forKeyPath: KVO_ContentSize options: NSKeyValueObservingOptionNew context: nil];
        
        [self setUpRefresh: YES];
        [self setDownRefresh: YES];
    }
    else if (scrollViewRefreshDelegateValue != nil && refreshDelegate == nil) {
        
        [self removeObserver: self forKeyPath: KVO_ContentOffset];
        [self removeObserver: self forKeyPath: KVO_ContentSize];
        
        [self setUpRefresh: NO];
        [self setDownRefresh: NO];
    }
    
    objc_setAssociatedObject(self, UIScrollViewRefreshDelegateValue, refreshDelegate, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - setter settingInset methods

static const void *UIScrollViewRefreshSettingInsetValue = &UIScrollViewRefreshSettingInsetValue;

@dynamic settingInset;
- (UIEdgeInsets)settingInset {
    
    id value = objc_getAssociatedObject(self, UIScrollViewRefreshSettingInsetValue);
    return value == nil ? UIEdgeInsetsZero : [value UIEdgeInsetsValue];
}

- (void)setSettingInset:(UIEdgeInsets)settingInset {
    
    [self setContentInset: settingInset];
    objc_setAssociatedObject(self, UIScrollViewRefreshSettingInsetValue, [NSValue valueWithUIEdgeInsets: settingInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - setter downRefresh methods

static const void *UIScrollViewDownRefreshValue = &UIScrollViewDownRefreshValue;

@dynamic downRefresh;
- (BOOL)isDownRefresh {
    
    return [objc_getAssociatedObject(self, UIScrollViewDownRefreshValue) boolValue];
}

- (void)setDownRefresh:(BOOL)downRefresh {
    
    BOOL scrollViewDownRefresh = [self isDownRefresh];
    if (!scrollViewDownRefresh && downRefresh) {
        
        ZMScrollViewTopView* topView = [ZMScrollViewTopView new];
        topView.center = CGPointMake(CGRectGetWidth(topView.bounds)/2, -CGRectGetHeight(topView.bounds)/2);
        [self addSubview: topView];
        
        [self setTopView: topView];
    }
    else if (scrollViewDownRefresh && !downRefresh) {
        
        [self.topView removeFromSuperview];
        [self setTopView: nil];
    }
    objc_setAssociatedObject(self, UIScrollViewDownRefreshValue, @(downRefresh), OBJC_ASSOCIATION_ASSIGN);
}


#pragma mark - setter upRefresh methods

static const void *UIScrollViewUpRefreshValue = &UIScrollViewUpRefreshValue;

@dynamic upRefresh;
- (BOOL)isUpRefresh {
    
    return [objc_getAssociatedObject(self, UIScrollViewUpRefreshValue) boolValue];
}

- (void)setUpRefresh:(BOOL)upRefresh {
    
    BOOL scrollViewUpRefresh = [self isUpRefresh];
    if (!scrollViewUpRefresh && upRefresh) {
        
        ZMScrollViewBottomView* bottomView = [ZMScrollViewBottomView new];
        [bottomView addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(onTap:)]];
        
        CGFloat height = self.contentSize.height;
        
        bottomView.hidden = height > CGRectGetHeight(self.bounds) ? NO : YES;
        [bottomView setCenter: CGPointMake(CGRectGetWidth(bottomView.bounds)/2, height + CGRectGetHeight(bottomView.bounds)/2)];
        
        [self addSubview: bottomView];
        [self setBottomView: bottomView];
    }
    else if (scrollViewUpRefresh && !upRefresh) {
        
        [self.bottomView removeFromSuperview];
        [self setBottomView: nil];
    }
    objc_setAssociatedObject(self, UIScrollViewUpRefreshValue, @(upRefresh), OBJC_ASSOCIATION_ASSIGN);
}


#pragma mark - setter ZMScrollViewTopView methods

static const void *UIScrollViewTopViewValue = &UIScrollViewTopViewValue;

@dynamic topView;

- (ZMScrollViewTopView*)topView {
    return objc_getAssociatedObject(self, UIScrollViewTopViewValue);
}

- (void)setTopView:(ZMScrollViewTopView *)topView {
    objc_setAssociatedObject(self, UIScrollViewTopViewValue, topView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - setter ZMScrollViewBottomView methods

static const void *UIScrollViewBottomViewValue = &UIScrollViewBottomViewValue;

@dynamic bottomView;

- (ZMScrollViewBottomView*)bottomView {
    return objc_getAssociatedObject(self, UIScrollViewBottomViewValue);
}

- (void)setBottomView:(ZMScrollViewBottomView *)bottomView {
    objc_setAssociatedObject(self, UIScrollViewBottomViewValue, bottomView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - 

@implementation ZMScrollViewTopView

- (id)init {
    return [self initWithFrame: CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 60)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: CGRectMake(0, 0, CGRectGetWidth(frame), 60)];
    if (self) {
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        _activityView.center = CGPointMake(CGRectGetWidth(self.bounds)/2 - 30, CGRectGetHeight(self.bounds)/2);
        _activityView.hidesWhenStopped = NO;
        [self addSubview: _activityView];
        
        _titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(CGRectGetWidth(self.bounds)/2 - 15, CGRectGetHeight(self.bounds)/2 - 10, CGRectGetWidth(self.bounds), 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize: 16];
        _titleLabel.text = @"加载中...";
        [self addSubview: _titleLabel];
    }
    return self;
}

#pragma mark - Public methods

- (void)startLoading {
    
    [_activityView startAnimating];
}

- (void)stopLoading {
    
    [_activityView stopAnimating];
}

- (void)setTitle:(NSString *)title {
    
    _titleLabel.text = title;
}
@end


@implementation ZMScrollViewBottomView

- (id)init {
    return [self initWithFrame: CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 40)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(15, CGRectGetHeight(self.bounds)/2 - 15, CGRectGetWidth(self.bounds) - 30, 30)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize: 16];
        _titleLabel.text = @"加载更多";
        [self addSubview: _titleLabel];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        _activityView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
        [self addSubview: _activityView];
    }
    return self;
}

#pragma mark - Public methods

- (BOOL)isLoading {
    
    return [_activityView isAnimating];
}

- (void)startLoading {
    
    _titleLabel.hidden = YES;
    [_activityView startAnimating];
}

- (void)stopLoading {
    
    _titleLabel.hidden = NO;
    [_activityView stopAnimating];
}

- (void)setTitle:(NSString *)title {
    
    _titleLabel.text = title;
}

@end

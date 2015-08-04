//
//  UIScrollView+Refresh.h
//  ZMRefreshView
//
//  Created by Leo on 15/8/3.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZMScrollViewTopView;
@class ZMScrollViewBottomView;

typedef NS_ENUM(NSUInteger, RefreshDirection) {
    
    RefreshDirectionIsReload = 0,       /**< 下拉刷新 */
    RefreshDirectionIsLoadMore = 1,     /**< 上拉加载更多*/
};

@protocol UIScrollViewRefreshDelegate <UIScrollViewDelegate>;

@optional
- (BOOL)scrollViewWillRefreshWithDirection:(RefreshDirection)direction;
- (void)scrollviewDidRefreshWithDirection:(RefreshDirection)direction;

@end

@interface UIScrollView(Refresh)

@property (nonatomic, weak) id<UIScrollViewRefreshDelegate> refreshDelegate;
@property (nonatomic, getter=isDownRefresh) BOOL downRefresh;   /**< 下拉刷新 */
@property (nonatomic, getter=isUpRefresh) BOOL upRefresh;       /**< 上拉加载 */

@property (nonatomic, assign) UIEdgeInsets settingInset;        /**< 设置的偏移值【默认为UIEdgeInsetsZero】*/

//  刷新数据
- (void)reloadRefreshData;


@property (nonatomic, strong) ZMScrollViewTopView* topView;
@property (nonatomic, strong) ZMScrollViewBottomView* bottomView;

@end

/**
 *  ZMScrollViewTopView 顶端
 */
@interface ZMScrollViewTopView : UIView {
    
    UILabel* _titleLabel;
    UIActivityIndicatorView* _activityView;
}

@property (nonatomic, copy) NSString* title;

- (void)startLoading;
- (void)stopLoading;

@end


/**
 *  ZMScrollViewBottomView 低端
 */
@interface ZMScrollViewBottomView : UIView {
    
    UILabel* _titleLabel;
    UIActivityIndicatorView* _activityView;
}

@property (nonatomic, copy) NSString* title;
@property (nonatomic, getter=isLoading)BOOL loading;

- (void)startLoading;
- (void)stopLoading;

@end


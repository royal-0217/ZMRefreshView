//
//  ViewController.h
//  ZMRefreshView
//
//  Created by Leo on 15/8/3.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIScrollView+Refresh.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewRefreshDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;


@end


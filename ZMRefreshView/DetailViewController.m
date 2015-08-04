//
//  DetailViewController.m
//  ZMRefreshView
//
//  Created by Leo on 15/8/3.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)loadView {
    [super loadView];
    
    _tableView.rowHeight = 80.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    _tableView.settingInset = UIEdgeInsetsMake(0, 0, 40, 0);
    _tableView.refreshDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    _tableView.refreshDelegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

static NSInteger TableViewSourceCount = 20;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return TableViewSourceCount;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"cellIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat: @"detail...%@", @(indexPath.row)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (BOOL)scrollViewWillRefreshWithDirection:(RefreshDirection)direction {
    return YES;
}

- (void)scrollviewDidRefreshWithDirection:(RefreshDirection)direction {
    
    if (direction == RefreshDirectionIsReload) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            TableViewSourceCount = 20;
            [_tableView reloadRefreshData];
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            TableViewSourceCount += 5;
            [_tableView reloadRefreshData];
        });
    }
}

@end

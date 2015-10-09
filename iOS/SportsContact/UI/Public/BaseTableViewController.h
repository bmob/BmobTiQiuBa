//
//  BaseTableViewController.h
//  SportsContact
//
//  Created by bobo on 14-7-8.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
#import <ODRefreshControl.h>
#import "NSObject+MGBinding.h"
#import "AppUtil.h"
#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

//下拉刷新，在子类实现该方法；
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl;



@end

//
//  MatchDetailViewController.h
//  SportsContact
//
//  Created by Nero on 8/14/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"


@interface MatchDetailViewController : BaseTableViewController<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>


@property (nonatomic,strong) NSString *leagueId;

@property (nonatomic,strong) NSString *leagueName;


@property (nonatomic) BOOL isSearchLeagueBool;



@end

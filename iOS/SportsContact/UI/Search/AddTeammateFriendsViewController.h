//
//  AddTeammateFriendsViewController.h
//  SportsContact
//
//  Created by bobo on 14/11/22.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseTableViewController.h"
#import "DataDef.h"

@interface AddTeammateFriendsViewController : BaseTableViewController

@property (nonatomic,strong) Team *teamInfo;
@property (nonatomic ,strong) NSArray *friends;

@end

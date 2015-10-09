//
//  ScoreManagerViewController.h
//  SportsContact
//
//  Created by bobo on 14-8-5.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseTableViewController.h"
#import "InfoEngine.h"
#import "MatchEngine.h"

@interface ScoreManagerViewController : BaseTableViewController

@property (nonatomic, strong) Tournament *match;
@property (nonatomic, strong) Team *team;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, strong) UserInfo *userInfo;

@property (nonatomic, assign) BOOL isOtherTeam;

@end

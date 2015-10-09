//
//  SelectingOpponentViewController.h
//  SportsContact
//
//  Created by bobo on 14-8-4.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseTableViewController.h"
#import "DataDef.h"

@interface SelectingOpponentViewController : BaseTableViewController

@property (nonatomic, strong) Tournament *match;
@property (nonatomic, strong) NSArray *homeCourtTeams;

@end

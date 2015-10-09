//
//  CommentViewController.h
//  SportsContact
//
//  Created by bobo on 14-8-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseTableViewController.h"
#import "DataDef.h"

@interface CommentViewController : BaseTableViewController

@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) Tournament *match;
@property (nonatomic, strong) PlayerScore *playerScore;
@property (nonatomic, assign) BOOL needInputCell;


@end

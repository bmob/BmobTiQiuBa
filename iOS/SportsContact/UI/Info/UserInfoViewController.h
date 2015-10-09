//
//  UserInfoViewController.h
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseTableViewController.h"
#import "Util.h"

#import "InfoEngine.h"


typedef NS_OPTIONS(NSInteger, UserInfoViewType) {
    UserInfoViewTypeOwn = 0,
    UserInfoViewTypeInfo,
    UserInfoViewTypeTeam
};

@interface UserInfoViewController : BaseTableViewController

@property (nonatomic) UserInfoViewType viewType;
@property (nonatomic) BOOL isFriend;
@property (nonatomic,strong) UserInfo *userInfo;
@property (nonatomic) BOOL isTeammate;
@property (nonatomic, strong) NSArray *ownTeams;
//@property (strong, nonatomic)  Team *teamInfo;
//@property (nonatomic) BOOL isTeammateClickPush;
//@property (nonatomic) BOOL isCaptionClickPush;
@end

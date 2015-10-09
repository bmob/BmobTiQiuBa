//
//  TeamsViewController.h
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseTableViewController.h"


@interface TeamsViewController : BaseTableViewController<UITextFieldDelegate>
{
    
}


@property (nonatomic,strong) NSString *isSearchBoolStr;


@property (nonatomic) BOOL quitTeamBool;




@end

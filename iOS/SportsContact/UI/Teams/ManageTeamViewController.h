//
//  ManageTeamViewController.h
//  SportsContact
//
//  Created by Nero on 7/22/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "DataDef.h"


@interface ManageTeamViewController : BaseTableViewController<UIScrollViewDelegate,UIAlertViewDelegate,UITextViewDelegate>


@property (nonatomic,strong) Team *teamInfo;

@property (nonatomic) BOOL isCreateteamBool;

@property (nonatomic) BOOL isScoremanagerBool;


@property (nonatomic) BOOL isNearbyAndSearchBool;




@end

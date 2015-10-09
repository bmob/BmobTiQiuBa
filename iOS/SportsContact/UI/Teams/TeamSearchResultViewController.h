//
//  TeamSearchResultViewController.h
//  SportsContact
//
//  Created by Nero on 9/29/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"


@interface TeamSearchResultViewController : BaseTableViewController

@property (strong, nonatomic)  NSString *searchKeyStr;
@property (strong, nonatomic)  NSMutableArray *joinTeamArray;


@end

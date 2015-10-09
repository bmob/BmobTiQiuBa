//
//  CreateTeamViewController.h
//  SportsContact
//
//  Created by Nero on 7/19/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "ValueSettingViewController.h"
#import "ChangeCaptainViewController.h"

#import "DataDef.h"



@interface CreateTeamViewController : BaseTableViewController<UIPickerViewDelegate,
UIPickerViewDataSource,ChangeCaptainSelectionDelegate, ValueSettingDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>



@property (nonatomic,strong) Team *teamInfo;

@property (nonatomic,strong) NSString *isCreateteamBoolStr;


@end

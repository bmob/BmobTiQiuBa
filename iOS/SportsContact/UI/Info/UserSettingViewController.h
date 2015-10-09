//
//  UserSettingViewController.h
//  SportsContact
//
//  Created by bobo on 14-7-18.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ValueSelectionViewController.h"
#import "ValueSettingViewController.h"

@interface UserSettingViewController : BaseTableViewController <UIPickerViewDelegate,
UIPickerViewDataSource, ValueSelectionDelegate, ValueSettingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

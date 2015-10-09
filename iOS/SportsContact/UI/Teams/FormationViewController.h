//
//  FormationViewController.h
//  SportsContact
//
//  Created by Nero on 7/22/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DataDef.h"


@interface FormationViewController : BaseViewController<UIPickerViewDelegate,
UIPickerViewDataSource>

@property (nonatomic, strong) Team *teamInfo;
@property (nonatomic, strong) Lineup *lineup;

@end

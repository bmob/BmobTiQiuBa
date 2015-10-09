//
//  FormationTableViewCell.h
//  SportsContact
//
//  Created by Nero on 7/28/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DataDef.h"

@interface FormationTableViewCell : UITableViewCell<UIScrollViewDelegate>
{
    NSTimer *myTimer;
}


@property (nonatomic,strong) Team *teamInfo;

@property (weak, nonatomic) IBOutlet UIScrollView *teamMemberScrollview;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *namesLabel;
@property (nonatomic, strong) Lineup *lineup;



@end

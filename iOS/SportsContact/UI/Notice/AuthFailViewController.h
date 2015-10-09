//
//  AuthFailViewController.h
//  SportsContact
//
//  Created by Bmob on 15-2-12.
//  Copyright (c) 2015年 CAF. All rights reserved.
//

#import "BaseViewController.h"

@interface AuthFailViewController : BaseViewController

@property (copy,nonatomic) NSString * tournamentID;
@property (copy,nonatomic) NSString * teamID;

@property (strong, nonatomic) IBOutlet UILabel *homeTeamLabel;
@property (strong, nonatomic) IBOutlet UILabel *opponentTeamLabel;
@property (strong, nonatomic) IBOutlet UILabel *homeTeamScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *opponentTeamScoreLabel;

@end

//
//  CompetitionInfoTableViewCell.h
//  SportsContact
//
//  Created by Nero on 7/28/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataDef.h"


@interface CompetitionInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *compitionName;

@property (nonatomic, strong) NSArray *competitionArr;

//@property (nonatomic,strong) Team *teamInfo;



//-(void)loadLeagueData:(NSString *)teamId;


@end

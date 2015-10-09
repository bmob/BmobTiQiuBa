//
//  ScheduleViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-22.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "ScheduleViewController.h"
#import "DataDef.h"
#import "DateUtil.h"
#import "Util.h"
#import "InfoEngine.h"
#import "ScoreManagerViewController.h"
#import "TeamEngine.h"

@interface ScheduleViewController ()

@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) NSArray *schedule;
@property (nonatomic, strong) NSMutableArray *scheduleGroup;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, assign) BOOL isOtherTeam;
@property (nonatomic, assign) BOOL isForTeam;

@end

@implementation ScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.title = @"个人赛程表";

    self.titles = [NSMutableArray arrayWithCapacity:0];
    self.scheduleGroup = [NSMutableArray arrayWithCapacity:0];
    [self orderData];
    [self.tableView reloadData];
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    if (self.isForTeam) {
        [self loadTeamScheduleData];
    }else
    {
        [self loadScheduleData];
    }
}


- (void)loadTeamScheduleData
{
    [TeamEngine getAllHomeTouramentWithTeamId:self.team.objectId limit:1000 block:^(id result1, NSError *error1)
     {
         NSMutableArray *allTeamTouramentArr = [NSMutableArray arrayWithCapacity:0];
         if (!error1)
         {
             //全部主场的比赛
             [allTeamTouramentArr addObjectsFromArray:result1];
             [TeamEngine getAllGusstTouramentWithTeamId:self.team.objectId limit:1000 block:^(id result2, NSError *error2)
              {
                  [self.refreshControl endRefreshing];
                  if (!error2)
                  {
                      //全部客场的比赛
                      [allTeamTouramentArr addObjectsFromArray:result2];
                      //tourament按照时间，时间降序排列，8-20、8-7、7-19
                      NSArray *allRankedTouramentArr = [self rankTheArrWithStarttime:allTeamTouramentArr kind:@"1"];
                      NSDate *serverDate = [NSDate dateFromServer];

                      NSMutableArray *scheduleTotalArr = [[NSMutableArray alloc] init];
                      for (Tournament *tourament in allRankedTouramentArr)
                      {
                          if ([tourament.start_time isLaterThanDate:serverDate])
                          {
                              [scheduleTotalArr addObject:tourament];
                          }
                      }
                      self.schedule = scheduleTotalArr;
                      [self orderData];
                      [self.tableView reloadData];
                  }
                  else
                  {
                      [self showMessage:[error2 localizedDescription]];
                  }
              }];
         }
         else
         {
             [self.refreshControl endRefreshing];
             [self showMessage:[error1 localizedDescription]];
         }
     }];
}


-(NSArray *)rankTheArrWithStarttime:(NSMutableArray *)sortArray kind:(NSString *)kindNumber
{
    
    NSComparator cmptr = ^(Tournament *match1, Tournament *match2)
    {
        if ([kindNumber isEqualToString:@"0"])
        {
            
            //战绩的时间降序
            if ([match1.start_time isLaterThanDate:match2.start_time])
            {
                return (NSComparisonResult)NSOrderedAscending;//升序
                
            }
            else
            {
                return (NSComparisonResult)NSOrderedDescending;//降序
                
            }
        }
        else if ([kindNumber isEqualToString:@"1"])
        {
            
            //赛程时间升序
            if ([match1.start_time isEarlierThanDate:match2.start_time])
            {
                return (NSComparisonResult)NSOrderedAscending;//升序
                
            }
            else
            {
                return (NSComparisonResult)NSOrderedDescending;//降序
                
            }
            
            
        }
        
        
        
        
        return (NSComparisonResult)NSOrderedSame;
        
    };
    
    
    
    
    //第一种排序
    NSArray *array = [sortArray sortedArrayUsingComparator:cmptr];
    
    
    //         BDLog(@"*********%@",array);
    
    
    
    return array;
}


- (void)loadScheduleData
{
    [InfoEngine getScheduleMatchWithUserId:self.userInfo.objectId block:^(id result, NSError *error)
     {
         [self.refreshControl endRefreshing];
         if (error)
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             self.schedule = result;
             [self orderData];
             [self.tableView reloadData];
         }
         
     }];
}

- (void)loadTeamsToTransformNextWithMatch:(Tournament *)match
{
    if (self.team)
    {
        UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
        ScoreManagerViewController *scoreViewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"ScoreManagerViewController"];
        scoreViewController.match = match;
        scoreViewController.team = self.team;
        scoreViewController.canEdit = NO;
        scoreViewController.userInfo = self.userInfo;
        scoreViewController.isOtherTeam = self.isOtherTeam;
        [self.navigationController pushViewController:scoreViewController animated:YES];
    }else
    {
        [self showLoadingView];
        [InfoEngine getTeamsWithUserId:self.userInfo.objectId block:^(id result, NSError *error)
         {
             [self hideLoadingView];
             if (!error)
             {
                 
                 if ([(NSArray*)result count] == 0)
                 {
                     [self showMessage:@"无所属球队！"];
                 }else
                 {
                     Team *matchTeam = nil;
                     if([(NSArray*)result count] == 1)
                     {
                         matchTeam = [result firstObject];
                     }else
                     {
                         for (Team *team in result)
                         {
                             if([team.objectId isEqualToString:match.home_court.objectId] || [team.objectId isEqualToString:match.opponent.objectId])
                             {
                                 matchTeam = team;
                             }
                         }
                     }
                     if (matchTeam)
                     {
                         UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
                         ScoreManagerViewController *scoreViewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"ScoreManagerViewController"];
                         scoreViewController.match = match;
                         scoreViewController.team = matchTeam;
                         scoreViewController.canEdit = NO;
                         scoreViewController.userInfo = self.userInfo;
                         [self.navigationController pushViewController:scoreViewController animated:YES];
                     }else
                     {
                         [self showMessage:@"加载所属球队错误！"];
                     }
                 }
             }else
             {
                 [self showMessage:@"加载所属球队错误！"];
                 
             }
             
         }];
    }
    
}


- (void)orderData
{
    if (!self.schedule || [self.schedule count] == 0)
    {
        return ;
    }
    self.titles = [NSMutableArray arrayWithCapacity:0];
    self.scheduleGroup = [NSMutableArray arrayWithCapacity:0];
    NSString *tempTitle = nil;
    NSMutableArray *tempArray = nil;
    for (Tournament *match in self.schedule)
    {
        if (match.start_time == nil) {
            continue ;
        }
        NSString *title =  [NSString stringWithFormat:@"%ld年", (long)match.start_time.year];
        if (tempTitle == nil)
        {
            tempTitle = title;
            tempArray = [NSMutableArray arrayWithCapacity:0];
            [self.scheduleGroup addObject:tempArray];
            [self.titles  addObject:tempTitle];
             [tempArray addObject:match];
        }else if ([tempTitle isEqualToString:title])
        {
            [tempArray addObject:match];
        }else
        {
            tempArray = [NSMutableArray arrayWithCapacity:0];
            tempTitle = title;
            [self.scheduleGroup addObject:tempArray];
            [self.titles  addObject:tempTitle];
            [tempArray addObject:match];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.titles count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 22.0f)];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    bgView.image = [UIImage imageNamed:@"cell_title_bg"];
    [headerView addSubview:bgView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 300.0, 22.0f)];
    titleLabel.text = [self.titles objectAtIndex:section];
    titleLabel.textColor = UIColorFromRGB(0x898989);
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [headerView addSubview:titleLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schedule_cell"];
    Tournament *match = [[self.scheduleGroup objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    UILabel *dayLabel = (id)[cell.contentView viewWithTag:0xF0];
    dayLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"MM月dd"];
    UILabel *timeLabel = (id)[cell.contentView viewWithTag:0xF1];
    timeLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"HH:mm"];
    
    UILabel *peopleLabel = (id)[cell.contentView viewWithTag:0xF2];
    peopleLabel.text = @"";
    UILabel *leagueNameLabel = (id)[cell.contentView viewWithTag:0xF3];
    leagueNameLabel.text = match.league.name ? match.league.name : tournamentTypeStringFromEnum([match.nature integerValue]);
    UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF4];
    nameLabel.text = [NSString stringWithFormat:@"%@ - %@", match.home_court.name, match.opponent.name];
    UILabel *addressLabel = (id)[cell.contentView viewWithTag:0xF5];
    addressLabel.text = match.site;
    
    UIImageView *line1 = (id)[cell.contentView viewWithTag:0xF6];
    line1.hidden = indexPath.row == 0;
    UIImageView *line2 = (id)[cell.contentView viewWithTag:0xF7];
    line2.hidden = indexPath.row == [(NSArray*)[self.scheduleGroup objectAtIndex:indexPath.section] count] - 1;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray*)[self.scheduleGroup objectAtIndex:section] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     Tournament *match = [[self.scheduleGroup objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self loadTeamsToTransformNextWithMatch:match];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

//
//  PerformanceViewController.m
//  SportsContact
//
//  Created by Nero on 7/22/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "PerformanceViewController.h"
#import "DataDef.h"
#import "DateUtil.h"
#import "Util.h"
#import "TeamEngine.h"
#import "ScoreManagerViewController.h"
#import "TeamEngine.h"

@interface PerformanceViewController ()


@property (nonatomic,strong) NSString *isInTheTeamBool;
@property (nonatomic, strong) NSArray *exploitsArr;
@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) Team *team;
@property (nonatomic, assign) BOOL isOtherTeam;
@property (nonatomic, strong) NSMutableArray *exploitsGroupArr;
@property (nonatomic, strong) NSMutableArray *titles;


@property (nonatomic, strong) NSMutableArray *selfPlayerScoreArr;

//@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation PerformanceViewController

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
    // Do any additional setup after loading the view.
    
    
    BDLog(@"**********%lu",(unsigned long)[self.exploitsArr count]);
    
    
    self.titles = [NSMutableArray arrayWithCapacity:0];
    self.exploitsGroupArr = [NSMutableArray arrayWithCapacity:0];
    [self orderData];
    [self loadPlayerScoreData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefresh) name:kObserverMatchInfoChanged object:nil];
    
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


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isNeedRefresh) {
        self.isNeedRefresh = NO;
        
//        [self loadPlayerScoreData];

        [self loadTeamExploitsData];
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

//获取tourament
- (void)loadTeamExploitsData
{
    [self showLoadingView];
    [TeamEngine getAllHomeTouramentWithTeamId:self.team.objectId limit:1000  block:^(id result1, NSError *error1)
     {
         NSMutableArray *allTeamTouramentArr = [NSMutableArray arrayWithCapacity:0];
         if (!error1)
         {
             //全部主场的比赛
             [allTeamTouramentArr addObjectsFromArray:result1];
             [TeamEngine getAllGusstTouramentWithTeamId:self.team.objectId  limit:1000 block:^(id result2, NSError *error2)
             {
                 if (!error2)
                 {
                     [self hideLoadingView];
                      //全部客场的比赛
                     [allTeamTouramentArr addObjectsFromArray:result2];
                     //tourament按照时间，时间降序排列，8-20、8-7、7-19
                     NSArray *allRankedTouramentArr = [self rankTheArrWithStarttime:allTeamTouramentArr kind:@"0"];
                     NSDate *serverDate = [NSDate dateFromServer];
                     NSMutableArray *exploitsTotalArr = [[NSMutableArray alloc] init];
                     for (Tournament *tourament in allRankedTouramentArr)
                     {
                         if (![tourament.start_time isLaterThanDate:serverDate])
                         {
                             [exploitsTotalArr addObject:tourament];
                         }
                     }
                     self.exploitsArr = exploitsTotalArr;
                     
                     BDLog(@"***********%lu",(unsigned long)[self.exploitsArr count]);
                     
                     [self orderData];
                     [self loadPlayerScoreData];
                 }
                 else
                 {
                     [self showMessage:[error2 localizedDescription]];
                 }
             }];
         }
         else
         {
             [self showMessage:[error1 localizedDescription]];
             [self hideLoadingView];
         }
     }];
}

- (void)loadPlayerScoreData
{
    [self showLoadingView];
    [TeamEngine getPlayerScoreWithUserID:[[BmobUser getCurrentUser] objectId] block:^(id result, NSError *error) {
        
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            self.selfPlayerScoreArr = result;
            
            
            [self.tableView reloadData];
            
            [self hideLoadingView];
        }
        
    }];
}

- (void)orderData
{
    if (!self.exploitsArr || [self.exploitsArr count] == 0)
    {
        return ;
    }
    self.titles = [NSMutableArray arrayWithCapacity:0];
    self.exploitsGroupArr = [NSMutableArray arrayWithCapacity:0];
    
    NSString *tempTitle = nil;
    NSMutableArray *tempArray = nil;
    
    for (Tournament *match in self.exploitsArr)
    {
        NSString *title =  [NSString stringWithFormat:@"%ld年", (long)match.start_time.year];

        if (tempTitle == nil)
        {
            tempTitle = title;
            tempArray = [NSMutableArray arrayWithCapacity:0];
            [self.exploitsGroupArr addObject:tempArray];
            [self.titles  addObject:tempTitle];
            [tempArray addObject:match];
        }else if ([tempTitle isEqualToString:title])
        {
            [tempArray addObject:match];
        }else
        {
            tempArray = [NSMutableArray arrayWithCapacity:0];
            tempTitle = title;
            [self.exploitsGroupArr addObject:tempArray];
            [self.titles  addObject:tempTitle];
            [tempArray addObject:match];
        }
    }
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

#pragma mark - Table view data source

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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.titles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray*)[self.exploitsGroupArr objectAtIndex:section] count];
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExploitsCell"];
    
    Tournament *match = [[self.exploitsGroupArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
//    NSString *dateTotal=[NSString stringWithFormat:@"%@",match.start_time];
    
    UILabel *dayLabel = (id)[cell.contentView viewWithTag:0xF0];
    dayLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"MM月dd"];
    
    UILabel *timeLabel = (id)[cell.contentView viewWithTag:0xF1];
    timeLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"HH:mm"];
    
    
    
    
    UILabel *leagueNameLabel = (id)[cell.contentView viewWithTag:0xF3];
    leagueNameLabel.text = match.league.name ? match.league.name : tournamentTypeStringFromEnum([match.nature integerValue]);
    
    
    UILabel *competitionNameLabel = (id)[cell.contentView viewWithTag:0xF4];
    competitionNameLabel.text = match.home_court.name;
    
    UILabel *scoreLabel = (id)[cell.contentView viewWithTag:0xF8];
    
    BOOL  isHomeCourt= [ self.team.objectId isEqualToString:match.home_court.objectId];
    if (isHomeCourt)
    {
        scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [match.score_h intValue], [match.score_h2 intValue]];
    }else
    {
        scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [match.score_o2 intValue], [match.score_o intValue]];
    }
    
    UILabel *opponentNameLabel = (id)[cell.contentView viewWithTag:0xF9];
    opponentNameLabel.text = match.opponent.name;
    
    UIImageView *attestationView = (id)[cell.contentView viewWithTag:1];
    if (match.isVerify)
    {
        attestationView.hidden = NO;
    }
    else
    {
        attestationView.hidden = YES;
    }
    UIImageView *line1 = (id)[cell.contentView viewWithTag:0xF6];
    line1.hidden = indexPath.row == 0;
    UIImageView *line2 = (id)[cell.contentView viewWithTag:0xF7];
    line2.hidden = indexPath.row == [(NSArray*)[self.exploitsGroupArr objectAtIndex:indexPath.section] count] - 1;
    UIView *selfPerformView=(id)[cell.contentView viewWithTag:0xF5];
    
    if ([self.isInTheTeamBool isEqualToString:@"YES"])
    {
        selfPerformView.hidden=NO;
        
        
        for (PlayerScore *score in self.selfPlayerScoreArr)
        {
            BDLog(@"**********%@*********%@",match.objectId,score.competition.objectId);
            
            if ([match.objectId isEqualToString:score.competition.objectId])
            {
                
                UILabel *goalsLabel = (id)[cell.contentView viewWithTag:0xFA];
                goalsLabel.text = [NSString stringWithFormat:@"%@", score.goals];
                
                UILabel *assistsLabel = (id)[cell.contentView viewWithTag:0xFB];
                assistsLabel.text = [NSString stringWithFormat:@"%@", score.assists];
                
                break;
            }
            else
            {
                
                UILabel *goalsLabel = (id)[cell.contentView viewWithTag:0xFA];
                goalsLabel.text = @"0";
                
                UILabel *assistsLabel = (id)[cell.contentView viewWithTag:0xFB];
                assistsLabel.text = @"0";

                
            }
            
            
        }
        
        
    }
    else if ([self.isInTheTeamBool isEqualToString:@"NO"])
    {
        selfPerformView.hidden=YES;
    }
    else
    {
        
    }

    return cell;

    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tournament *match = [[self.exploitsGroupArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
    ScoreManagerViewController *scoreViewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"ScoreManagerViewController"];
    scoreViewController.match = match;
    scoreViewController.team = self.team;
    scoreViewController.canEdit = YES;
    scoreViewController.userInfo = self.userInfo;
    scoreViewController.isOtherTeam = self.isOtherTeam;
    [self.navigationController pushViewController:scoreViewController animated:YES];
}


@end

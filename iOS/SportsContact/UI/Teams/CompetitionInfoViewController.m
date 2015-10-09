//
//  CompetitionInfoViewController.m
//  SportsContact
//
//  Created by Nero on 7/22/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "CompetitionInfoViewController.h"
#import "DataDef.h"
#import "DateUtil.h"
#import "Util.h"
#import "ViewUtil.h"

#import "InfoEngine.h"
#import "LeagueEngine.h"


@interface CompetitionInfoViewController ()


@property (strong, nonatomic)  NSString *leagueName;
@property (strong, nonatomic)  NSString *leagueId;
@property (strong, nonatomic)  NSMutableArray *teamScoreArr;

@property (weak, nonatomic) IBOutlet UITableView *scoreTableview;




@end

@implementation CompetitionInfoViewController

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
    
    self.teamScoreArr=[[NSMutableArray alloc]init];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showLoadingView];
    
        //得出参加的正在参加的联赛
//        [InfoEngine getInfoWithTournament:self.leagueId block:^(id result, NSError *error)
         [LeagueEngine getTeamscoreWithLeagueId:self.leagueId block:^(id result, NSError *error)
         {
             
             
             self.teamScoreArr=result;
             
             if ([self.teamScoreArr count]!=0 )
             {
                 [self.scoreTableview reloadData];
                 
             }
             else
             {
                 
                 UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-25.0, 320.0, 50.0f)];
                 warningLabel.text = @"联赛积分榜暂无信息！";
                 warningLabel.textColor = [UIColor blackColor];
                 warningLabel.textAlignment = NSTextAlignmentCenter;
                 warningLabel.font = [UIFont boldSystemFontOfSize:20.0f];
                 [self.view addSubview:warningLabel];
             }

             

             [self hideLoadingView];
             
             
             
             
             
             
             
             
         }];

//    [self loadScoreboard:self.leagueId];
    
}

-(void)loadScoreboard:(NSString *)leagueId
{
    
    [self showLoadingView];
    __weak typeof(self) weakSelf = self;
    [LeagueEngine getTeamscoreWithLeagueId:leagueId block:^(id result, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            strongSelf.teamScoreArr=result;
            NSMutableArray  *nameArray = [NSMutableArray array];
            for (LeagueScoreStat *score in result) {
                NSString *name = [score.name copy];
                if (name && ![nameArray containsObject:name]) {
                    [nameArray addObject:name];
                }
            }
            //排序
            [nameArray setArray:[nameArray sortedArrayUsingSelector:@selector(compare:)]];
            
            NSMutableArray *scoreArray = [NSMutableArray array];
            for (NSString *name in nameArray) {
                NSMutableArray *tmpArray = [NSMutableArray array];
                for (LeagueScoreStat * score in result) {
                    if ([score.name isEqualToString:name]) {
                        [tmpArray addObject:score];
                    }
                }
                NSDictionary *dic = @{@"number":name,@"content":tmpArray};
                [scoreArray addObject:dic];
            }
            
            strongSelf.teamScoreArr = scoreArray;
            if ([strongSelf.teamScoreArr count] != 0 )
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.scoreTableview reloadData];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-25.0, 320.0, 50.0f)];
                    warningLabel.text = @"联赛积分榜暂无信息！";
                    warningLabel.textColor = [UIColor blackColor];
                    warningLabel.textAlignment = NSTextAlignmentCenter;
                    warningLabel.font = [UIFont boldSystemFontOfSize:20.0f];
                    [strongSelf.view addSubview:warningLabel];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf hideLoadingView];
            });
        });
        
    }];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 23.0f)];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    bgView.image = [UIImage imageNamed:@"cell_title_bg"];
    [headerView addSubview:bgView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 300.0, 23.0f)];
    titleLabel.text = @"联赛积分榜";
    titleLabel.textColor = UIColorFromRGB(0x898989);
    titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [headerView addSubview:titleLabel];
    return headerView;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        return 21;
    }
    else
    {
        return 25;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return [self.teamScoreArr count]+1;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    if (indexPath.row==0)
    {
        cell=[tableView dequeueReusableCellWithIdentifier:@"CompetitionLabelCell"];

    }
    else
    {
        
        LeagueScoreStat *teamscore=[self.teamScoreArr objectAtIndex:indexPath.row-1];

        cell=[tableView dequeueReusableCellWithIdentifier:@"CompetitionTeamCell"];
        
        
        
            UILabel *rankLabel = (id)[cell.contentView viewWithTag:1];
            rankLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
            
            UILabel *teamNameLabel = (id)[cell.contentView viewWithTag:2];
            teamNameLabel.text=teamscore.team.name;
        
            
            UILabel *winLabel = (id)[cell.contentView viewWithTag:3];
            winLabel.text=[teamscore.win stringValue];
        
            UILabel *drawLabel = (id)[cell.contentView viewWithTag:4];
        drawLabel.text=[teamscore.draw stringValue];
        
            UILabel *lossLabel = (id)[cell.contentView viewWithTag:5];
        lossLabel.text=[teamscore.loss stringValue];
        
            UILabel *goalsLabel = (id)[cell.contentView viewWithTag:6];
        goalsLabel.text=[teamscore.goals stringValue];
        
            UILabel *goals_againstLabel = (id)[cell.contentView viewWithTag:7];
        goals_againstLabel.text=[teamscore.goalsAgainst stringValue];
        
            UILabel *goal_differenceLabel = (id)[cell.contentView viewWithTag:8];
        goal_differenceLabel.text=[teamscore.goalDifference stringValue];
        
            UILabel *scoreLabel = (id)[cell.contentView viewWithTag:9];
        scoreLabel.text=[teamscore.points stringValue];
        
            
        
        
        


    }
    
    
    if (indexPath.row%2 == 0) {
        cell.contentView.backgroundColor = [ViewUtil hexStringToColor:@"ffffff"];
    }else{
        cell.contentView.backgroundColor = [ViewUtil hexStringToColor:@"f1f2f4"];
    }
    
    
    
    
    
    
    
    return cell;
    
    
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//    return self.teamScoreArr.count;
//}
//
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSDictionary *dic = [self.teamScoreArr objectAtIndex:section];
//    NSString *key = [dic objectForKey:@"number"];
//    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 22.0f)];
//    UIImageView *bgView = [[UIImageView alloc] initWithFrame:headerView.bounds];
//    bgView.image = [UIImage imageNamed:@"cell_title_bg"];
//    [headerView addSubview:bgView];
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 300.0, 22.0f)];
//    titleLabel.text =[NSString stringWithFormat:@"%@ 第%@组",self.leagueName,key] ;
//    titleLabel.textColor = UIColorFromRGB(0x898989);
//    titleLabel.font = [UIFont systemFontOfSize:10.0f];
//    [headerView addSubview:titleLabel];
//    return headerView;
//    
//    
//    
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row==0)
//    {
//        return 21;
//    }
//    else
//    {
//        return 25;
//    }
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSDictionary *dic = [self.teamScoreArr objectAtIndex:section];
//    NSArray *array = [dic objectForKey:@"content"];
//    return array.count+1;//[self.teamScoreArr count]+1;
//    
//    
//}
//
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    UITableViewCell *cell;
//    
//    if (indexPath.row==0)
//    {
//        cell=[tableView dequeueReusableCellWithIdentifier:@"ScoreboardLabelCell"];
//        
//    }
//    else
//    {
//        
//        
//        //        TeamScore *teamscore=[self.teamScoreArr objectAtIndex:indexPath.row-1];
//        NSDictionary *dic = [self.teamScoreArr objectAtIndex:indexPath.section];
//        
//        NSArray *array = [dic objectForKey:@"content"];
//        
//        LeagueScoreStat *teamscore=[array objectAtIndex:indexPath.row-1];//[self.teamScoreArr objectAtIndex:indexPath.row-1];
//        
//        
//        cell=[tableView dequeueReusableCellWithIdentifier:@"ScoreboardNumberCell"];
//        
//        
//        
//        UILabel *rankLabel = (id)[cell.contentView viewWithTag:1];
//        rankLabel.text=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
//        
//        UILabel *teamNameLabel = (id)[cell.contentView viewWithTag:2];
//        teamNameLabel.text=teamscore.team.name;
//        
//        
//        UILabel *winLabel = (id)[cell.contentView viewWithTag:3];
//        winLabel.text=[teamscore.win stringValue];
//        
//        UILabel *drawLabel = (id)[cell.contentView viewWithTag:4];
//        drawLabel.text=[teamscore.draw stringValue];
//        
//        UILabel *lossLabel = (id)[cell.contentView viewWithTag:5];
//        lossLabel.text=[teamscore.loss stringValue];
//        
//        UILabel *goalsLabel = (id)[cell.contentView viewWithTag:6];
//        goalsLabel.text=[teamscore.goals stringValue];
//        
//        UILabel *goals_againstLabel = (id)[cell.contentView viewWithTag:7];
//        goals_againstLabel.text=[teamscore.goalsAgainst stringValue];
//        
//        UILabel *goal_differenceLabel = (id)[cell.contentView viewWithTag:8];
//        goal_differenceLabel.text=[teamscore.goalDifference stringValue];
//        
//        UILabel *scoreLabel = (id)[cell.contentView viewWithTag:9];
//        scoreLabel.text=[teamscore.points stringValue];
//        
//        
//        
//        
//        
//        
//        
//    }
//    
//    
//    if (indexPath.row%2 == 0) {
//        cell.contentView.backgroundColor = [ViewUtil hexStringToColor:@"ffffff"];
//    }else{
//        cell.contentView.backgroundColor = [ViewUtil hexStringToColor:@"f1f2f4"];
//    }
//    
//    
//    
//    
//    return cell;
//    
//    
//    
//    
//    
//}


@end

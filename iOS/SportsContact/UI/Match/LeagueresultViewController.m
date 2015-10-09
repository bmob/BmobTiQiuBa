//
//  LeagueresultViewController.m
//  SportsContact
//
//  Created by Nero on 8/16/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "LeagueresultViewController.h"
#import "LeagueEngine.h"
#import "DataDef.h"
#import "DateUtil.h"
#import "Util.h"




@interface LeagueresultViewController ()
//@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic)  NSMutableArray *totalArr;
@property (strong, nonatomic)  NSMutableArray *touramentResultArr;
@property (nonatomic, strong) NSMutableArray *titlesArr;


@property (nonatomic, strong) NSMutableArray *playerGoalArr;



@end

@implementation LeagueresultViewController

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
    
    
    self.titlesArr = [NSMutableArray arrayWithCapacity:0];

    self.touramentResultArr = [NSMutableArray arrayWithCapacity:0];

    self.totalArr = [NSMutableArray arrayWithCapacity:0];

    [self loadLeagueresult:self.leagueId];
    
    self.tableView.scrollsToTop=YES;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



-(void)loadTheScroreCount:(NSString *)leagueId
{
    
    [self showLoadingView];
    [LeagueEngine getFootballerGoalWithLeagueId:leagueId block:^(id result, NSError *error) {
        
        
        self.playerGoalArr=result;
        
        if ([self.playerGoalArr count]!=0 )
        {
            [self.tableView reloadData];
            
        }
        else
        {
            
            UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-25.0, 320.0, 50.0f)];
            warningLabel.text = @"联赛战绩表暂无信息！";
            warningLabel.textColor = [UIColor blackColor];
            warningLabel.textAlignment = NSTextAlignmentCenter;
            warningLabel.font = [UIFont boldSystemFontOfSize:20.0f];
            [self.view addSubview:warningLabel];
        }

        
        
        [self hideLoadingView];
        
    }];

    
    
    
}




-(void)loadLeagueresult:(NSString *)leagueId
{
    
    [LeagueEngine getLeagueResultWithLeagueId:leagueId block:^(id result, NSError *error) {
        
        
        
        
        self.totalArr=result;
        
        [self orderData];

        
//        [self.tableView reloadData];
        
        [self loadTheScroreCount:self.leagueId];

        
        
    }];
    
    
    
}








- (void)orderData
{
    if (!self.totalArr || [self.totalArr count] == 0)
    {
        return ;
    }
    
    NSString *tempTitle = nil;
    NSMutableArray *tempArray = nil;
    
    for (Tournament *match in self.totalArr)
    {
        NSString *title =  [NSString stringWithFormat:@"%ld年", (long)match.start_time.year];
        
        
        if (tempTitle == nil)
        {
            tempTitle = title;
            tempArray = [NSMutableArray arrayWithCapacity:0];
            [self.touramentResultArr addObject:tempArray];
            [self.titlesArr  addObject:tempTitle];
            [tempArray addObject:match];
            
        }else if ([tempTitle isEqualToString:title])
        {
            [tempArray addObject:match];
            
        }else
        {
            tempArray = [NSMutableArray arrayWithCapacity:0];
            tempTitle = title;
            [self.touramentResultArr addObject:tempArray];
            [self.titlesArr  addObject:tempTitle];
            [tempArray addObject:match];
        }
        
        
    }
}



#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 22.0f)];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    bgView.image = [UIImage imageNamed:@"cell_title_bg"];
    [headerView addSubview:bgView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 300.0, 22.0f)];
    titleLabel.text = [self.titlesArr objectAtIndex:section];
    titleLabel.textColor = UIColorFromRGB(0x898989);
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [headerView addSubview:titleLabel];
    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.titlesArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //根据返回的比赛球员得分，控制高度
    
//    Tournament *match = [[self.touramentResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//
//    NSInteger maxGoal=[match.score_h intValue]>=[match.score_o intValue] ? [match.score_h intValue]:[match.score_o intValue];
//    
//    if (maxGoal==0)
//    {
//        return 90;
//    }
//    else
//    {
//        return 90+20*maxGoal;
//    }
    

    return 90;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray*)[self.touramentResultArr objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeagueResultCell"];
    
    Tournament *match = [[self.touramentResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    
    
    BDLog(@"**********%@",match.start_time);
    
//    NSString *dateTotal=[NSString stringWithFormat:@"%@",match.start_time];
    
    
    UILabel *dayLabel = (id)[cell.contentView viewWithTag:0xF0];
    dayLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"MM月dd"];
//    dayLabel.text = [NSString stringWithFormat:@"%@月%@日",[dateTotal substringWithRange:NSMakeRange(5,2)],[dateTotal substringWithRange:NSMakeRange(8,2)]];

    
    
    
    UILabel *timeLabel = (id)[cell.contentView viewWithTag:0xF1];
    timeLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"HH:mm"];
//    timeLabel.text = [NSString stringWithFormat:@"%@",[dateTotal substringWithRange:NSMakeRange(11,5)]];
    
    
    
    UILabel *leagueNameLabel = (id)[cell.contentView viewWithTag:0xF3];
    leagueNameLabel.text = match.league.name ? match.league.name : tournamentTypeStringFromEnum([match.nature integerValue]);
    
    
    UILabel *competitionNameLabel = (id)[cell.contentView viewWithTag:0xF4];
    competitionNameLabel.text = match.home_court.name;
    
    UILabel *scoreLabel = (id)[cell.contentView viewWithTag:0xF8];
    if ([match.score_h length]==0)
    {
        match.score_h=@"0";
    }
    if ([match.score_o length]==0)
    {
        match.score_o=@"0";
    }
    
    scoreLabel.text = [NSString stringWithFormat:@"%@-%@",match.score_h,match.score_o];

    
    UILabel *opponentNameLabel = (id)[cell.contentView viewWithTag:0xF9];
    opponentNameLabel.text = match.opponent.name;
    
    
    UIImageView *attestationView = (id)[cell.contentView viewWithTag:1];
    if (match.isVerify)
    {
        attestationView.hidden=NO;
    }
    else
    {
        attestationView.hidden=YES;
    }
    
    
    //得分人员,主场，客场
//    for (int i=0; i<[match.score_h intValue]; i++)
//    {
//        UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100.0,65.0+20*i,10.0,10.0)];
//        imageView.image=[UIImage imageNamed:@"ball.png"];
//        [cell.contentView addSubview:imageView];
//        
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(115, 60+20*i, 80, 20)];
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor lightGrayColor];
//        label.font = [UIFont boldSystemFontOfSize:12];
//        [cell.contentView addSubview:label];
//        
//        
//        for (PlayerScore *plarer in self.playerGoalArr)
//        {
//            if ([plarer.competition.objectId isEqualToString:match.objectId] && [plarer.team.objectId isEqualToString:match.home_court.objectId])
//            {
//                
//                
//                if ([plarer.player.nickname length]!=0)
//                {
//                    label.text=plarer.player.nickname;
//                }
//                else
//                {
//                    label.text=plarer.player.username;
//                }
//                
//                break;
//
//            }
//            else
//            {
//                label.text=@"暂无信息";
//
//            }
//            
//            
//        }
//        
//
//        
//    }
//    
//    for (int i=0; i<[match.score_o intValue]; i++)
//    {
//        
//        UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(205.0,65.0+20*i,10.0,10.0)];
//        imageView.image=[UIImage imageNamed:@"ball.png"];
//        [cell.contentView addSubview:imageView];
//
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(220, 60+20*i, 80, 20)];
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor lightGrayColor];
//        label.font = [UIFont boldSystemFontOfSize:12];
//        [cell.contentView addSubview:label];
//
//        
//        for (PlayerScore *plarer in self.playerGoalArr)
//        {
//            
//            if ([plarer.competition.objectId isEqualToString:match.objectId] && [plarer.team.objectId isEqualToString:match.opponent.objectId])
//            {
//                label.text=plarer.player.nickname;
//                break;
//            }
//            else
//            {
//                label.text=@"暂无信息";
//                
//            }
//            
//            
//        }
//        
//        
//    }

    
    
    

    
    
    NSInteger maxGoal=0;//[match.score_h intValue]>=[match.score_o intValue] ? [match.score_h intValue]:[match.score_o intValue];

    
    UIImageView *line1 = (id)[cell.contentView viewWithTag:0xF6];
    line1.hidden = indexPath.row == 0;
    
    UIImageView *line2 = (id)[cell.contentView viewWithTag:0xF7];
    [line2 setFrame:CGRectMake(81, 22, 1, 78+20*maxGoal)];
    
    line2.hidden = indexPath.row == [(NSArray*)[self.touramentResultArr objectAtIndex:indexPath.section] count] - 1;
    
    return cell;
    
    
}





@end

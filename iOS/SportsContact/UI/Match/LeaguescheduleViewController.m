//
//  LeaguescheduleViewController.m
//  SportsContact
//
//  Created by Nero on 8/16/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "LeaguescheduleViewController.h"
#import "LeagueEngine.h"
#import "DataDef.h"
#import "DateUtil.h"
#import "Util.h"





@interface LeaguescheduleViewController ()
//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic)  NSMutableArray *totalArr;
@property (strong, nonatomic)  NSMutableArray *touramentScheduleArr;
@property (nonatomic, strong) NSMutableArray *titlesArr;


@end

@implementation LeaguescheduleViewController

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
    
    self.touramentScheduleArr = [NSMutableArray arrayWithCapacity:0];
    
    self.totalArr = [NSMutableArray arrayWithCapacity:0];

    
    
    [self loadLeagueschedule:self.leagueId];
    
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







-(void)loadLeagueschedule:(NSString *)leagueId
{
    
    [self showLoadingView];
    [LeagueEngine getLeagueScheduleWithLeagueId:leagueId block:^(id result, NSError *error) {
        
        
        //数组按时间，升序排列
        NSMutableArray *sourceArr=[[NSMutableArray alloc]init];
        sourceArr=result;
        
        //赛程，按照starttime排序,时间升序
        if ([sourceArr count]>=2)
        {
            //tourament按照时间，时间升序排列，10.1、10.2
            NSArray *allRankedTouramentArr=[[NSArray alloc]init];
            
            allRankedTouramentArr=[self rankTheArrWithStarttime:sourceArr kind:@"1"];
            
            //                        self.scheduleTotalArr=nil;
            
            for (Tournament *match in allRankedTouramentArr)
            {
                [self.totalArr addObject:match];
            }
        }else
        {
            self.totalArr = sourceArr;
        }

        
        
        
        
        
        
        
        
//        self.totalArr=result;
        
        
        
        
        
        [self orderData];
        
        if ([self.totalArr count]!=0 )
        {
            [self.tableView reloadData];
            
        }
        else
        {
            
            UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-25.0, 320.0, 50.0f)];
            warningLabel.text = @"联赛赛程表暂无信息！";
            warningLabel.textColor = [UIColor blackColor];
            warningLabel.textAlignment = NSTextAlignmentCenter;
            warningLabel.font = [UIFont boldSystemFontOfSize:20.0f];
            [self.view addSubview:warningLabel];
        }

        

        [self hideLoadingView];
        
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
        //        NSString *title =@"11111";
        
        
        if (tempTitle == nil)
        {
            tempTitle = title;
            tempArray = [NSMutableArray arrayWithCapacity:0];
            [self.touramentScheduleArr addObject:tempArray];
            [self.titlesArr  addObject:tempTitle];
            [tempArray addObject:match];
            
        }else if ([tempTitle isEqualToString:title])
        {
            [tempArray addObject:match];
            
        }else
        {
            tempArray = [NSMutableArray arrayWithCapacity:0];
            tempTitle = title;
            [self.touramentScheduleArr addObject:tempArray];
            [self.titlesArr  addObject:tempTitle];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray*)[self.touramentScheduleArr objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeagueScheduleCell"];
    
    Tournament *match = [[self.touramentScheduleArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    UILabel *dayLabel = (id)[cell.contentView viewWithTag:0xF0];
    dayLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"MM月dd"];
    UILabel *timeLabel = (id)[cell.contentView viewWithTag:0xF1];
    timeLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"HH:mm"];
    
    
    
    
    UILabel *leagueNameLabel = (id)[cell.contentView viewWithTag:0xF3];
    leagueNameLabel.text = match.league.name ? match.league.name : tournamentTypeStringFromEnum([match.nature integerValue]);
    
    UILabel *competitionNameLabel = (id)[cell.contentView viewWithTag:0xF4];
    competitionNameLabel.text = [NSString stringWithFormat:@"%@ - %@",match.home_court.name,match.opponent.name];
    
    
    UILabel *siteLabel = (id)[cell.contentView viewWithTag:0xF5];
    siteLabel.text = match.site;

    
    
    
    UIImageView *line1 = (id)[cell.contentView viewWithTag:0xF6];
    line1.hidden = indexPath.row == 0;
    UIImageView *line2 = (id)[cell.contentView viewWithTag:0xF7];
    line2.hidden = indexPath.row == [(NSArray*)[self.touramentScheduleArr objectAtIndex:indexPath.section] count] - 1;
    
    
    return cell;
    
    
}







@end

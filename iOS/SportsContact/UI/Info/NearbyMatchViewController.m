//
//  NearbyMatchViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-22.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "NearbyMatchViewController.h"
#import "InfoEngine.h"
#import "DateUtil.h"
#import "ScoreManagerViewController.h"

@interface NearbyMatchViewController ()

@property (nonatomic, strong) NSArray *matchs;

@end

@implementation NearbyMatchViewController

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
    self.title = @"附近的比赛";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadMatchData];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

//match_cell
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadMatchData
{
    [self showLoadingView];
    [InfoEngine getNearByMatchWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error)
    {
        [self hideLoadingView];
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            self.matchs = result;
            if (!self.matchs  || [self.matchs count] == 0) {
                [self showMessage:@"暂无记录"];
            }
            [self.tableView reloadData];
        }
    }];
    
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"match_cell"];
    Tournament *match = [self.matchs objectAtIndex:indexPath.row];
    UILabel *dayLabel = (id)[cell.contentView viewWithTag:0xF0];
    dayLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"MM月dd"];
    UILabel *timeLabel = (id)[cell.contentView viewWithTag:0xF1];
    timeLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"HH:mm"];
    
    UILabel *peopleLabel = (id)[cell.contentView viewWithTag:0xF2];
    peopleLabel.text = @"";
    UILabel *leagueNameLabel = (id)[cell.contentView viewWithTag:0xF3];
    leagueNameLabel.text = match.league.name ? match.league.name : tournamentTypeStringFromEnum([match.nature integerValue]);
    UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF4];
    nameLabel.text = [NSString stringWithFormat:@"%@ - %@", match.home_court.name ? match.home_court.name : @"", match.opponent.name ? match.opponent.name : @""];
    UILabel *addressLabel = (id)[cell.contentView viewWithTag:0xF5];
    addressLabel.text = match.site;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.matchs count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     Tournament *match = [self.matchs objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
    ScoreManagerViewController *scoreViewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"ScoreManagerViewController"];
    scoreViewController.match = match;
    scoreViewController.team = match.home_court;
    scoreViewController.canEdit = NO;
//    scoreViewController.userInfo = self.userInfo;
    scoreViewController.isOtherTeam = YES;
    [self.navigationController pushViewController:scoreViewController animated:YES];
}

@end

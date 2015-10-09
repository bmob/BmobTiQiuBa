//
//  MatchSearchResultViewController.m
//  SportsContact
//
//  Created by Nero on 9/24/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "MatchSearchResultViewController.h"
#import "LeagueEngine.h"
#import "MatchDetailViewController.h"

@interface MatchSearchResultViewController ()

@property (strong, nonatomic)  NSMutableArray *leagueArray;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation MatchSearchResultViewController




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
    
    self.leagueArray=[[NSMutableArray alloc]init];
    
    [self getSearchTouramentMessage:self.searchKeyStr];
    
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








-(void)getSearchTouramentMessage:(NSString *)touramentName
{
    
    [self showLoadingView];
    
    //关键字搜索？
    [LeagueEngine getSearchWithTouramentName:touramentName block:^(id result, NSError *error) {
        
        
        [self hideLoadingView];
        
        
//        //模糊搜索
        
        self.leagueArray=result;
        
        if ([self.leagueArray count]!=0)
        {
            [self.tableView reloadData];

        }
        else
        {
            [self showMessage:@"暂无搜索结果！"];
        }
        
        
        
        
        
    }];
    
    
    
    
}



#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.leagueArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTournamentCell"];

    UILabel *itemLabel = (id)[cell.contentView viewWithTag:0xF1];
    
    League *league = [self.leagueArray objectAtIndex:indexPath.row];
    
//    League *league=[[League alloc] initWithDictionary:[self.leagueArray objectAtIndex:indexPath.row]];

    
    itemLabel.text=league.name;
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    League *league = [self.leagueArray objectAtIndex:indexPath.row];
    
    MatchDetailViewController *leagueVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MatchDetailViewController"];
    
    leagueVC.leagueName=league.name;
    
    leagueVC.leagueId=league.objectId;//传联赛id
    
    leagueVC.isSearchLeagueBool=YES;
    
    [self.navigationController pushViewController:leagueVC animated:YES];
    
    
    
    
}





#pragma mark - Navigation

 
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end

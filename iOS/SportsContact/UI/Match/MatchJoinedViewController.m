//
//  MatchJoinedViewController.m
//  SportsContact
//
//  Created by Nero on 10/18/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "MatchJoinedViewController.h"
#import "MatchDetailViewController.h"
#import "LeagueEngine.h"


@interface MatchJoinedViewController ()

@property (strong, nonatomic)  NSMutableArray *totalTeamArr;

@property (strong, nonatomic)  NSMutableArray *leagueArray;


//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MatchJoinedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.leagueArray=[[NSMutableArray alloc]init];

    [self getSearchTouramentMessage:self.totalTeamArr];
    
    
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getSearchTouramentMessage:(NSMutableArray *)teamArr
{
    
    
    [self showLoadingView];
    
    if([teamArr count]==0)
    {
        
        [self showMessage:@"暂无参加联赛！"];
        [self hideLoadingView];
        
    }
    else if ([teamArr count]==1)
    {
        
        
        Team *team=[teamArr firstObject];
        
        [LeagueEngine getAllLeagueWithTeamId:team.objectId block:^(id result, NSError *error) {
          
            
            self.leagueArray=result;
            
            [self.tableView reloadData];

            [self hideLoadingView];
            
            
        }];
        
        
    }
    else if ([teamArr count]==2)
    {
        
        //第一支队伍参加的所有联赛
        Team *team1=[teamArr firstObject];

        [LeagueEngine getAllLeagueWithTeamId:team1.objectId block:^(id result1, NSError *error) {
            
            
            NSMutableArray *categoryArray = [[NSMutableArray alloc] init];

            
            
            if ([(NSArray*)result1 count]!=0)
            {
                [categoryArray addObjectsFromArray:result1];
            }
            
            
            //第二支队伍参加的所有联赛
            Team *team2=[teamArr lastObject];
            
            [LeagueEngine getAllLeagueWithTeamId:team2.objectId block:^(id result2, NSError *error) {
                
                
                if ([(NSArray*)result2 count]!=0)
                {
                    [categoryArray addObjectsFromArray:result2];

                    
                }
                
                
                
                
                
                //2支球队的league合并，排重
                
                
                NSSet *set = [NSSet setWithArray:categoryArray];
                BDLog(@"%@",[set allObjects]);
                
                BDLog(@"***********%lu",(unsigned long)[[set allObjects] count]);

                
                
                for (id obj in [set allObjects])
                {
                    [self.leagueArray addObject:obj];
                }
                
                BDLog(@"***********%lu",(unsigned long)[self.leagueArray count]);

                [self.tableView reloadData];
                
                [self hideLoadingView];

                
                
            }];

            
            
            
            
        }];

        
        
        
        
    }
    else
    {
        [self hideLoadingView];
    }
    
    
    
    
    
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JoinLeagueCell"];
    
    UILabel *itemLabel = (id)[cell.contentView viewWithTag:0xF1];
    
    League *league = [self.leagueArray objectAtIndex:indexPath.row];
    
    
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










/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

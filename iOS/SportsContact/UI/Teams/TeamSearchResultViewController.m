//
//  TeamSearchResultViewController.m
//  SportsContact
//
//  Created by Nero on 9/29/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "TeamSearchResultViewController.h"

#import "TeamEngine.h"
#import "ManageTeamViewController.h"
#import "ViewUtil.h"


@interface TeamSearchResultViewController ()

@property (strong, nonatomic)  NSMutableArray *teamArray;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;




@end

@implementation TeamSearchResultViewController

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
    
    self.teamArray=[[NSMutableArray alloc]init];
    
    [self getSearchTeamMessage:self.searchKeyStr];

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

-(void)getSearchTeamMessage:(NSString *)teamName
{
    
    //关键字搜索？
    [TeamEngine getFuzzySearchTeamWithTeamname:teamName block:^(id result, NSError *error) {
        
        
        
        
        
        //        //模糊搜索
        
        self.teamArray=result;
        BDLog(@"***********%lu",(unsigned long)[self.teamArray count]);
        
        
        if ([self.teamArray count]==0)
        {
            [self showMessage:@"暂时搜索结果！"];
        }
        
        
        [self.tableView reloadData];
        
        //        if ([self.touramentArr count]==0)
        //        {
        //            [self showMessage:@"搜不到赛事信息"];
        //
        //            //如果没有加入任何球队，就显示『附近的球队』
        //            [self loadNearbyLeague];
        //
        //
        //        }
        //        else
        //        {
        //            [self.tableView reloadData];
        //            
        //        }
        
        
        
        
        
    }];
    
    
    
    
}




#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.teamArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTeamCell"];
    
    UILabel *itemLabel = (id)[cell.contentView viewWithTag:0xF1];
    
    
    Team *team=[self.teamArray objectAtIndex:indexPath.row];
    
    itemLabel.text=team.name;
    
    
    
    for (id obj in self.joinTeamArray)
    {
        
        Team *jointeam=obj;
        
        if ([jointeam.objectId isEqualToString:team.objectId])
        {
            itemLabel.textColor=[ViewUtil hexStringToColor:@"f47900"];
            cell.userInteractionEnabled=NO;
        }
        else
        {
            itemLabel.textColor=[UIColor grayColor];
            cell.userInteractionEnabled=YES;
        }
        
    }

    
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    Team *team = [self.teamArray objectAtIndex:indexPath.row];
    
    ManageTeamViewController *teamInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ManageTeamViewController"];
    
    [teamInfoVC setValue:team forKey:@"teamInfo"];
    
    teamInfoVC.title=@"球队资料";
    
    teamInfoVC.isNearbyAndSearchBool=1;

    
    [self.navigationController pushViewController:teamInfoVC animated:YES];

    
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

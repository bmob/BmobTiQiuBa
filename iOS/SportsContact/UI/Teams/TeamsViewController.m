//
//  TeamsViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "TeamsViewController.h"
#import "ViewUtil.h"
#import <BmobSDK/Bmob.h>
#import "DataDef.h"
#import "LocationInfoManager.h"
#import "Util.h"

#import "TeamEngine.h"


#import "ManageTeamViewController.h"
#import "CreateTeamViewController.h"

#import "TeamSearchResultViewController.h"



typedef void (^searchtextFieldControllBlock)(BOOL aBool);

@interface TeamsViewController ()

@property (nonatomic, copy) searchtextFieldControllBlock searchControlBlock;

@property (nonatomic, assign) BOOL isNearbyAndSearchTable;


@property (nonatomic,strong) UserInfo *userInfo;
@property (nonatomic,strong) Team *teamInfo;

@property (strong, nonatomic) IBOutlet UITableView *nearbyteamTable;

@property (nonatomic, strong) NSMutableArray *teamArray;
@property (nonatomic, strong) NSMutableArray *joinTeamArray;




@end

@implementation TeamsViewController
@synthesize searchControlBlock;

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
    
    


//    self.view.backgroundColor=[ViewUtil hexStringToColor:@"eef0f2"];
    
    self.nearbyteamTable.backgroundColor=[ViewUtil hexStringToColor:@"eef0f2"];

    
//    //删除关联
//    //表名为Post,id为a1419df47a的BmobObject对象
//    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:@"ab5266d81f"];
//    //新建relation对象
//    BmobRelation *relation = [[BmobRelation alloc] init];
//    //relation要移除id为27bb999834的用户
//    [relation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"fc3a3b8e19"]];
//    //obj 更新关联关系到likes列中
//    [obj addRelation:relation forKey:@"footballer"];
//    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//        BDLog(@"error %@",[error description]);
//    }];


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.teamArray=[[NSMutableArray alloc]init];
    self.joinTeamArray=[[NSMutableArray alloc]init];
    
    [self getUserJoinedTeam];
    
    if (self.quitTeamBool)
    {
        [self hideBackButton];
    }
    else
    {
        [self showBackButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getUserJoinedTeam
{
    
    self.isNearbyAndSearchTable=NO;
    
    //获取当前用户的信息
    [self showLoadingView];
    
//    //插入所属球队数据
//    BmobObject *obj = [BmobUser getCurrentUser];
//    BmobRelation *relation = [[BmobRelation alloc] init];
//    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"b3757c998c"]];
//    [obj addRelation:relation forKey:@"team"];
//    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//        BDLog(@"error %@",[error description]);
//    }];
    
    
    
//    //删除所属球队数据
//    BmobObject *obj = [BmobUser getCurrentUser];
//    BmobRelation *relation = [[BmobRelation alloc] init];
//    [relation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"2072693011"]];
//    [obj addRelation:relation forKey:@"team"];
//    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//        BDLog(@"error %@",[error description]);
//    }];

    
    

//    //表名为Post,id为a1419df47a的BmobObject对象
//    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Team" objectId:@"2072693011"];
//    //新建relation对象
//    BmobRelation *relation = [[BmobRelation alloc] init] ;
//    //relation要移除id为27bb999834的用户
//    [relation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"fwXuDDDP"]];
//    //obj 更新关联关系到likes列中
//    [obj addRelation:relation forKey:@"footballer"];
//    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//        BDLog(@"error %@",[error description]);
//    }];

    [TeamEngine getTeamsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error){
                
        if (error)
        {
            [self hideLoadingView];
            
            [self showMessage:[Util errorStringWithCode:error.code]];

        }
        else
        {
            
            self.teamArray=result;
            
            
            if ([self.isSearchBoolStr isEqualToString:@"1"])
            {
                
                    self.joinTeamArray=self.teamArray;
                
                    self.teamArray=nil;
            }
            
            
            
            if ([self.teamArray count]==2)
            {
                
                
                [self.nearbyteamTable reloadData];
                
                [self hideLoadingView];
                
            }
            else if ([self.teamArray count]==1)
            {
                

//                self.title = nil;
                Team *team = [self.teamArray firstObject];
                
                ManageTeamViewController *teamInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ManageTeamViewController"];
                
                [teamInfoVC setValue:team forKey:@"teamInfo"];
                
                teamInfoVC.title=@"球队管理";
                
                teamInfoVC.isNearbyAndSearchBool=0;

                
                [self.navigationController pushViewController:teamInfoVC animated:YES];

                
                
                
            }
            else if ([self.teamArray count]==0)
            {
                

                //如果没有加入任何球队，就显示『附近的球队』
                [self getNearbyTeamArr];
                
            }
            else
            {
                
            }


            
        }
        
        
        
        
        
    }];
    
    


    
    
}


-(void)getNearbyTeamArr
{
    
    self.isNearbyAndSearchTable=YES;
    
    self.teamArray     = nil;
    self.teamArray     = [[NSMutableArray alloc] init];

    NSString *cityCode = [[BmobUser getCurrentUser] objectForKey:@"city"];

    [TeamEngine getNearbyTeamWithUserCity:cityCode block:^(id result, NSError *error){
        self.teamArray=result;
        BDLog(@"*************%lu",(unsigned long)[self.teamArray count]);
        [self.nearbyteamTable reloadData];
        
        [self hideLoadingView];
    }];
}


- (IBAction)getCreateTeamClick:(id)sender
{
    
    //一个人只能加入2支球队
    [self showLoadingView];
    
    [TeamEngine getJoinedTeamsWithUserId:[[BmobUser getCurrentUser] objectId] block:^(id result, NSError *error) {
        
        [self hideLoadingView];

        NSMutableArray *array=[[NSMutableArray alloc]initWithArray:result];
        
        if ([array count]==0)
        {
            CreateTeamViewController *teamInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeamViewController"];
            
            teamInfoVC.title=@"球队管理";
            
            teamInfoVC.isCreateteamBoolStr=@"1";
            
            [self.navigationController pushViewController:teamInfoVC animated:YES];
            
        }
        else if ([array count]==1)
        {
            
            Team *team=[array firstObject];
            
            if ([team.captain.objectId isEqualToString:[[BmobUser getCurrentUser] objectId]])
            {
                [self showMessage:@"一个人只能担任一个球队的队长！"];
            }
            else
            {
                CreateTeamViewController *teamInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeamViewController"];
                
                teamInfoVC.title=@"球队管理";
                
                teamInfoVC.isCreateteamBoolStr=@"1";
                
                [self.navigationController pushViewController:teamInfoVC animated:YES];

                
            }
            
            
            
        }
        else if ([array count]>=2)
        {
            [self showMessage:@"只能加入2支球队,可退出一支球队再加入"];
        }
        else
        {
            
        }

        
        
        
        
    }];
    
    
    

    
}









#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.isNearbyAndSearchTable)
    {
        if (indexPath.row==0)
        {
            return 230;
        }
        else
        {
            return 44;
        }

        
    }
    else
    {
        
        if (indexPath.row==0)
        {
            return 30;
        }
        else
        {
            return 44;
        }

    }
    
    

    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return [self.teamArray count]+1;

    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell;
    
    
    if (self.isNearbyAndSearchTable)
    {
        
        if (indexPath.row==0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CreateTeamCell"];
            
            
            UITextField *searchTextField=(id)[cell.contentView viewWithTag:100];
            
            UIButton *searchButton=(id)[cell.contentView viewWithTag:101];
            [searchButton addTarget:self action:@selector(onSearch:) forControlEvents:UIControlEventTouchUpInside];
            
            
            __block TeamsViewController *blockSelf = self;
            self.searchControlBlock=^(BOOL aBool)
            {
                
                [searchTextField resignFirstResponder];
                
                if ([searchTextField.text length]!=0 )
                {
                    //条件搜索请求，按球队代码、名字搜索
                    
//                    [blockSelf getSearchTeamMessage:searchTextField.text];
                    
                    TeamSearchResultViewController *searchResultVC = [blockSelf.storyboard instantiateViewControllerWithIdentifier:@"TeamSearchResultViewController"];
                    
                    [searchResultVC setValue:searchTextField.text forKey:@"searchKeyStr"];
                    
                    [searchResultVC setValue:blockSelf.joinTeamArray forKey:@"joinTeamArray"];

                    searchResultVC.title=@"球队搜索";
                    
                    [blockSelf.navigationController pushViewController:searchResultVC animated:YES];

                    
                    
                }else
                {
                    [blockSelf showMessage:@"请输入搜索内容！"];
                }
                
            };
            
            

        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTeamCell"];
            
            UILabel *itemLabel = (id)[cell.contentView viewWithTag:0xF1];
            
            Team *team = [self.teamArray objectAtIndex:indexPath.row-1];
            

            itemLabel.text=team.name;
            
            
            
            for (id obj in self.joinTeamArray)
            {

                Team *jointeam=obj;
                
                if ([jointeam.objectId isEqualToString:team.objectId])
                {
                    [itemLabel setTextColor:UIColorFromRGB(0xFFAE01)];
                    cell.userInteractionEnabled=NO;
                    
                    break;
                }
                else
                {
                    itemLabel.textColor=[UIColor grayColor];
                    cell.userInteractionEnabled=YES;
                }
                
            }
            
            
            
            
            
        }

        
        
    }
    else
    {
        
        if (indexPath.row==0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchSpaceCell"];

        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTeamCell"];
            
            UILabel *itemLabel = (id)[cell.contentView viewWithTag:0xF1];
            
            Team *team = [self.teamArray objectAtIndex:indexPath.row-1];
            
            itemLabel.text=team.name;
            
            
            
            
            
            

        }
        
        
        
    }

    

    
    return cell;
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0)
    {
        
    }
    else
    {
        
        Team *team = [self.teamArray objectAtIndex:indexPath.row-1];
        
        ManageTeamViewController *teamInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ManageTeamViewController"];
        
        [teamInfoVC setValue:team forKey:@"teamInfo"];
        
        if ([[[BmobUser getCurrentUser] objectId] isEqualToString:team.captain.objectId])
        {
            teamInfoVC.title=@"球队管理";
        }
        else
        {
            teamInfoVC.title=@"球队资料";
        }
        
        teamInfoVC.isNearbyAndSearchBool=1;
        
        
        [self.navigationController pushViewController:teamInfoVC animated:YES];
        

        
    }
    
    
        
    
    

    
}







#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onSearch:nil];
    
    return YES;
}

- (void)onSearch:(id)sender
{
    
    
    if (self.searchControlBlock)
    {
        self.searchControlBlock(YES);
    }

    
   
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    
    if ([segue.identifier isEqualToString:@"CreateTeam"])
	{
        
//        [segue.destinationViewController setValue:@"1" forKey:@"isCreateteamBoolStr"];
//
//        [segue.destinationViewController setValue:@"创建球队" forKey:@"title"];
	}

    else
    {
        
    }

    
}


@end

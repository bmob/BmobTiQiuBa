//
//  MatchViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "MatchViewController.h"
#import "DateUtil.h"
#import "LeagueEngine.h"
#import "MatchDetailViewController.h"
#import "MatchSearchResultViewController.h"
#import "NoticeManager.h"
#import "MatchEngine.h"
#import "InfoEngine.h"


typedef void (^searchMatchBlock)(BOOL aBool);

@interface MatchViewController ()


@property (nonatomic,strong) Tournament *teamTournament;

@property (nonatomic,strong) Tournament *team1Tourament;
@property (nonatomic,strong) Tournament *team2Tourament;

@property (nonatomic, strong) NSArray *noticeList;




@property (nonatomic, copy) searchMatchBlock searchMatchBlock;


@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic)  NSString *joiningLeagueName;

@property (strong, nonatomic)  NSMutableArray *touramentArr;


@property (strong, nonatomic)  NSMutableArray *totalTeamArr;




@end

@implementation MatchViewController

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
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadNoticeData];
    [self loadSelfLeague];
    
    [self loadNearbyLeague];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLeagueInviteWithNotice:(Notice *)aNotice
{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    if ([list count] != 2) {
        [self showMessage:@"消息数据异常"];
        return;
    }
    NSString *leagueId = [list objectAtIndex:0];
    NSString *teamId = [list objectAtIndex:1];
    
    [self showLoadingView];
    [MatchEngine registerTeamToLeagueId:leagueId teamId:teamId block:^(id result, NSError *error) {
        [self hideLoadingView];
        if (!error)
        {
            [self showMessage:@"加入联赛成功"];
            [[NoticeManager sharedManager] markNoticeDisposed:aNotice];
            aNotice.status = NoticeStatusDisposed;
            [self loadNoticeData];
            [self loadSelfLeague];
            [self loadNearbyLeague];
        }else
        {
            BDLog(@"add friend error %@",error);
            [self showMessage:[Util errorStringWithCode:error.code] ];
        }
    }];
}

- (void)loadNoticeData
{
//    [[NoticeManager sharedManager] readLeagueNoticeListFinished:^(NSArray *noticeList)
//     {
//         self.noticeList = [NSMutableArray arrayWithArray:noticeList];
//         [self.tableView reloadData];
//     }];
}

//-(void)loadSelfLeague
//{
//    
//    [self showLoadingView];
//    
//    //找出用户加入的所有球队
//    [InfoEngine getTeamsWithUserId:[BmobUser getCurrentUser].objectId
//                             block:^(id result, NSError *error) {
//                                 [self hideLoadingView];
//                                 NSMutableArray *teamsArr=[[NSMutableArray alloc]init];
//                                 teamsArr=result;
//                                 
//                                 self.totalTeamArr=result;
//                                 
//                                 if ([teamsArr count]==1)
//                                 {
//                                     Team *team=[teamsArr firstObject];
//                                     
//                                     //得出每支球队正在参加的最后一次的比赛
//                                     
//                                     [self showLoadingView];
//                                     
//                                     [LeagueEngine getHomeMatchWithTeamId:team.objectId block:^(id result, NSError *error) {
//                                         if (!error)
//                                         {
//                                             NSMutableArray *homeTourament1Arr=[[NSMutableArray alloc]init];
//                                             homeTourament1Arr=result;
//                                             Tournament *homeTourament1;
//                                             
//                                             if (result)
//                                             {
//                                                 homeTourament1=[homeTourament1Arr firstObject];
//                                             }
//                                             else
//                                             {
//                                                 homeTourament1=nil;
//                                             }
//                                             
//                                             
//                                             
//                                             [LeagueEngine getGuestMatchWithTeamId:team.objectId block:^(id result, NSError *error) {
//                                                 
//                                                 
//                                                 if (!error)
//                                                 {
//                                                     
//                                                     
//                                                     NSMutableArray *guestTourament1Arr=[[NSMutableArray alloc]init];
//                                                     guestTourament1Arr=result;
//                                                     Tournament *guestTourament1;
//                                                     
//                                                     if (result)
//                                                     {
//                                                         guestTourament1=[guestTourament1Arr firstObject];
//                                                     }
//                                                     else
//                                                     {
//                                                         guestTourament1=nil;
//                                                     }
//                                                     
//                                                     
//                                                     //比较主场，客场的时间，得出最后的一场比赛
//                                                     if (homeTourament1!=nil && guestTourament1!=nil)
//                                                     {
//                                                         if ([homeTourament1.start_time isLaterThanDate:guestTourament1.start_time])
//                                                         {
//                                                             self.teamTournament=homeTourament1;
//                                                         }
//                                                         else
//                                                         {
//                                                             self.teamTournament=guestTourament1;
//                                                             
//                                                         }
//                                                         
//                                                     }
//                                                     else if (homeTourament1!=nil && guestTourament1==nil)
//                                                     {
//                                                         self.teamTournament=homeTourament1;
//                                                     }
//                                                     else if (homeTourament1==nil && guestTourament1!=nil)
//                                                     {
//                                                         self.teamTournament=guestTourament1;
//                                                     }
//                                                     else
//                                                     {
//                                                         self.teamTournament=nil;
//                                                     }
//                                                     
//                                                     
//                                                     
//                                                     
//                                                     if (self.teamTournament)
//                                                     {
//                                                         //得出联赛名
//                                                         self.joiningLeagueName=self.teamTournament.league.name;
//                                                         
//                                                     }
//                                                     else
//                                                     {
//                                                         self.joiningLeagueName=@"暂无联赛信息！";
//                                                     }
//                                                     
//                                                     //                                [self.tableView reloadData];
//                                                     [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//                                                     
//                                                     [self hideLoadingView];
//                                                     
//                                                 }
//                                                 else
//                                                 {
//                                                     [self showMessage:[Util errorStringWithCode:error.code]];
//                                                     [self hideLoadingView];
//                                                 }
//                                                 
//                                                 
//                                                 
//                                             }];
//                                             
//                                             
//                                         }
//                                         else
//                                         {
//                                             [self showMessage:[Util errorStringWithCode:error.code]];
//                                             [self hideLoadingView];
//                                         }
//                                         
//                                     }];
//                                 }
//                                 else if ([teamsArr count]==2)
//                                 {
//                                     
//                                     
//                                     Team *team1=[teamsArr firstObject];
//                                     BDLog(@"**********%@",team1.objectId);
//                                     
//                                     [self showLoadingView];
//                                     [LeagueEngine getHomeMatchWithTeamId:team1.objectId block:^(id result, NSError *error) {
//                                         
//                                         
//                                         if (!error)
//                                         {
//                                             
//                                             NSMutableArray *homeTourament1Arr=[[NSMutableArray alloc]init];
//                                             homeTourament1Arr=result;
//                                             Tournament *homeTourament1;
//                                             
//                                             
//                                             if (result)
//                                             {
//                                                 //                       homeTourament1 =result;
//                                                 homeTourament1=[homeTourament1Arr firstObject];
//                                             }
//                                             else
//                                             {
//                                                 homeTourament1=nil;
//                                             }
//                                             
//                                             
//                                             
//                                             [LeagueEngine getGuestMatchWithTeamId:team1.objectId block:^(id result, NSError *error)
//                                              {
//                                                  
//                                                  
//                                                  if (!error)
//                                                  {
//                                                      
//                                                      //得出客场最后的一场比赛
//                                                      NSMutableArray *guestTourament1Arr=[[NSMutableArray alloc]init];
//                                                      guestTourament1Arr=result;
//                                                      Tournament *guestTourament1;
//                                                      
//                                                      
//                                                      if (result)
//                                                      {
//                                                          //                                guestTourament1=result;
//                                                          guestTourament1=[guestTourament1Arr firstObject];
//                                                      }
//                                                      else
//                                                      {
//                                                          guestTourament1=nil;
//                                                      }
//                                                      
//                                                      
//                                                      
//                                                      //比较主场，客场的时间，得出最后的一场比赛
//                                                      if (homeTourament1!=nil && guestTourament1!=nil)
//                                                      {
//                                                          
//                                                          if ([homeTourament1.start_time isLaterThanDate:guestTourament1.start_time])
//                                                          {
//                                                              self.team1Tourament=homeTourament1;
//                                                          }
//                                                          else
//                                                          {
//                                                              self.team1Tourament=guestTourament1;
//                                                              
//                                                          }
//                                                          
//                                                          
//                                                      }
//                                                      else if (homeTourament1!=nil && guestTourament1==nil)
//                                                      {
//                                                          self.team1Tourament=homeTourament1;
//                                                          
//                                                      }
//                                                      else if (homeTourament1==nil && guestTourament1!=nil)
//                                                      {
//                                                          self.team1Tourament=guestTourament1;
//                                                      }
//                                                      else
//                                                      {
//                                                          self.team1Tourament=nil;
//                                                          
//                                                      }
//                                                      //第二个球队的信息
//                                                      
//                                                      Team *team2=[teamsArr lastObject];
//                                                      //                            BDLog(@"**********%@",team2.objectId);
//                                                      
//                                                      [LeagueEngine getHomeMatchWithTeamId:team2.objectId block:^(id result, NSError *error) {
//                                                          
//                                                          
//                                                          
//                                                          if (!error)
//                                                          {
//                                                              
//                                                              //得出客场最后的一场比赛
//                                                              NSMutableArray *homeTourament2Arr=[[NSMutableArray alloc]init];
//                                                              homeTourament2Arr=result;
//                                                              Tournament *homeTourament2;
//                                                              
//                                                              
//                                                              
//                                                              if (result)
//                                                              {
//                                                                  //                                        homeTourament2=result;
//                                                                  homeTourament2=[homeTourament2Arr firstObject];
//                                                              }
//                                                              else
//                                                              {
//                                                                  homeTourament2=nil;
//                                                              }
//                                                              
//                                                              
//                                                              
//                                                              [LeagueEngine getGuestMatchWithTeamId:team2.objectId block:^(id result, NSError *error) {
//                                                                  
//                                                                  if (!error)
//                                                                  {
//                                                                      
//                                                                      NSMutableArray *guestTourament2Arr=[[NSMutableArray alloc]init];
//                                                                      guestTourament2Arr=result;
//                                                                      Tournament *guestTourament2;
//                                                                      
//                                                                      
//                                                                      if (result)
//                                                                      {
//                                                                          //                                                guestTourament2=result;
//                                                                          guestTourament2=[guestTourament2Arr firstObject];
//                                                                      }
//                                                                      else
//                                                                      {
//                                                                          guestTourament2=nil;
//                                                                      }
//                                                                      
//                                                                      
//                                                                      
//                                                                      
//                                                                      //比较主场，客场的时间，得出最后的一场比赛
//                                                                      
//                                                                      //比较主场，客场的时间，得出最后的一场比赛
//                                                                      if (homeTourament2!=nil && guestTourament2!=nil)
//                                                                      {
//                                                                          
//                                                                          if ([homeTourament2.start_time isLaterThanDate:guestTourament2.start_time])
//                                                                          {
//                                                                              self.team2Tourament=homeTourament2;
//                                                                          }
//                                                                          else
//                                                                          {
//                                                                              self.team2Tourament=guestTourament2;
//                                                                              
//                                                                          }
//                                                                      }
//                                                                      else if (homeTourament2!=nil && guestTourament2==nil)
//                                                                      {
//                                                                          self.team2Tourament=homeTourament2;
//                                                                          
//                                                                      }
//                                                                      else if (homeTourament2==nil && guestTourament2!=nil)
//                                                                      {
//                                                                          self.team2Tourament=guestTourament2;
//                                                                      }
//                                                                      else
//                                                                      {
//                                                                          self.team2Tourament=nil;
//                                                                          
//                                                                      }
//                                                                      
//                                                                      //                                            BDLog(@"**********%@**********%@",self.team1Tourament,self.team2Tourament);
//                                                                      
//                                                                      //得出最终的tourament
//                                                                      if (self.team1Tourament!=nil && self.team2Tourament!=nil)
//                                                                      {
//                                                                          
//                                                                          if ([self.team1Tourament.start_time isLaterThanDate:guestTourament2.start_time])
//                                                                          {
//                                                                              self.teamTournament=self.team1Tourament;
//                                                                          }
//                                                                          else
//                                                                          {
//                                                                              self.teamTournament=self.team2Tourament;
//                                                                              
//                                                                          }
//                                                                          
//                                                                      }
//                                                                      else if (self.team1Tourament!=nil && self.team2Tourament==nil)
//                                                                      {
//                                                                          self.teamTournament=self.team1Tourament;
//                                                                      }
//                                                                      else if (self.team1Tourament==nil && self.team2Tourament!=nil)
//                                                                      {
//                                                                          self.teamTournament=self.team2Tourament;
//                                                                      }
//                                                                      else
//                                                                      {
//                                                                          self.teamTournament=nil;
//                                                                      }
//                                                                      
//                                                                      
//                                                                      
//                                                                      if (self.teamTournament)
//                                                                      {
//                                                                          //得出联赛名
//                                                                          self.joiningLeagueName=self.teamTournament.league.name;
//                                                                          
//                                                                      }
//                                                                      else
//                                                                      {
//                                                                          self.joiningLeagueName=@"暂无联赛信息！";
//                                                                      }
//                                                                      
//                                                                      
//                                                                      //                                            [self.tableView reloadData];
//                                                                      [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//                                                                      
//                                                                      [self hideLoadingView];
//                                                                      
//                                                                      
//                                                                      
//                                                                  }
//                                                                  else
//                                                                  {
//                                                                      [self showMessage:[Util errorStringWithCode:error.code]];
//                                                                      [self hideLoadingView];
//                                                                      
//                                                                  }
//                                                                  
//                                                                  
//                                                              }];
//                                                              
//                                                              
//                                                          }
//                                                          else
//                                                          {
//                                                              [self showMessage:[Util errorStringWithCode:error.code]];
//                                                              [self hideLoadingView];
//                                                              
//                                                          }
//                                                          
//                                                          
//                                                      }];
//                                                  }
//                                                  else
//                                                  {
//                                                      [self showMessage:[Util errorStringWithCode:error.code]];
//                                                      [self hideLoadingView];
//                                                      
//                                                  }
//                                              }];
//                                         }
//                                         else
//                                         {
//                                             [self showMessage:[Util errorStringWithCode:error.code]];
//                                             [self hideLoadingView];
//                                             
//                                         }
//                                     }];
//                                 }
//                                 else
//                                 {
//                                     self.joiningLeagueName=@"暂无联赛信息！";
//                                 }
//                             }];
////    [LeagueEngine getTeamsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error) {
////        
////        
////    }];
//    
//    
//}



-(void)loadSelfLeague
{
    
    [self showLoadingView];
    
    //找出用户加入的所有球队
    [InfoEngine getTeamsWithUserId:[BmobUser getCurrentUser].objectId block:^(id result, NSError *error) {
        [self hideLoadingView];
        NSMutableArray *teamsArr=[[NSMutableArray alloc]init];
        teamsArr=result;
        
        self.totalTeamArr=result;
        
        if ([teamsArr count]==1)
        {
            Team *team=[teamsArr firstObject];
            
            //得出每支球队正在参加的最后一次的比赛
            
            [self showLoadingView];
            [LeagueEngine getLastLeagueMatchWithTeamId:team.objectId
                                                 block:^(id result, NSError *error) {
                                                     if (!error)
                                                     {
                                                         NSMutableArray *homeTourament1Arr=[[NSMutableArray alloc]init];
                                                         homeTourament1Arr=result;
                                                         if (homeTourament1Arr && homeTourament1Arr.count > 0) {
                                                             self.teamTournament = [homeTourament1Arr firstObject];
                                                         }
                                                         
                                                         if (self.teamTournament)
                                                         {
                                                             //得出联赛名
                                                             self.joiningLeagueName=self.teamTournament.league.name;
                                                             
                                                         }
                                                         else
                                                         {
                                                             self.joiningLeagueName=@"暂无联赛信息！";
                                                         }
                                                         
                                                         //                                [self.tableView reloadData];
                                                         [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                         
                                                         [self hideLoadingView];
                                                     }else{
                                                         [self showMessage:[Util errorStringWithCode:error.code]];
                                                         [self hideLoadingView];
                                                     }
                                                 }];
            
        }else if ([teamsArr count]==2){
            Team *team1=[teamsArr firstObject];
            BDLog(@"**********%@",team1.objectId);
            
            [self showLoadingView];
            [LeagueEngine getLastLeagueMatchWithTeamId:team1.objectId block:^(id result, NSError *error) {
                if (!error) {
                    NSMutableArray *homeTourament1Arr=[[NSMutableArray alloc]init];
                    homeTourament1Arr=result;
                    if (result)
                    {
                        self.team1Tourament=[homeTourament1Arr firstObject];
                    }
                    else
                    {
                        self.team1Tourament=nil;
                    }
                    //第二个球队的信息
                    
                    Team *team2=[teamsArr lastObject];
                    [LeagueEngine getLastLeagueMatchWithTeamId:team2.objectId block:^(id result, NSError *error) {
                        if (!error)
                        {
                            
                            //得出客场最后的一场比赛
                            NSMutableArray *homeTourament2Arr=[[NSMutableArray alloc]init];
                            homeTourament2Arr=result;
                            Tournament *homeTourament2;
                            if (result)
                            {
//                                        homeTourament2=result;
                                homeTourament2=[homeTourament2Arr firstObject];
                            }
                            else
                            {
                                homeTourament2=nil;
                            }
                            self.team2Tourament = homeTourament2;
                            //得出最终的tourament
                            if (self.team1Tourament!=nil && self.team2Tourament!=nil)
                            {
                                
                                if ([self.team1Tourament.start_time isLaterThanDate:self.team2Tourament.start_time])
                                {
                                    self.teamTournament=self.team1Tourament;
                                }
                                else
                                {
                                    self.teamTournament=self.team2Tourament;
                                    
                                }
                                
                            }
                            else if (self.team1Tourament!=nil && self.team2Tourament==nil)
                            {
                                self.teamTournament=self.team1Tourament;
                            }
                            else if (self.team1Tourament==nil && self.team2Tourament!=nil)
                            {
                                self.teamTournament=self.team2Tourament;
                            }
                            else
                            {
                                self.teamTournament=nil;
                            }
                            if (self.teamTournament)
                            {
                                //得出联赛名
                                self.joiningLeagueName=self.teamTournament.league.name;
                                
                            }
                            else
                            {
                                self.joiningLeagueName=@"暂无联赛信息！";
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //                                            [self.tableView reloadData];
                                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                                
                                [self hideLoadingView];
                            });
                        }
                        else
                        {
                            [self showMessage:[Util errorStringWithCode:error.code]];
                            [self hideLoadingView];
                            
                        }
                        
                    }];
                }else
                {
                    [self showMessage:[Util errorStringWithCode:error.code]];
                    [self hideLoadingView];
                    
                }
            }];
        }
        else
        {
            self.joiningLeagueName=@"暂无联赛信息！";
        }
    }];
}






-(void)loadNearbyLeague
{
    
    [self showLoadingView];
    NSString *cityCode = [[BmobUser getCurrentUser] objectForKey:@"city"];
    [LeagueEngine getNearbyLeagueWithCitycode:cityCode block:^(id result, NSError *error) {
        
        
        self.touramentArr=result;
        
        BDLog(@"*********%ld",(long)[self.touramentArr count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            [self hideLoadingView];
        });
        
        
    }];
    
}





//- (IBAction)getMyTouramentBtnClick:(id)sender
//{
//
//
//    if (self.teamTournament.league.objectId!=nil)
//    {
//
//
//        MatchDetailViewController *leagueVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MatchDetailViewController"];
//
////        leagueVC.title=self.teamTournament.league.name;
//        leagueVC.leagueName=self.teamTournament.league.name;
//
//
//        leagueVC.leagueId=self.teamTournament.league.objectId;//传联赛id
//
//        [self.navigationController pushViewController:leagueVC animated:YES];
//
//
//    }
//
//
//
//
//
//}







#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onSearchTourament:nil];
    
    return YES;
}

- (void)onSearchTourament:(id)sender
{
    
    
    if (self.searchMatchBlock)
    {
        self.searchMatchBlock(YES);
    }
    
    
    
    
}








#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        return 120;
    }else if (indexPath.row <= self.noticeList.count)
    {
        return 67;
    }else if (indexPath.row == 1 + self.noticeList.count) {
        return 110;
    }else{
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.touramentArr count]+2 + [self.noticeList count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TournamentCell"];
        UILabel *touramentLabel = (id)[cell.contentView viewWithTag:0xF0];
        touramentLabel.text=self.joiningLeagueName;
        
    }else if (indexPath.row <= self.noticeList.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"notice_cell"];
         Notice *recent = [self.noticeList objectAtIndex:indexPath.row - 1];
        UILabel *titleLabel = (id)[cell.contentView viewWithTag:0xF3];
        titleLabel.text = recent.title;
        UILabel *contentLabel = (id)[cell.contentView viewWithTag:0xF4];
        contentLabel.text = recent.aps.alert;
        UIButton *control = (id)[cell.contentView viewWithTag:0xF5];
        [self embeddedClickEvent:control setBindingRunnable:^{
            [self handleLeagueInviteWithNotice:recent];
        }];
    }else if (indexPath.row== 1 + self.noticeList.count) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
        UITextField *searchTextField=(id)[cell.contentView viewWithTag:100];
        UIButton *searchButton=(id)[cell.contentView viewWithTag:101];
        [searchButton addTarget:self action:@selector(onSearchTourament:) forControlEvents:UIControlEventTouchUpInside];
        
        __block MatchViewController *blockSelf = self;
        self.searchMatchBlock=^(BOOL aBool)
        {
            
            [searchTextField resignFirstResponder];
            
            if ([searchTextField.text length]!=0 )
            {
                //条件搜索请求，按球队代码、名字搜索
                
                //                [blockSelf getSearchTouramentMessage:searchTextField.text];
                
                
                MatchSearchResultViewController *searchResultVC = [blockSelf.storyboard instantiateViewControllerWithIdentifier:@"MatchSearchResultViewController"];
                
                [searchResultVC setValue:searchTextField.text forKey:@"searchKeyStr"];
                
                searchResultVC.title=@"联赛搜索";
                
                [blockSelf.navigationController pushViewController:searchResultVC animated:YES];
                
                
                
                
            }else
            {
                [blockSelf showMessage:@"请输入搜索内容！"];
            }
            
        };

    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NearbyTournamentCell"];
        
        UILabel *itemLabel = (id)[cell.contentView viewWithTag:0xF1];
        
        Tournament *tourament = [self.touramentArr objectAtIndex:indexPath.row-2];
        
        itemLabel.text=tourament.name;
        
        
    }

    
    return cell;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    
    if (indexPath.row<=[self.noticeList count]+1)
    {
        
    }
    else
    {
        
        NSUInteger row=indexPath.row-2-[self.noticeList count];
        
        Tournament *tourament = [self.touramentArr objectAtIndex:row];
        
        MatchDetailViewController *leagueVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MatchDetailViewController"];
        
        leagueVC.leagueName=tourament.name;
        
        //    BDLog(@"*****%@",leagueVC.leagueName);
        
        leagueVC.leagueId=tourament.objectId;//传联赛id
        
        [self.navigationController pushViewController:leagueVC animated:YES];

        
    }
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([segue.identifier isEqualToString:@"push_matchJoined"])
     {
         [segue.destinationViewController setValue:self.totalTeamArr forKey:@"totalTeamArr"];
     }
  
 }

@end



















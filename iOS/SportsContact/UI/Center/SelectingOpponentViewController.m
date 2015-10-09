//
//  SelectingOpponentViewController.m
//  SportsContact
//
//  Created by bobo on 14-8-4.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "SelectingOpponentViewController.h"
#import "MatchEngine.h"
#import "Util.h"
#import "NSObject+MGBlockPerformer.h"
#import "NoticeManager.h"

@interface SelectingOpponentViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) NSArray *teams;

@end

@implementation SelectingOpponentViewController

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
    self.title = @"选择对手";
    
    [self showLoadingView];
   
    [MatchEngine getTeamsWithBlock:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (error)
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             self.teams = result;
             [self.tableView reloadData];
         }
     }];
    
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:@"提交" forState:UIControlStateNormal];
    [rButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    // Do any additional setup after loading the view.
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

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.teams count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"team_cell" forIndexPath:indexPath];
    UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF0];
    nameLabel.text = [[self.teams objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.match.opponent = [self.teams objectAtIndex:indexPath.row];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onSearch:nil];
    return YES;
}

#pragma mark - Event handler
- (void)onSave:(id)sender
{
    if (self.match.opponent)
    {
        if ([self.match.home_court.objectId isEqualToString:self.match.opponent.objectId])
        {
            [self showMessage:@"主队和对手不能相同！"];
            return ;
        }
        
        for (Team *team in self.homeCourtTeams) {
            if ([team.objectId isEqualToString:self.match.opponent.objectId]) {
                [self showMessage:@"您同属于这两只球队无法创建比赛！"];
                return ;
            }
        }
    }else
    {
        [self showMessage:@"对手不能为空！"];
        return;
    }
    self.match.name = [NSString stringWithFormat:@"%@-%@", self.match.home_court.name ? self.match.home_court.name : @"", self.match.opponent.name ? self.match.opponent.name : @""];
    self.match.nature = [NSNumber numberWithInteger:TournamentTypeFriendly];
    
    [self addMatchPushWithMatch:self.match];
    /*
    [MatchEngine addMatchWithMatch:self.match block:^(id result, NSError *error) {
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            [self showMessage:@"添加比赛成功"];
            [self performRunnable:^{
                
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMatchAdded object:nil];
                
                
                //通知球队主页面，主动刷新数据
                [[NSNotificationCenter defaultCenter] postNotificationName:kObserverTeamInfoChanged object:nil];

                
            } afterDelay:1.5f];
        }
    }];
     */
}


- (void)addMatchPushWithMatch:(Tournament *)match
{
    NSMutableDictionary *matchObject = [NSMutableDictionary dictionaryWithCapacity:0];
    [matchObject setObject:match.name forKey:@"name"];
    [matchObject setObject:@((long)[match.event_date timeIntervalSince1970]) forKey:@"event_date"];
    [matchObject setObject:@((long)[match.start_time timeIntervalSince1970]) forKey:@"start_time"];
    [matchObject setObject:@((long)[match.end_time timeIntervalSince1970]) forKey:@"end_time"];
    [matchObject setObject:@(3) forKey:@"nature"];
    [matchObject setObject:@(NO) forKey:@"state"];
    [matchObject setObject:match.site forKey:@"site"];
    [matchObject setObject:match.city forKey:@"city"];
    [matchObject setObject:match.nature forKey:@"nature"];
    [matchObject setObject:match.home_court.objectId forKey:@"home_court"];
    [matchObject setObject:match.opponent.objectId forKey:@"opponent"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [formatter setDateFormat:@"MM月dd日"];
    NSString *timeString = [formatter stringFromDate:match.event_date];
    
    
    
    Notice *msg = [[Notice alloc] init];
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    NSString *content;
    NSString *toUsername;
    if ([match.home_court.captain.objectId isEqualToString:[BmobUser getCurrentUser].objectId])
    {
        if(!match.opponent.captain.username)
        {
            [self showMessage:@"球队未设置队长"];
            return;
        }
//        content = [NSString stringWithFormat:@"%@球队邀请您的球队参加比赛", match.home_court.name];
//        msg.title = match.opponent.name;

        content = [NSString stringWithFormat:@"%@邀请你们%@于%@比赛", match.home_court.name,timeString,match.site];
        
        msg.title = match.opponent.name;
        toUsername = match.opponent.captain.username;
        msg.subtype = NoticeSubtypeMatchCaptainInvitation;
        
    }else
    {
        if(!match.home_court.captain.username)
        {
            [self showMessage:@"您的球队未设置队长"];
            return;
        }
        NSString *selfName = selfUser.nickname ? selfUser.nickname : selfUser.username;
        content = [NSString stringWithFormat:@"队员%@申请%@与%@球队在%@比赛",selfName ,timeString, match.opponent.name,match.site];
        msg.title = match.home_court.name;
        toUsername = match.home_court.captain.username;
        msg.subtype = NoticeSubtypeMatchMemberInvitation;
    }
    
    msg.targetId = [NSString stringWithFormat:@"%@&%@", match.home_court.objectId, match.opponent.objectId];
    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.extra = matchObject;
    //    msg.content = content;
    msg.type = NoticeTypeTeam;
    [[NoticeManager sharedManager] pushNotice:msg toUsername:toUsername block:^(id result, NSError *error) {
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            [self showMessage:@"发送成功"];
            [self performRunnable:^{
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } afterDelay:1.0f];
        }
    }];
}


- (IBAction)onSearch:(id)sender
{
    [self.searchTextField resignFirstResponder];
    if (self.searchTextField.text && ![self.searchTextField.text isEqualToString:@""]) {
        [self showLoadingView];
        [MatchEngine searchTeamsWithName:self.searchTextField.text block:^(id result, NSError *error)
         {
             [self hideLoadingView];
             if (error)
             {
                 [self showMessage:[Util errorStringWithCode:error.code]];
             }else
             {
                 self.teams = result;
                 [self.tableView reloadData];
             }
         }];
    }else{
        [self showLoadingView];
        [MatchEngine getTeamsWithBlock:^(id result, NSError *error)
         {
             [self hideLoadingView];
             if (error)
             {
                 [self showMessage:[Util errorStringWithCode:error.code]];
             }else
             {
                 self.teams = result;
                 [self.tableView reloadData];
             }
         }];
    }
}

@end

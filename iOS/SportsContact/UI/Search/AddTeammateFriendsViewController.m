//
//  AddTeammateFriendsViewController.m
//  SportsContact
//
//  Created by bobo on 14/11/22.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "AddTeammateFriendsViewController.h"
#import "Util.h"
#import "InfoEngine.h"
#import "TeamEngine.h"
#import <UIImageView+WebCache.h>
#import "NoticeManager.h"

@interface AddTeammateFriendsViewController ()

@property (nonatomic, strong) NSArray *teammates;
@property (nonatomic, strong) NSMutableArray *selectedRows;

@end

@implementation AddTeammateFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedRows = [NSMutableArray arrayWithCapacity:0];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadAllFriendsList];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - Data loader
-(void)loadAllFriendsList
{
    //获取全部好友
    [self showLoadingView];
    [InfoEngine getFriendsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (error)
         {
             
             [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             self.friends = result;
             if ([self.friends count]!=0 )
             {
                 //区别队友，好友
                 [self loadTeammatesList];
             }
             else
             {
                 UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-25.0, 320.0, 50.0f)];
                 warningLabel.text = @"暂无好友！";
                 warningLabel.textColor = [UIColor blackColor];
                 warningLabel.textAlignment = NSTextAlignmentCenter;
                 warningLabel.font = [UIFont boldSystemFontOfSize:20.0f];
                 [self.view addSubview:warningLabel];
             }
         }
     }];
}

-(void)loadTeammatesList
{
    [self showLoadingView];
    //获取全部队友
    [TeamEngine getTeamMenberCountWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (!error)
         {
             self.teammates = result;
             [self.tableView reloadData];
         }
         else
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }
     }];
    
    
}

#pragma mark - Private methods

- (void)enableRightButton
{
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:@"确定" forState:UIControlStateNormal];
    [rButton addTarget:self action:@selector(onSure:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
}

- (void)disenableRightButton
{
    self.navigationItem.rightBarButtonItem = nil;
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

#pragma Event handler
-(void)onSure:(id)sender
{
    //邀请球员入队，发送通知，同意再添加成功
    if ([self.selectedRows count] > 0)
    {
        for (NSNumber *row in self.selectedRows)
        {
            UserInfo *user = [self.friends objectAtIndex:[row integerValue]];
            Notice *msg = [[Notice alloc] init];
            NSString *toUsername = nil;
            UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
            NSString *content = nil;
            content = [NSString stringWithFormat:@"邀请您加入%@",self.teamInfo.name];
            
//            [NSString stringWithFormat:@"%@队长邀请您加入球队", self.teamInfo.name];
            msg.subtype = NoticeSubtypeCaptainInvitation;
            msg.targetId = self.teamInfo.objectId;
            toUsername = user.username;
            msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
            msg.time = [[NSDate date] timeIntervalSince1970];
            msg.belongId = selfUser.username;
            msg.title = self.teamInfo.name;
            msg.type = NoticeTypeTeam;
            [[NoticeManager sharedManager] pushNotice:msg toUsername:toUsername];
            
        }
        [self showMessage:@"入队邀请发送成功！"];
        [self performRunnable:^{
            [self.navigationController popViewControllerAnimated:YES];
        } afterDelay:1.5f];
    }
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendsCell"];
    
    UserInfo *user = [self.friends objectAtIndex:[indexPath row]];
    
    UIImageView *avatarImageView = (id)[cell.contentView viewWithTag:0xF0];
    
    [avatarImageView.layer setCornerRadius:avatarImageView.bounds.size.width/2.0f];
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avator.url] completed:nil];
    
    UILabel *nicknameLabel = (id)[cell.contentView viewWithTag:0xF1];
    if ([user.nickname length]!=0)
    {
        nicknameLabel.text = user.nickname;
    }
    else
    {
        nicknameLabel.text=user.username;
    }
    
    
    //显示好友or队友
    UILabel *relatedTypeLabel = (id)[cell.contentView viewWithTag:0xF2];
    for (UserInfo *teammate in self.teammates)
    {
        if ([user.objectId isEqualToString:teammate.objectId])
        {
            relatedTypeLabel.text=@"队友";
            cell.userInteractionEnabled=NO;
            break;
        }
        else
        {
            relatedTypeLabel.text=@"好友";
            cell.userInteractionEnabled=YES;
            
        }
    }
    UIImageView *choseView = (id)[cell.contentView viewWithTag:0xF3];
    if ([self.selectedRows indexOfObject:@(indexPath.row)] == NSNotFound) {
        [choseView setImage:[UIImage imageNamed:@"addTM_chose.png"]];
    }else
    {
        [choseView setImage:[UIImage imageNamed:@"addTM_chose_.png"]];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.selectedRows indexOfObject:@(indexPath.row)] == NSNotFound)
    {
        [self.selectedRows addObject:@(indexPath.row)];
    }else
    {
       [self.selectedRows removeObject:@(indexPath.row)];
    }
    if ([self.selectedRows count] > 0) {
        [self enableRightButton];
    }else
    {
        [self disenableRightButton];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}



@end

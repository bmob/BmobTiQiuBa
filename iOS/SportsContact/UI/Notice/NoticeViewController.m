//
//  NoticeViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "NoticeViewController.h"
#import "DataDef.h"
#import "NSObject+MGBlockPerformer.h"
#import "DateUtil.h"
#import "NoticeManager.h"
#import "InfoEngine.h"
#import "TeamEngine.h"
#import "Util.h"
#import "MatchEngine.h"
#import "TeamEngine.h"
#import "FormationViewController.h"
#import "CommentViewController.h"
#import "ScoreManagerViewController.h"
#import "AuthFailViewController.h"
#import "LeaguescheduleViewController.h"
#import "ScoreboardViewController.h"
#import "LeagueEngine.h"
#import "UserInfoViewController.h"


@interface NoticeViewController ()

@property (nonatomic, strong) NSMutableArray *noticeList;

@end

@implementation NoticeViewController

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
    self.title = @"消息";
    [self onCancel:nil];
    
    // Do any additional setup after loading the view.
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [self loadDataWithLoadView:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kObserverNoticeRecieve object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessage:) name:kObserverNoticeRecieve object:nil];
    
    [[NoticeManager sharedManager] readNoticeListFromDiskFinished:^(NSArray *noticeList) {
        self.noticeList = [NSMutableArray arrayWithArray:noticeList];
        [self.tableView reloadData];
    }];
//    [self loadDataWithLoadView:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNewMessage:(id)sender
{
    [self performRunnable:^
     {
         [self loadDataWithLoadView:YES];
     }afterDelay:1.5];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self loadDataWithLoadView:NO];
}

- (void)loadDataWithLoadView:(BOOL)loadView
{
    if (loadView) {
        [self showLoadingView];
    }
    [[NoticeManager sharedManager] readNoticeListFromWebFinished:^(NSArray *noticeList) {
        [[NoticeManager sharedManager] readNoticeListFromDiskFinished:^(NSArray *noticeList) {
            if (loadView) {
                [self hideLoadingView];
            }
            if (self.refreshControl.refreshing) {
                [self.refreshControl endRefreshing];
            }
            
            self.noticeList = [NSMutableArray arrayWithArray:noticeList];
            [self.tableView reloadData];
        }];
    }];
//    [[NoticeManager sharedManager] readNoticeListFinished:^(NSArray *noticeList)
//     {
//         if (loadView) {
//             [self hideLoadingView];
//         }
//         if (self.refreshControl.refreshing) {
//             [self.refreshControl endRefreshing];
//         }
//         self.noticeList = [NSMutableArray arrayWithArray:noticeList];
//         [self.tableView reloadData];
//     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"report"]) {
        Notice *nti = (Notice *)sender;
        NSArray *list = [nti.targetId componentsSeparatedByString:@"&"];
        
        if ([list count] >= 1) {
             [segue.destinationViewController setValue:[list objectAtIndex:0] forKey:@"tournamentId"];
        }
        if ([list count] >= 2) {
            [segue.destinationViewController setValue:[list objectAtIndex:1] forKey:@"teamId"];
        }
    }
//    else if ([segue.identifier isEqualToString:@"authfail"]) {
//        Notice *nti = (Notice *)sender;
//        NSArray *list = [nti.targetId componentsSeparatedByString:@"&"];
//        if ([list count] >= 1) {
//            [segue.destinationViewController setValue:[list objectAtIndex:0] forKey:@"tournamentId"];
//        }
//        if ([list count] >= 2) {
//            [segue.destinationViewController setValue:[list objectAtIndex:1] forKey:@"teamId"];
//        }
//    }
}

//- (void)load

#pragma mark - Event handler
- (void)onDel:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    UIButton *leftBtn = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)onCancel:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    UIButton *rightBtn = [self rightButtonWithImage:[UIImage imageNamed:@"btn_notice_delete"] hightlightedImage:[UIImage imageNamed:@"btn_notice_delete_h"]];
    [rightBtn addTarget:self action:@selector(onDel:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.leftBarButtonItem = nil;
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
//icon_notice_other.png
//icon_notice_team.png
//icon_notice_user.png
#pragma mark - UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return indexPath.row % 2 == 0 ? 10.0f : 101.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0)
    {
        return [tableView dequeueReusableCellWithIdentifier:@"space_cell" forIndexPath:indexPath];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notice_cell" forIndexPath:indexPath];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notice_cell"];
//    }
    Notice *recent = [self.noticeList objectAtIndex:indexPath.row / 2];
    UIImageView *imageView = (id)[cell.contentView viewWithTag:0xF0];
    UILabel *typeLabel = (id)[cell.contentView viewWithTag:0xF1];
    UIButton *control = (id)[cell.contentView viewWithTag:0xF5];
    imageView.image = [UIImage imageNamed:@"icon_notice_user.png"];
    control.enabled = YES;
    
    control.hidden = NO;
    
    switch (recent.type)
    {
        case NoticeTypePersonal:
            imageView.image = [UIImage imageNamed:@"icon_notice_user.png"];
            typeLabel.text = @"个人消息";
            [control setTitle:@"添加" forState:UIControlStateNormal];
            break;
        case NoticeTypeTeam:
            imageView.image = [UIImage imageNamed:@"icon_notice_team.png"];
            typeLabel.text = @"球队消息";
           
            break;
        case NoticeTypeRanking:
            imageView.image = [UIImage imageNamed:@"icon_notice_other.png"];
            typeLabel.text = @"其他消息";
            [control setTitle:@"确认" forState:UIControlStateNormal];
            break;
        case NoticeTypeLeague:{
            imageView.image = [UIImage imageNamed:@"icon_notice_other.png"];
            typeLabel.text = @"联赛消息";
//            [control setTitle:@"确认" forState:UIControlStateNormal];
        }
            break;
        default:
            imageView.image = [UIImage imageNamed:@"icon_notice_user.png"];
            typeLabel.text = @"个人消息";
            break;
    }
    
    NSInteger subType = recent.subtype;//[[recent.extra objectForKey:@"subtype"] intValue];
    //title
    UILabel *titleLabel = (id)[cell.contentView viewWithTag:0xF3];
    titleLabel.text = recent.title;
    NSLog(@"subType %d",(int)subType);
    //将recent.subType 替换为 subType
    switch (subType) {
        case NoticeSubtypeAddFriend:
        {
            control.hidden = NO;
//            [control setTitle:@"添加" forState:UIControlStateNormal];
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleAddFriendWithNotice:recent];
                
            }];
        }
            break;
        case NoticeSubtypeAddFriendFeed:
            control.hidden = YES;
            break;
        case NoticeSubtypeApplyTeam:
        {
            NSArray *nameArray = [recent.title componentsSeparatedByString:@"&"];
            titleLabel.text = [nameArray firstObject];
            control.hidden = NO;
            [control setTitle:@"同意" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleApplyTeamWithNotice:recent];
               
            }];
        }
            break;
        case NoticeSubtypeApplyTeamFeed:
            control.hidden = YES;
            break;
        case NoticeSubtypeCaptainInvitation:
        {
            control.hidden = NO;
            [control setTitle:@"同意" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleCaptainInvitationWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeCaptainInvitationFeed:
            control.hidden = YES;
            break;
        case NoticeSubtypeMemberInvitation:
        {
            NSArray *nameArray = [recent.title componentsSeparatedByString:@"&"];
            titleLabel.text = [nameArray firstObject];
            control.hidden = NO;
            [control setTitle:@"确认" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleMemberInvitationWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeTeamKickout:
            control.hidden= YES;
            break;
        case NoticeSubtypeQuitTeam:
            control.hidden = YES;
            break;
        case NoticeSubtypeMarking:
        {
            control.hidden = NO;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleMarkingWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeMatchReport:
        {
            control.hidden = NO;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleMatchReportFeedWithNotice:recent];
            }];
        }
            break;
            case NoticeSubtypeLeagueInvite:
        {
            control.hidden = YES;
//            [control setTitle:@"同意" forState:UIControlStateNormal];
//            [self embeddedClickEvent:control setBindingRunnable:^{
//                [self handleLeagueInviteWithNotice:recent];
//            }];
        }
            break;
        case NoticeSubtypeTeamLineupPub:
        {
            control.hidden = NO;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleTeamLineupPubWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeMatchMemberInvitation:
        {
            control.hidden = NO;
            [control setTitle:@"同意" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleMatchMemberInvitationWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeMatchCaptainInvitation:
        {
            control.hidden = NO;
            [control setTitle:@"同意" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleMatchCaptainInvitationWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeMatchCreated:
        {
            control.hidden = NO;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleMatchCreatedWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeMatchReportOtherFeed:{
            control.hidden = NO;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [self handleMatchReportFeedWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeMatchNotices:{
            control.hidden = NO;
            //赛事提醒
            __weak typeof(self)weakSelf = self;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [weakSelf handleMatchCreatedWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeScheduleCreated:{
            control.hidden = NO;
            //发布赛程
            __weak typeof(self)weakSelf = self;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [weakSelf handleLeagueWithScheduleDataUpdatedNotice:recent];
            }];
        }
            break;
            
        case NoticeSubtypeScheduleDataUpdated:{
            control.hidden = NO;
            //更新数据
            __weak typeof(self)weakSelf = self;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [weakSelf handleLeagueScoreboard:recent];
            }];

        }
            break;
        case NoticeSubtypeMatchResultCreated:{
            control.hidden = NO;
            //输入数据提示
            __weak typeof(self)weakSelf = self;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [weakSelf handleMatchCreatedWithNotice:recent];
            }];
        }
            break;
        case NoticeSubtypeMatchReportFail:{
            control.hidden = NO;
            __weak typeof(self)weakSelf = self;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [weakSelf handleMatchReportFail:recent];
            }];
        }
            break;
        case NoticeSubtypeMatchReportSuccess:{
            control.hidden = NO;
            __weak typeof(self)weakSelf = self;
            [control setTitle:@"查看" forState:UIControlStateNormal];
            [self embeddedClickEvent:control setBindingRunnable:^{
                [weakSelf handleMatchReportSuccess:recent];
            }];
        }
            break;
        default:
            control.hidden = YES;
            break;
    }
    if (recent.status == NoticeStatusDisposed) {
        control.enabled = NO;
        [control setTitle:@"已处理" forState:UIControlStateNormal];
    }
    
    UILabel *dateLabel = (id)[cell.contentView viewWithTag:0xF2];
    dateLabel.text = [DateUtil formatedDate:[NSDate dateWithTimeIntervalSince1970:recent.time] byDateFormat:@"yyyy.MM.dd"];
    
    UILabel *contentLabel = (id)[cell.contentView viewWithTag:0xF4];
    contentLabel.text = recent.aps.alert;
    CGRect labelFrame = contentLabel.frame;
    if (control.hidden) {
        labelFrame.size.width = 300;
    }else
    {
        labelFrame.size.width = 233;
    }
    contentLabel.frame = labelFrame;
   
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.noticeList count] * 2;
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        Notice *recent = [self.noticeList objectAtIndex:indexPath.row / 2];
        [[NoticeManager sharedManager] deleteNotice:recent];
        [self.noticeList removeObjectAtIndex:indexPath.row/2];
        NSIndexPath *spaceIndex = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:spaceIndex,indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row % 2 != 0;
}

#pragma mark - 消息处理逻辑

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
            NSInteger index = [self.noticeList indexOfObject:aNotice];
            aNotice.status = NoticeStatusDisposed;
            
            
            //通知球队主页面，主动刷新数据
            [[NSNotificationCenter defaultCenter] postNotificationName:kObserverTeamInfoChanged object:nil];

            
            if (index != NSNotFound)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index * 2 + 1 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }else
        {
            BDLog(@"add friend error %@",error);
            [self showMessage:[Util errorStringWithCode:error.code] ];
        }
    }];
}

//- (void)handleAddFriendWithNotice:(Notice *)aNotice
//{
//    BmobUser *user = [BmobUser getCurrentUser];
//    BmobRelation *relation = [BmobRelation relation];
//    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:aNotice.targetId]];
//    [user addRelation:relation forKey:@"friends"];
//    [self showLoadingView];
//    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//        [self hideLoadingView];
//        if (isSuccessful)
//        {
//            
//            [self showMessage:@"添加好友成功"];
//            [[NoticeManager sharedManager] markNoticeDisposed:aNotice];
//            NSInteger index = [self.noticeList indexOfObject:aNotice];
//            aNotice.status = NoticeStatusDisposed;
//            if (index != NSNotFound)
//            {
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index * 2 + 1 inSection:0];
//                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            }
//            [self performRunnable:^
//             {
//                 [self addFriendFeedPushWithNotice:aNotice];
//             } afterDelay:1.5f];
//        }else
//        {
//            BDLog(@"add friend error %@",error);
//            [self showMessage:[Util errorStringWithCode:error.code] ];
//        }
//    }];
//   
//}

- (void)handleAddFriendWithNotice:(Notice *)aNotice{
    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Info" bundle:[NSBundle mainBundle]];
    UserInfoViewController *userViewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    [InfoEngine getInfoWithUserId:aNotice.targetId block:^(UserInfo *user, NSError *error) {
//        UserInfo *user = [[UserInfo alloc] initWithDictionary:user1];//[self.teammateArr objectAtIndex:[indexPath row]];
        userViewController.userInfo = user;
//        userViewController.isTeammate = YES;
        //判断是否好友，再控制显示『添加好友』
        [InfoEngine getFriendsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error)
         {
             if (!error)
             {
                 userViewController.isFriend = NO;
                 for (UserInfo *currUser in result)
                 {
                     if([user.username isEqualToString:currUser.username])
                     {
                         userViewController.isFriend = YES;
                         break;
                     }
                 }
//                 if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
//                 {
//                     userViewController.viewType = UserInfoViewTypeTeam;
//                     userViewController.ownTeams = @[self.teamInfo];
//                 }else
//                 {
                     userViewController.viewType = UserInfoViewTypeInfo;
//                 }
                 [self.navigationController pushViewController:userViewController animated:YES];
             }else
             {
                 [self showMessage:[Util errorStringWithCode:error.code]];
             }
         }];
    }];
    
    
}

- (void)handleApplyTeamWithNotice:(Notice *)aNotice
{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    if ([list count] != 2) {
        [self showMessage:@"消息数据异常"];
        return;
    }
    NSString *teamId = [list objectAtIndex:0];
    NSString *userId = [list objectAtIndex:1];
    
//    NSArray *nameArray = [aNotice.title componentsSeparatedByString:@"&"];
//    NSString *teamName = [nameArray lastObject];
    
    [self showLoadingView];
    
    
    //同意请入队，先判断自己加入的球队总数，不能超过2个球队。
    [TeamEngine getTeamsWithUser:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId] block:^(id result, NSError *error){
        if (error)
        {
            [self hideLoadingView];
            [self showMessage:[Util errorStringWithCode:error.code]];
        }
        else
        {

            if ([(NSArray*)result count]<2)
            {
                //可以加入球队
                
                [InfoEngine addUserId:userId toTeamId:teamId block:^(id result, NSError *error)
                 {
                     [self hideLoadingView];
                     if (!error)
                     {
                         [self showMessage:@"加入球队成功"];
                         [[NoticeManager sharedManager] markNoticeDisposed:aNotice];
                         NSInteger index = [self.noticeList indexOfObject:aNotice];
                         aNotice.status = NoticeStatusDisposed;
                         if (index != NSNotFound)
                         {
                             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index * 2 + 1 inSection:0];
                             [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                         }
                         
                         [self performRunnable:^
                          {
                              [self joinTeamFeedPushWithTeamId:teamId userId:userId fromCaptain:NO];
                          } afterDelay:1.5f];
                     }else
                     {
                         BDLog(@"add friend error %@",error);
                         [self showMessage:[Util errorStringWithCode:error.code] ];
                     }
                 }];

                
                
                
                
            }
            else if ([(NSArray*)result count]>=2)
            {
                //提示不能加入球队
                [self hideLoadingView];
                [self showMessage:@"加入球队数不能超过2个！"];
                
            }
            
            
            
        }
        
    }];

}


- (void)handleCaptainInvitationWithNotice:(Notice *)aNotice
{
    [self showLoadingView];
    [TeamEngine getTeamsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error){
        if (error)
        {
            [self hideLoadingView];
            
            [self showMessage:[Util errorStringWithCode:error.code]];
            
        }
        else
        {
            
            
            if ([(NSArray*)result count]<2)
            {
                NSString *currentUserID = [BmobUser getCurrentUser].objectId;
                
                [InfoEngine addUserId:currentUserID toTeamId:aNotice.targetId block:^(id result, NSError *error)
                 {
                     [self hideLoadingView];
                     if (!error)
                     {
                         [self showMessage:@"加入球队成功"];
                         [[NoticeManager sharedManager] markNoticeDisposed:aNotice];
                         NSInteger index = [self.noticeList indexOfObject:aNotice];
                         aNotice.status = NoticeStatusDisposed;
                         if (index != NSNotFound)
                         {
                             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index * 2 + 1 inSection:0];
                             [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                         }
                         
                         [self performRunnable:^
                          {
                              [self joinTeamFeedPushWithTeamId:aNotice.targetId userId:currentUserID fromCaptain:YES];
                          } afterDelay:1.5f];
                     }else
                     {
                         BDLog(@"add friend error %@",error);
                         [self showMessage:[Util errorStringWithCode:error.code] ];
                     }
                 }];
                
                
            }
            else if ([(NSArray*)result count]>=2)
            {
                //提示不能加入球队
                [self hideLoadingView];
                [self showMessage:@"加入球队数不能超过2个！"];
                
            }
            else
            {
            }

        }
    }];
    
    
    
 }

- (void)handleMemberInvitationWithNotice:(Notice *)aNotice
{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    if ([list count] != 2) {
        [self showMessage:@"消息数据异常"];
        return;
    }
    NSString *teamId = [list objectAtIndex:0];
    NSString *targetId = [list objectAtIndex:1];
    [TeamEngine getInfoWithTeamId:teamId block:^(id result, NSError *error)
     {
         if (!error)
         {
             Team *team = result;
             Notice *msg = [[Notice alloc] init];
             UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
             NSString *content = nil;
             content = [NSString stringWithFormat:@"邀请您加入%@",team.name];
             //[NSString stringWithFormat:@"%@队长邀请您加入球队", team.name];
             msg.subtype = NoticeSubtypeCaptainInvitation;
             msg.targetId = [list objectAtIndex:0];
             
             msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
             msg.time = [[NSDate date] timeIntervalSince1970];
             msg.belongId = selfUser.username;
             msg.title = team.name;
//             msg.content = content;
             msg.type = NoticeTypeTeam;
             [[NoticeManager sharedManager] pushNotice:msg toUsername:targetId];
             aNotice.status = NoticeStatusDisposed;
             [[NoticeManager sharedManager] markNoticeDisposed:aNotice];
             [self.tableView reloadData];
         }else
         {
            BDLog(@"get team members error : %@", error);
         }
     }];
   
}

- (void)handleMatchReportWithNotice:(Notice *)aNotice
{
//    [self performSegueWithIdentifier:@"report" sender:aNotice];
    
//    Notice *nti = (Notice *)sender;
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
//    if ([list count] >= 1) {
//         [segue.destinationViewController setValue:[list objectAtIndex:0] forKey:@"tournamentId"];
//    }
//    if ([list count] >= 2) {
//        [segue.destinationViewController setValue:[list objectAtIndex:1] forKey:@"teamId"];
//    }
    
    [BmobCloud callFunctionInBackground:@"authTournament" withParameters:@{@"objectId":[list firstObject]} block:^(id object, NSError *error) {
        if (error)
        {
            [self showMessage:@"查询失败，请重试！"];
        }else
        {
            BOOL isVerify = ![[NSString stringWithFormat:@"%@", object] isEqualToString:@"0"];
            if (isVerify) {
                [self performSegueWithIdentifier:@"report" sender:aNotice];
            }else{
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notice" bundle:[NSBundle mainBundle]];
                AuthFailViewController *afvc =(AuthFailViewController*) [storyboard instantiateViewControllerWithIdentifier:@"AuthFailVC"];
                afvc.title = @"认证失败";
                if (list.count >= 1) {
                    afvc.tournamentID = [list firstObject];
                }
                if (list.count >= 2) {
                    
                    afvc.teamID = [list lastObject];
                }
                [self.navigationController pushViewController:afvc animated:YES];
            }
        }
    }];
    
    
}

-(void)handleMatchReportFeedWithNotice:(Notice*)aNotice{
    [self performSegueWithIdentifier:@"report" sender:aNotice];
}


- (void)handleTeamLineupPubWithNotice:(Notice *)aNotice
{
    [self showLoadingView];
    [TeamEngine getInfoWithTeamId:aNotice.targetId block:^(id teamInfo, NSError *error)
     {
         if (teamInfo && !error)
         {
             [TeamEngine getLineupWithTeamId:aNotice.targetId block:^(id lineup, NSError *error)
              {
                  [self hideLoadingView];
                  if (!error)
                  {
                      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Teams" bundle:[NSBundle mainBundle]];
                      FormationViewController *lineupViewController = [storyboard instantiateViewControllerWithIdentifier:@"FormationViewController"];
                      lineupViewController.lineup = lineup;
                      lineupViewController.teamInfo = teamInfo;
                      [self.navigationController pushViewController:lineupViewController animated:YES];
                  }
                  else
                  {
                      [self showMessage:[Util errorStringWithCode:error.code]];
                  }
              }];
         }else
         {
             [self hideLoadingView];
             [self showMessage:@"加载球队数据出错！"];
         }
     }];
}

- (void)handleMatchMemberInvitationWithNotice:(Notice *)aNotice
{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    if ([list count] != 2) {
        [self showMessage:@"消息数据异常"];
        return;
    }
    NSString *homeCourtId = [list objectAtIndex:0];
    NSString *opponentId = [list objectAtIndex:1];
    [self showLoadingView];
    [TeamEngine getInfoWithTeamId:homeCourtId block:^(Team *home_court, NSError *error) {
        if (home_court && !error)
        {
            [TeamEngine getInfoWithTeamId:opponentId block:^(Team *opponent, NSError *error) {
                [self hideLoadingView];
                if (opponent && !error)
                {
                    if(!opponent.captain.username)
                    {
                        [self showMessage:@"对方球队未设置队长"];
                        return;
                    }
                    Notice *msg = [[Notice alloc] init];
                    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
                    NSString *content;
                    NSString *toUsername;
                    content = [NSString stringWithFormat:@"%@球队邀请您的球队参加比赛", home_court.name];
                    msg.title = opponent.name;
                    toUsername = opponent.captain.username;
                    msg.subtype = NoticeSubtypeMatchCaptainInvitation;
                    msg.targetId = [NSString stringWithFormat:@"%@&%@", home_court.objectId, opponent.objectId];
                    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
                    msg.time = [[NSDate date] timeIntervalSince1970];
                    msg.belongId = selfUser.username;
                    msg.extra = aNotice.extra;
                    //    msg.content = content;
                    msg.type = NoticeTypeTeam;
                    [self showLoadingView];
                    [[NoticeManager sharedManager] pushNotice:msg toUsername:toUsername block:^(id result, NSError *error)
                    {
                        [self hideLoadingView];
                        if (error) {
                            [self showMessage:@"发送失败"];
                        }else
                        {
                            [self showMessage:@"发送成功"];
                            [[NoticeManager sharedManager] markNoticeDisposed:aNotice];
                            NSInteger index = [self.noticeList indexOfObject:aNotice];
                            aNotice.status = NoticeStatusDisposed;
                            if (index != NSNotFound)
                            {
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index * 2 + 1 inSection:0];
                                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                            }
                            [self matchMemberInvitationFeedPushWithNotice:aNotice teamName:home_court.name];
                        }
                    }];
                    
                    
                }else
                {
                    [self showMessage:@"加载数据出错"];
                }
            }];
        }else
        {
            [self hideLoadingView];
            [self showMessage:@"加载数据出错"];
        }
    }];
}

- (void)handleMatchCaptainInvitationWithNotice:(Notice *)aNotice
{
    NSDictionary *matchObject = aNotice.extra;
    BmobObject *tournament = [[BmobObject alloc] initWithClassName:kTableTournament];
    [tournament setObject:[matchObject objectForKey:@"name"] forKey:@"name"];
    [tournament setObject:[[NSDate alloc] initWithTimeIntervalSince1970:[[matchObject objectForKey:@"event_date"] doubleValue]] forKey:@"event_date"];
    [tournament setObject:[[NSDate alloc] initWithTimeIntervalSince1970:[[matchObject objectForKey:@"start_time"] doubleValue]] forKey:@"start_time"];
    [tournament setObject:[[NSDate alloc] initWithTimeIntervalSince1970:[[matchObject objectForKey:@"end_time"] doubleValue]] forKey:@"end_time"];
    [tournament setObject:[matchObject objectForKey:@"nature"] forKey:@"nature"];
    [tournament setObject:[matchObject objectForKey:@"state"] forKey:@"state"];
    [tournament setObject:[matchObject objectForKey:@"site"] forKey:@"site"];
    [tournament setObject:[matchObject objectForKey:@"city"] forKey:@"city"];
    [tournament setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:[matchObject objectForKey:@"home_court"]] forKey:@"home_court"];
    [tournament setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:[matchObject objectForKey:@"opponent"]]  forKey:@"opponent"];
    [self showLoadingView];
    [tournament saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        [self hideLoadingView];
        if (!error)
        {
            [[NoticeManager sharedManager] markNoticeDisposed:aNotice];
            [self showMessage:@"比赛成功发起"];
            NSInteger index = [self.noticeList indexOfObject:aNotice];
            aNotice.status = NoticeStatusDisposed;
            if (index != NSNotFound)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index * 2 + 1 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMatchAdded object:nil];
            //通知球队主页面，主动刷新数据
            [[NSNotificationCenter defaultCenter] postNotificationName:kObserverTeamInfoChanged object:nil];
            [self matchCaptainInvitationFeedPushWithNotice:aNotice];
            [self addMatchPushWithMatchId:tournament.objectId homeCourtId:[matchObject objectForKey:@"home_court"] opponentId:[matchObject objectForKey:@"opponent"]];
        }else
        {
            BDLog(@"error %@",error);
            [self showMessage:[Util errorStringWithCode:error.code]];
        }
    }];
}

- (void)handleMarkingWithNotice:(Notice *)aNotice
{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    if ([list count] != 2) {
        [self showMessage:@"消息数据异常"];
        return;
    }
    NSString *userId = list[0];
    NSString *matchId = list[1];
    [self showLoadingView];
    [InfoEngine getInfoWithUserId:userId block:^(id userInfo, NSError *error) {
        if (error) {
            [self hideLoadingView];
            [self showMessage:@"用户信息加载错误"];
        }else
        {
            [MatchEngine getMatchWithMatchId:matchId block:^(id match, NSError *error) {
                [self hideLoadingView];
                if (error) {
                    [self showMessage:@"比赛信息加载错误"];
                }else
                {
                    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
                    CommentViewController *viewControler = [centerStoryboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
                    viewControler.userInfo = userInfo;
                    viewControler.match = match;
                    viewControler.needInputCell = NO;
                    [self.navigationController pushViewController:viewControler animated:YES];
                }
            }];
        }
        
    }];
}

- (void)handleMatchCreatedWithNotice:(Notice *)aNotice
{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    if ([list count] != 2) {
        [self showMessage:@"消息数据异常"];
        return;
    }
    NSString *matchId = list[0];
    NSString *teamId = list[1];
    [self showLoadingView];
    [MatchEngine getMatchWithMatchId:matchId block:^(Tournament *tournament, NSError *error) {
        
        if (error) {
            [self hideLoadingView];
            [self showMessage:@"用户信息加载错误"];
        }else
        {
            [TeamEngine getInfoWithTeamId:teamId block:^(Team *team, NSError *error) {
                [self hideLoadingView];
                if (error) {
                    [self showMessage:@"比赛信息加载错误"];
                }else
                {
                    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Center" bundle:[NSBundle mainBundle]];
                    ScoreManagerViewController *scoreViewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"ScoreManagerViewController"];
                    scoreViewController.match = tournament;
                    scoreViewController.team = team;
                    if ([[NSDate dateFromServer] timeIntervalSince1970] > [tournament.start_time timeIntervalSince1970]) {
                         scoreViewController.canEdit = YES;
                    }
                    scoreViewController.userInfo = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
                    [self.navigationController pushViewController:scoreViewController animated:YES];
                }
            }];
        }
    }];
}

//发布赛程
-(void)handleLeagueWithScheduleDataUpdatedNotice:(Notice*)aNotice{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Match" bundle:[NSBundle mainBundle]];
    LeaguescheduleViewController *leaguescheduleVC = [storyboard instantiateViewControllerWithIdentifier:@"LeaguescheduleViewController"];
    leaguescheduleVC.leagueId = aNotice.targetId;
    [self.navigationController pushViewController:leaguescheduleVC animated:YES];
}

//更新积分
-(void)handleLeagueScoreboard:(Notice *)aNotice{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Match" bundle:[NSBundle mainBundle]];
    ScoreboardViewController *scoreboardVC = [storyboard instantiateViewControllerWithIdentifier:@"ScoreboardViewController"];
    scoreboardVC.leagueId=aNotice.targetId;
//    [self addChildViewController:scoreboardVC];
//    scoreboardVC.view.frame = self.scoreboardView.bounds;
    scoreboardVC.leagueName=aNotice.title;
    scoreboardVC.title = aNotice.title;
    [self.navigationController pushViewController:scoreboardVC animated:YES];
}

//联赛邀请
-(void)handleLeagueInvitation:(Notice *)aNotice{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    if ([list count] != 2) {
        [self showMessage:@"消息数据异常"];
        return;
    }
    NSString *leagueId = list[0];
    NSString *teamId = list[1];
    [self showLoadingView];
    
    __weak typeof(self)weakSelf = self;
    [LeagueEngine joinLeagueWithTeamId:teamId
                              leagueId:leagueId
                                 block:^(BOOL isSuccessful, NSError *error) {
                                     __strong typeof(self)strongSelf = weakSelf;
                                      [strongSelf hideLoadingView];
                                     if (error) {
                                         [strongSelf showMessage:@"加入联赛失败"];
                                     }else{
                                         [strongSelf showMessage:@"加入联赛成功"];
                                     }
                                 }];
}


-(void)handleMatchReportFail:(Notice *)aNotice{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Notice" bundle:[NSBundle mainBundle]];
    AuthFailViewController *afvc =(AuthFailViewController*) [storyboard instantiateViewControllerWithIdentifier:@"AuthFailVC"];
    afvc.title = @"认证失败";
    if (list.count >= 1) {
        afvc.tournamentID = [list firstObject];
    }
    if (list.count >= 2) {
        
        afvc.teamID = [list lastObject];
    }
    [self.navigationController pushViewController:afvc animated:YES];
}


-(void)handleMatchReportSuccess:(Notice *)aNotice{
//    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    [self performSegueWithIdentifier:@"report" sender:aNotice];
}

#pragma mark - 推送反馈信息

- (void)matchMemberInvitationFeedPushWithNotice:(Notice *)aNotice teamName:(NSString *)teamName
{
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    Notice *msg = [[Notice alloc] init];
    msg.aps = [ApsInfo apsInfoWithAlert:@"队长已经处理您的比赛请求" badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.title = teamName;
    //    msg.content = content;
    msg.type = NoticeTypeTeam;
    msg.subtype = NoticeSubtypeMatchInvitationFeed;
    [[NoticeManager sharedManager] pushNotice:msg toUsername:aNotice.belongId];
}

- (void)matchCaptainInvitationFeedPushWithNotice:(Notice *)aNotice

{
    NSArray *list = [aNotice.targetId componentsSeparatedByString:@"&"];
    if ([list count] != 2) {
//        [self showMessage:@"消息数据异常"];
        UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
        Notice *msg = [[Notice alloc] init];
        msg.aps = [ApsInfo apsInfoWithAlert:@"对方已经接受您的比赛邀请" badge:0 sound:nil];
        msg.time = [[NSDate date] timeIntervalSince1970];
        msg.belongId = selfUser.username;
        msg.title = selfUser.nickname ? selfUser.nickname : selfUser.username;
        //    msg.content = content;
        msg.type = NoticeTypeTeam;
        msg.subtype = NoticeSubtypeMatchInvitationFeed;
        [[NoticeManager sharedManager] pushNotice:msg toUsername:aNotice.belongId];
        return;
    }
    NSString *homeCourtId = [list objectAtIndex:0];
    NSString *opponentId = [list objectAtIndex:1];
//    [self showLoadingView];
    [TeamEngine getInfoWithTeamId:homeCourtId block:^(Team *home_court, NSError *error) {
        if (home_court && !error)
        {
            [TeamEngine getInfoWithTeamId:opponentId block:^(Team *opponent, NSError *error) {
                if (home_court && opponent) {
                    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
                    Notice *msg = [[Notice alloc] init];
                    NSString *content = [NSString stringWithFormat:@"%@球队已经接受您的比赛邀请", opponent.name];
                    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
                    msg.time = [[NSDate date] timeIntervalSince1970];
                    msg.belongId = selfUser.username;
                    msg.title = home_court.name;
                    //    msg.content = content;
                    msg.type = NoticeTypeTeam;
                    msg.subtype = NoticeSubtypeMatchInvitationFeed;
                    [[NoticeManager sharedManager] pushNotice:msg toUsername:aNotice.belongId];
                }
            }];
        }
    }];
    
}

- (void)joinTeamFeedPushWithTeamId:(NSString *)teamId userId:(NSString *)userId fromCaptain:(BOOL)fromCaptain
{
    [TeamEngine getInfoWithTeamId:teamId block:^(id result, NSError *error)
    {
        if (!error)
        {
            Team *team = result;
            [TeamEngine getTeamMembersWithTeamId:teamId block:^(id result, NSError *error)
            {
                if (!error)
                {
                    NSArray *members = result;
                    
                    BmobUser *currentUser = [BmobUser getCurrentUser];
                    if ([currentUser.objectId isEqualToString:userId]) {
                        UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
                       
                        Notice *msg = [[Notice alloc] init];
                       
                        msg.time = [[NSDate date] timeIntervalSince1970];
                        msg.belongId = selfUser.username;
                        msg.title = [team name];
  //                    msg.content = content;
                        msg.type = NoticeTypeTeam;
                        msg.subtype = NoticeSubtypeCaptainInvitationFeed;
                        for (UserInfo *user in members)
                        {
                            NSString *content = @"";
                            NSString *name = selfUser.nickname ? selfUser.nickname : selfUser.username;
                            if (!fromCaptain) {
                                if ([user.objectId isEqualToString:userId]) {
                                    content =[NSString stringWithFormat:@"恭喜您成功加入%@", team.name];
                                }else{
                                    content =[NSString stringWithFormat:@"新成员%@加入%@",name,team.name];
                                }
                            }else{
                                if ([user.objectId isEqualToString:team.captain.objectId]) {
                                    content =[NSString stringWithFormat:@"成功加入您所属的%@", team.name];
                                    msg.title = name;
                                }else{
                                     content =[NSString stringWithFormat:@"新成员%@加入%@",name,team.name];
                                }
                            }
                            
                            msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
                            [[NoticeManager sharedManager] pushNotice:[msg copy] toUsername:user.username];
                        }
                    }else{
                        [self pushToUserWithObjectId:userId array:members team:team fromCaptain:fromCaptain];
                    }
                    
                    
                    
                }else
                {
                   BDLog(@"get team members error : %@", error);
                }
            }];
        }else
        {
            BDLog(@"get team info error : %@", error);
        }
        
    }];
 
}


-(void)pushToUserWithObjectId:(NSString *)userId array:(NSArray *)members team:(Team*)team fromCaptain:(BOOL)fromCaptain{
    
    BmobQuery *query = [BmobQuery queryForUser];
    [query getObjectInBackgroundWithId:userId
                                 block:^(BmobObject *object, NSError *error) {
                                     UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:object];
//                                     NSString *content =[NSString stringWithFormat:@"%@成功加入您所属的球队", selfUser.nickname ? selfUser.nickname : selfUser.username];
                                     Notice *msg = [[Notice alloc] init];
//                                     msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
                                     msg.time = [[NSDate date] timeIntervalSince1970];
                                     msg.belongId = selfUser.username;
                                     msg.title = [team name];
                                     //                    msg.content = content;
                                     msg.type = NoticeTypeTeam;
                                     msg.subtype = NoticeSubtypeCaptainInvitationFeed;
                                     for (UserInfo *user in members)
                                     {
                                         NSString *content = @"";
                                         NSString *name = selfUser.nickname ? selfUser.nickname : selfUser.username;
                                         if (!fromCaptain) {
                                             if ([user.objectId isEqualToString:userId]) {
                                                 content =[NSString stringWithFormat:@"恭喜您成功加入%@", team.name];
                                             }else{
                                                 content =[NSString stringWithFormat:@"新成员%@加入%@",name,team.name];
                                             }
                                         }else{
                                             if ([user.objectId isEqualToString:team.captain.objectId]) {
                                                 content =[NSString stringWithFormat:@"成功加入您所属的%@", team.name];
                                                 msg.title = name;
                                             }else{
                                                 content =[NSString stringWithFormat:@"新成员%@加入%@",name,team.name];
                                             }
                                         }
                                         msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
                                         [[NoticeManager sharedManager] pushNotice:[msg copy] toUsername:user.username];
                                     }
                                 }];

}

- (void)addFriendFeedPushWithNotice:(Notice *)aNotice
{
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    NSString *content =[NSString stringWithFormat:@"%@已添加您为好友", selfUser.nickname ? selfUser.nickname : selfUser.username];
    Notice *msg = [[Notice alloc] init];
    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.title = selfUser.nickname ? selfUser.nickname : selfUser.username;
//    msg.content = content;
    msg.type = NoticeTypePersonal;
    msg.subtype = NoticeSubtypeAddFriendFeed;
    [[NoticeManager sharedManager] pushNotice:msg toUsername:aNotice.belongId];
}

#pragma mark - Private methods
- (void)addMatchPushWithMatchId:(NSString *)matchId homeCourtId:(NSString *)homeCourtId opponentId:(NSString *)opponentId
{
    [self showLoadingView];
    [TeamEngine getInfoWithTeamId:homeCourtId block:^(Team *team, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
            Notice *msg = [[Notice alloc] init];
            msg.aps = [ApsInfo apsInfoWithAlert:@"安排了一场新比赛" badge:0 sound:nil];
            msg.time = [[NSDate date] timeIntervalSince1970];
            msg.belongId = selfUser.username;
            msg.title = team.name;
            //    msg.content = content;
            msg.type = NoticeTypeTeam;
            msg.subtype = NoticeSubtypeMatchCreated;
            msg.targetId = [NSString stringWithFormat:@"%@&%@", matchId, team.objectId];
            [[NoticeManager sharedManager] pushNotice:msg toTeam:team.objectId];
        }else
        {
            [self showMessage:@"球队数据加载出错"];
        }
    }];
    
    [self showLoadingView];
    [TeamEngine getInfoWithTeamId:opponentId block:^(Team *team, NSError *error) {
        [self hideLoadingView];
        if (!error) {
            UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
            Notice *msg = [[Notice alloc] init];
            msg.aps = [ApsInfo apsInfoWithAlert:@"安排了一场新比赛" badge:0 sound:nil];
            msg.time = [[NSDate date] timeIntervalSince1970];
            msg.belongId = selfUser.username;
            msg.title = team.name;
            //    msg.content = content;
            msg.type = NoticeTypeTeam;
            msg.subtype = NoticeSubtypeMatchCreated;
            msg.targetId = [NSString stringWithFormat:@"%@&%@", matchId, team.objectId];
            [[NoticeManager sharedManager] pushNotice:msg toTeam:team.objectId];
        }else
        {
            [self showMessage:@"球队数据加载出错"];
        }
    }];
    
}

@end

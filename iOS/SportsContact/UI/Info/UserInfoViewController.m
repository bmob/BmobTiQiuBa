//
//  UserInfoViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "UserInfoViewController.h"
#import "InfoEngine.h"
#import "MatchEngine.h"
#import <UIImageView+WebCache.h>
#import "ViewUtil.h"
#import "LocationInfoManager.h"
#import "DateUtil.h"
#import "MainNavigationController.h"
#import "NoticeManager.h"
#import "ValueSelectionViewController.h"
#import "UIImage+Util.h"
#import <BmobSDK/Bmob.h>
#import "TeamEngine.h"
#import "BPush.h"
#import "BPushUtil.h"


#define kUserInfoCellBase @"base_cell"
#define kUserInfoCellData @"data_cell"
#define kUserInfoCellControll1 @"controll1_cell"
#define kUserInfoCellControll2 @"controll2_cell"
#define kUserInfoCellExploits @"exploits_cell"
#define kUserInfoCellSchedule @"schedule_cell"
#define kUserInfoCellLoading @"loading_cell"


#import "CHTumblrMenuView.h"
#import <ShareSDK/ShareSDK.h>


#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"

#define TITLE @"测试_Title"
#define CONTENT @"测试_Content"
#define URL @"http://www.baidu.com"

#import "AppDelegate.h"


@interface UserInfoViewController () <ValueSelectionDelegate>

//@property (nonatomic,strong) UserInfo *userInfo;

@property (weak, nonatomic) IBOutlet UIView *settingToolView;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (nonatomic) BOOL isSetting;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) BOOL isExploitsLoaded;
@property (nonatomic, assign) BOOL isScheduleLoaded;
@property (nonatomic, strong) NSArray *exploits;
@property (nonatomic, strong) NSArray *schedule;
@property (nonatomic, strong) NSArray *teams;
@property (nonatomic, weak) NSTimer *timer;


@property (strong, nonatomic)  NSString *shareTitle;
@property (strong, nonatomic)  NSString *shareContent;
@property (strong, nonatomic)  NSString *shareUrl;
@property (assign) BOOL  bmobInitSuccessful;

@property (strong, nonatomic) UIView *tipview;

@end

@implementation UserInfoViewController
@synthesize tipview = _tipview;

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

    self.bmobInitSuccessful = NO;
    
    self.title = @"个人中心";
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    self.isSetting = NO;
    self.isExploitsLoaded = NO;
    self.isScheduleLoaded = NO;
    if ([self.userInfo.objectId isEqualToString:[BmobUser getCurrentUser].objectId])
    {
        self.viewType = UserInfoViewTypeOwn;
    }
    
    if (self.viewType != UserInfoViewTypeOwn)
    {
        self.dataSource = @[kUserInfoCellBase, kUserInfoCellData, kUserInfoCellControll2, kUserInfoCellExploits, kUserInfoCellSchedule];
    }else
    {
        UIButton *rightBtn = [self rightButtonWithImage:[UIImage imageNamed:@"btn_setting"] hightlightedImage:[UIImage imageNamed:@"btn_setting_hl"]];
        [rightBtn addTarget:self action:@selector(onSetting:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        self.dataSource = @[kUserInfoCellBase, kUserInfoCellData, kUserInfoCellControll1, kUserInfoCellExploits, kUserInfoCellSchedule];
        self.userInfo = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    }
    [self.tableView reloadData];
    
    self.settingToolView.hidden = YES;
    UIView *toolView = [self.settingToolView viewWithTag:0xF0];
    [ViewUtil addSingleTapGestureForView:toolView target:self action:@selector(onSetting:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefresh) name:kObserverUserInfoChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefresh) name:kObserverMatchInfoChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefresh) name:kObserverMatchAdded object:nil];
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
//    if (appDelegate.bmobInitState) {
//        [self loadUserInfo];
//    }else{
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:kBmobInitSuccessNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserInfo) name:kBmobInitSuccessNotification object:nil];
//    }
    
    
//    [self showLoadingView];
    
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
   
    // Do any additional setup after loading the view.
    _tipview = [[UIView alloc] init];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self loadUserInfoWithHandler:^{
        [refreshControl   endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if (self.isNeedRefresh)
//    {
    
//
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    if (appDelegate.bmobInitState) {
    
        self.isNeedRefresh = NO;
        [self showLoadingView];
        [self loadUserInfoWithHandler:^{
            [self hideLoadingView];
        }];
        
//    }
    

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(updateTeamName) userInfo:nil repeats:YES];
    self.timer = timer;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self hideSettingToolView];
    self.isSetting = NO;
}

-(void)loadUserInfo{
    
//    self.bmobInitSuccessful = YES;
//    __weak typeof(self) weakSelf = self;
//    [weakSelf loadUserInfoWithHandler:^{
        [self hideLoadingView];
//    }];
}

- (void)showSettingToolView
{
    self.settingToolView.hidden = NO;
    
    UIView *bgView = [self.settingToolView viewWithTag:0xF0];
    UIView *toolView = [self.settingToolView viewWithTag:0xF1];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = toolView.frame;
        frame.origin.y = 0;
        toolView.frame  = frame;
        bgView.alpha = 0.3;
    } completion:nil];
}

- (void)hideSettingToolView
{
    UIView *bgView = [self.settingToolView viewWithTag:0xF0];
    UIView *toolView = [self.settingToolView viewWithTag:0xF1];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = toolView.frame;
        frame.origin.y = - frame.size.height;
        toolView.frame  = frame;
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        self.settingToolView.hidden = YES;
    }];
}

- (void)loadUserInfoWithHandler:(void (^)())handler
{
    [InfoEngine getInfoWithUserId:self.userInfo.objectId block:^(id result, NSError *error) {
        if (handler) {
            handler ();
        }
        
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            self.userInfo = result;
            if (self.viewType != UserInfoViewTypeOwn)
            {
                self.isExploitsLoaded = NO;
                self.isScheduleLoaded = NO;
                __weak typeof(self)weakSelf = self;
                [self loadTeamsData:^{
                    [weakSelf loadExploitsData];
                }];
                
                [self loadScheduleData];
                
                if (!self.ownTeams) {
                    [self loadOwnTeamsData];
                }
                
            }else
            {
                self.isExploitsLoaded = NO;
                self.isScheduleLoaded = NO;
                __weak typeof(self)weakSelf = self;
                [self loadTeamsData:^{
                    [weakSelf loadExploitsData];
                }];
                
                [self loadScheduleData];
                
            }
            [self.tableView reloadData];
        }
    }];
}
- (void)loadOwnTeamsData
{
    [InfoEngine getTeamsWithUserId:[BmobUser getCurrentUser].objectId block:^(id result, NSError *error) {
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            self.ownTeams = result;
            NSInteger controllIndex = [self.dataSource indexOfObject:kUserInfoCellControll2];
            if (controllIndex != NSNotFound)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:controllIndex inSection:0];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }
    }];
}

- (void)loadTeamsData:(void(^)())block
{
//    [self showLoadingView];
    self.teamNameLabel.text = @"正在加载...";
    [InfoEngine getTeamsWithUserId:self.userInfo.objectId block:^(id result, NSError *error) {
//        [self hideLoadingView];
        
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
            self.teamNameLabel.text = @"加载失败，请刷新！";
        }else
        {
            self.teams = result;
            NSInteger baseIndex = [self.dataSource indexOfObject:kUserInfoCellBase];
            if (baseIndex != NSNotFound)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:baseIndex inSection:0];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            if ([self.teams count] == 0) {
                 self.teamNameLabel.text = @"暂无";
            }
        }
        
        if (block) {
            block();
        }
    }];
}

- (void)loadExploitsData
{
    [InfoEngine getPlayerScoreWithUserId:self.userInfo.objectId block:^(id result, NSError *error)
    {
        self.isExploitsLoaded = YES;
        if (error)
        {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            self.exploits = result;
            NSInteger index = [self.dataSource indexOfObject:kUserInfoCellExploits];
//            NSLog(@"index %ld",(long)index);
            if (index != NSNotFound)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
}

- (void)loadScheduleData
{
    [InfoEngine getScheduleMatchWithUserId:self.userInfo.objectId block:^(id result, NSError *error)
     {
         self.isScheduleLoaded = YES;
         if (error)
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             self.schedule = result;
             NSInteger index = [self.dataSource indexOfObject:kUserInfoCellSchedule];
             if (index != NSNotFound)
             {
                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
             }
         }
         
     }];
}


#pragma mark - Push
- (void)addFriendPush
{
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
   
    NSString *content =[NSString stringWithFormat:@"%@添加你为好友", selfUser.nickname ? selfUser.nickname : selfUser.username];
    Notice *msg = [[Notice alloc] init];
    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.targetId = selfUser.objectId;
    msg.title = selfUser.nickname ? selfUser.nickname : selfUser.username;
//    msg.content = content;
    msg.type = NoticeTypePersonal;
    msg.subtype = NoticeSubtypeAddFriend;
    
    [[NoticeManager sharedManager] pushNotice:msg toUsername:self.userInfo.username];
}

- (void)invitePushWithTeam:(Team *)team
{
    if(!team.captain.username)
    {
        [self showMessage:@"球队未设置队长"];
        return;
    }
    Notice *msg = [[Notice alloc] init];
    NSString *toUsername = nil;
     UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    NSString *content = nil;
    if ([team.captain.username isEqualToString:selfUser.username])
    {
        content = [NSString stringWithFormat:@"邀请您加入%@",team.name];
        //[NSString stringWithFormat:@"%@队长邀请您加入球队", team.name];
        msg.subtype = NoticeSubtypeCaptainInvitation;
        msg.targetId = team.objectId;
        toUsername = self.userInfo.username;
    }else
    {
        NSString *selfUsername     = selfUser.nickname ? selfUser.nickname : selfUser.username;
        NSString *selfUserInfoName = self.userInfo.nickname ? self.userInfo.nickname : self.userInfo.username;
        content                    = [NSString stringWithFormat:@"%@邀请%@加入他所在的球队%@",selfUsername , selfUserInfoName ,team.name];
        msg.subtype                = NoticeSubtypeMemberInvitation;
        //targetId team的objectId和用户名
        msg.targetId               = [NSString stringWithFormat:@"%@&%@", team.objectId, self.userInfo.username];
        toUsername                 = team.captain.username;
        msg.title                  = [NSString stringWithFormat:@"%@&%@",selfUsername,team.name];
    }
    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.title = team.name;
//    msg.content = content;
    msg.type = NoticeTypeTeam;
    [[NoticeManager sharedManager] pushNotice:[msg copy] toUsername:toUsername];
    [self showMessage:@"已发出邀请!"];
}

- (void)deleteTeammatePushWithTeam:(Team *)team
{
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    
    NSString *content =[NSString stringWithFormat:@"将您踢出球队"];
    Notice *msg = [[Notice alloc] init];
    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.targetId = team.objectId;
    msg.title = team.name;
    //    msg.content = content;
    msg.type = NoticeTypeTeam;
    msg.subtype = NoticeSubtypeTeamKickout;
    
    [[NoticeManager sharedManager] pushNotice:msg toUsername:self.userInfo.username];
}

#pragma mark - Private methods

- (void)updateTeamName
{
    if (self.teamNameLabel && [self.teams count] > 0) {
        for (Team *team in self.teams)
        {
            if (![self.teamNameLabel.text isEqualToString:team.name]) {
                CATransition *transition = [CATransition animation];
                transition.duration = 0.4f;
                
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                self.teamNameLabel.text = team.name;
                [self.teamNameLabel.layer addAnimation:transition forKey:nil];
                break;
            }
        }
    }
    
}

- (NSArray *)getCanInviteTeams
{
    NSMutableArray *ownTeams = [NSMutableArray arrayWithCapacity:0];
    for (Team *ownTeam in self.ownTeams)
    {
        BOOL isExist = NO;
        for (Team *team in self.teams) {
            if ([ownTeam.objectId isEqualToString:team.objectId])
            {
                isExist = YES;
            }
        }
        if (isExist)
            continue;
        [ownTeams addObject:ownTeam];
    }
    return ownTeams;
}

#pragma mark - ValueSelectionDelegate

- (void)valueSelection:(id)valueSelection didSaveAtIndex:(NSInteger)index
{
    Team *team = [self.ownTeams objectAtIndex:index];
    [self invitePushWithTeam:team];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [self.dataSource objectAtIndex:indexPath.row];
    if ([item  isEqualToString:kUserInfoCellBase])
    {
        return 93.0;
    }else if ([item  isEqualToString:kUserInfoCellData])
    {
        return 126.0;
    }else if ([item  isEqualToString:kUserInfoCellControll1])
    {
        return 43.0;
    }else if ([item  isEqualToString:kUserInfoCellControll2])
    {
        return 43.0;
    }else if ([item  isEqualToString:kUserInfoCellSchedule])
    {
        return 101.0;
    }else if ([item  isEqualToString:kUserInfoCellExploits])
    {
        return 101.0;
    }else
    {
        return 44.0;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [self.dataSource objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item];
    if ([item  isEqualToString:kUserInfoCellBase])
    {
        UIImageView *avatarImageView = (id)[cell.contentView viewWithTag:0xF0];
        avatarImageView.layer.cornerRadius =avatarImageView.bounds.size.height / 2.0;
        [avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avator.url] placeholderImage:[UIImage defaultAvatarImage] completed:nil];
        
        UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF1];
        nameLabel.text = self.userInfo.nickname ? self.userInfo.nickname : self.userInfo.username;
        
        UILabel *ageLabel = (id)[cell.contentView viewWithTag:0xF2];
        ageLabel.text = self.userInfo.birthday ? [NSString stringWithFormat:@"%ld岁", (long)[Util calAgeWithBirthDay:self.userInfo.birthday]] :@"未设置";
        
        UILabel *teamLabel = (id)[cell.contentView viewWithTag:0xF3];
        self.teamNameLabel = teamLabel;
        if (!self.teams) {
            teamLabel.text = @"";
        }else
        {
            if ([self.teams count] > 0)
            {
                teamLabel.text = [[self.teams firstObject] name];
            }else
            {
                teamLabel.text = @"暂无";
            }
        }
        
        UILabel *fieldLabel = (id)[cell.contentView viewWithTag:0xF4];
        fieldLabel.text = self.userInfo.midfielder ? positioningTypeStringFromEnum([self.userInfo.midfielder integerValue]) : @"暂无";
        UILabel *cityLabel = (id)[cell.contentView viewWithTag:0xF5];
        
        if ([self.userInfo.city integerValue] > 0)
        {
            LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[self.userInfo.city integerValue]]];
            cityLabel.text = [NSString stringWithFormat:@"%@ %@", locInfo.cityName, locInfo.districtName ? locInfo.districtName : @""];
        }else
        {
            cityLabel.text = @"暂无";
        }
        
    }else if ([item  isEqualToString:kUserInfoCellData])
    {
        UILabel *entryAuthCountLabel = (id)[cell.contentView viewWithTag:0xF0];
        entryAuthCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.userInfo.games integerValue]];
        UILabel *entryCountLabel = (id)[cell.contentView viewWithTag:0xF1];
        entryCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.userInfo.gamesTotal integerValue]];
        
        
        UILabel *assistsAuthCountLabel = (id)[cell.contentView viewWithTag:0xF2];
        assistsAuthCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.userInfo.assists integerValue]];
        UILabel *assistsCountLabel = (id)[cell.contentView viewWithTag:0xF3];
        assistsCountLabel.text =  [NSString stringWithFormat:@"%ld", (long)[self.userInfo.assistsTotal integerValue]];
        
        UILabel *goalsAuthCountLabel = (id)[cell.contentView viewWithTag:0xF4];
        goalsAuthCountLabel.text =  [NSString stringWithFormat:@"%ld", (long)[self.userInfo.goals integerValue]];
        UILabel *goalsCountLabel = (id)[cell.contentView viewWithTag:0xF5];
        goalsCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.userInfo.goalsTotal integerValue]];
        
        UILabel *scoreAuthAvgLabel = (id)[cell.contentView viewWithTag:0xF6];
        scoreAuthAvgLabel.text =  [NSString stringWithFormat:@"%.1f", [self.userInfo.score floatValue]];
        UILabel *scoreAvgLabel = (id)[cell.contentView viewWithTag:0xF7];
        scoreAvgLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.userInfo.score integerValue]];
        
    }else if ([item  isEqualToString:kUserInfoCellControll1])
    {
        
    }else if ([item  isEqualToString:kUserInfoCellControll2])
    {
        UIButton *addFriendButton = (id)[cell.contentView viewWithTag:0xF0];
        addFriendButton.hidden = YES;
        UIButton *delFriendButton = (id)[cell.contentView viewWithTag:0xF1];
        delFriendButton.hidden = YES;
        UIButton *addTeammateButton = (id)[cell.contentView viewWithTag:0xF2];
        addTeammateButton.hidden = YES;
        UIButton *delTeammateButton = (id)[cell.contentView viewWithTag:0xF3];
        delTeammateButton.hidden = YES;
        NSMutableArray *controlls = [NSMutableArray arrayWithCapacity:0];
        if (self.viewType == UserInfoViewTypeInfo)
        {
            if(self.isFriend)
            {
                [controlls addObject:delFriendButton];
            }else
            {
                [controlls addObject:addFriendButton];
            }
            if ([[self getCanInviteTeams] count] > 0) {
                [controlls addObject:addTeammateButton];
            }
        }else if(self.viewType == UserInfoViewTypeTeam && [self.ownTeams count] == 1)
        {
            Team *team = [self.ownTeams firstObject];
            if(self.isFriend)
            {
                [controlls addObject:delFriendButton];
            }else
            {
                [controlls addObject:addFriendButton];
            }
            if ([team.captain.objectId isEqualToString:[BmobUser getCurrentUser].objectId])
            {
                if(self.isTeammate)
                {
                    [controlls addObject:delTeammateButton];
                }else
                {
                    if ([[self getCanInviteTeams] count] > 0) {
                        [controlls addObject:addTeammateButton];
                    }
                }
            }
            
        }
        CGRect frame = addFriendButton.frame;
        int count = (int)[controlls count];
        for (int i = 0;  i < count; i ++) {
            UIButton *controll = [controlls objectAtIndex:i];
            controll.hidden = NO;
            if (count == 2) {
                if (i == 1) {
                    frame.origin.x = 160;
                    frame.size.width = 160;
                }else
                {
                    frame.origin.x = 0;
                    frame.size.width = 160;
                }
            }else
            {
                frame.origin.x = 0;
                frame.size.width = 320;
            }
            controll.frame = frame;
        }
        
        /*
        if (self.isTeammateClickPush)
        {
            
            
            UIButton *leftBtn = (id)[cell.contentView viewWithTag:0xF0];
            leftBtn.hidden = YES;
            
            UIButton *rightBtn = (id)[cell.contentView viewWithTag:0xF1];
            rightBtn.hidden = YES;

            
            
            if (self.isCaptionClickPush)
            {
                
                UIButton *deleteButton = (id)[cell.contentView viewWithTag:0xF2];
                deleteButton.hidden=NO;
                [deleteButton setTitle:@"删除队友" forState:UIControlStateNormal];
                [deleteButton addTarget:self action:@selector(onDelTeammate:) forControlEvents:UIControlEventTouchUpInside];
                

            }
            else
            {
                UIButton *deleteButton = (id)[cell.contentView viewWithTag:0xF2];
                
                if (self.isFriend)
                {
                    deleteButton.hidden=YES;
                }
                else
                {
                    
                    deleteButton.hidden=NO;
                    [deleteButton setTitle:@"加为好友" forState:UIControlStateNormal];
                    [deleteButton addTarget:self action:@selector(onAddFriend:) forControlEvents:UIControlEventTouchUpInside];
                    
                }

                
            }
            
            
            
            
            
        }
        else
        {
            
            
            UIButton *leftBtn = (id)[cell.contentView viewWithTag:0xF0];
            if (self.isFriend)
            {
                [leftBtn setTitle:@"删除好友" forState:UIControlStateNormal];
                [leftBtn removeTarget:self action:@selector(onAddFriend:) forControlEvents:UIControlEventTouchUpInside];
                [leftBtn addTarget:self action:@selector(onDelFriend:) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
                [leftBtn setTitle:@"加为好友" forState:UIControlStateNormal];
                [leftBtn removeTarget:self action:@selector(onDelFriend:) forControlEvents:UIControlEventTouchUpInside];
                [leftBtn addTarget:self action:@selector(onAddFriend:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            UIButton *rightBtn = (id)[cell.contentView viewWithTag:0xF1];
            if ([[self getCanInviteTeams] count] > 0 && [self.teams count] < 2)
            {
                rightBtn.hidden = NO;
                [rightBtn addTarget:self action:@selector(onInviting:) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
                rightBtn.hidden = YES;
            }

            
            UIButton *deleteButton = (id)[cell.contentView viewWithTag:0xF2];
            deleteButton.hidden=YES;
            
         
            
        }
        */
        
        
    }else if ([item  isEqualToString:kUserInfoCellSchedule])
    {
        UILabel *mesaageLabel = (id)[cell.contentView viewWithTag:0xFA];
        UILabel *dateLabel = (id)[cell.contentView viewWithTag:0xF0];
        if (self.isScheduleLoaded && [self.schedule isKindOfClass:[NSArray class]] && [self.schedule count] > 0)
        {
            mesaageLabel.superview.hidden = YES;
            dateLabel.superview.hidden = NO;
            Tournament *match = [self.schedule firstObject];
            
            dateLabel.text = [DateUtil formatedDate:match.start_time byDateFormat:@"MM/dd HH:mm"];
            
            UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF1];
            nameLabel.text = [NSString stringWithFormat:@"%@ - %@", match.home_court.name ? match.home_court.name : @"", match.opponent.name ? match.opponent.name : @""];
            
            UILabel *addressLabel = (id)[cell.contentView viewWithTag:0xF2];
            addressLabel.text = match.site;
        }else
        {
            mesaageLabel.superview.hidden = NO;
            dateLabel.superview.hidden = YES;
            if (!self.isScheduleLoaded) {
                mesaageLabel.text = @"正在加载赛程...";
            }else if ([self.schedule isKindOfClass:[NSArray class]])
            {
                mesaageLabel.text = @"暂无赛程信息";
            }else
            {
                mesaageLabel.text = @"赛程信息加载出错";
            }
        }
    }else if ([item  isEqualToString:kUserInfoCellExploits])
    {
        UILabel *mesaageLabel = (id)[cell.contentView viewWithTag:0xFA];
        UILabel *dateLabel = (id)[cell.contentView viewWithTag:0xF0];
        if (self.isExploitsLoaded && [self.exploits isKindOfClass:[NSArray class]] && [self.exploits count] > 0)
        {
            mesaageLabel.superview.hidden = YES;
            dateLabel.superview.hidden = NO;
            PlayerScore *score = [self.exploits firstObject];
            dateLabel.text = [DateUtil formatedDate:score.competition.start_time byDateFormat:@"MM/dd HH:mm"];
            
            UILabel *homeCourtLabel = (id)[cell.contentView viewWithTag:0xF1];
            homeCourtLabel.text =score.competition.home_court.name;
            
            UILabel *scoreLabel = (id)[cell.contentView viewWithTag:0xF2];
            if (self.teams.count >=1 ) {
                for (Team *team in self.teams) {
                    if ([team.objectId isEqualToString:score.competition.home_court.objectId] || [team.objectId isEqualToString:score.competition.opponent.objectId]) {
                        if ([team.objectId isEqualToString:score.competition.home_court.objectId]) {
                            if (score.competition.score_h || score.competition.score_h2) {
                                scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [score.competition.score_h intValue], [score.competition.score_h2 intValue]];
                            }else
                            {
                                scoreLabel.text = @"0 - 0";
                            }
                        }else{
                            if (score.competition.score_o2 || score.competition.score_o) {
                                scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [score.competition.score_o2 intValue], [score.competition.score_o intValue]];
                            }else
                            {
                                scoreLabel.text = @"0 - 0";
                            }
                        }
                    }
                    break;
                }
            }else{
                if (score.competition.score_h || score.competition.score_h2) {
                    scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [score.competition.score_h intValue], [score.competition.score_h2 intValue]];
                }else
                {
                    scoreLabel.text = @"0 - 0";
                }
            }
            
            
            
           
            
            UILabel *opponentLabel = (id)[cell.contentView viewWithTag:0xF3];
            opponentLabel.text = score.competition.opponent.name;
            
            UILabel *goalsLabel = (id)[cell.contentView viewWithTag:0xF4];
//            goalsLabel.text = [NSString stringWithFormat:@"%@", score.goals];
            if (score.goals) {
                goalsLabel.text = [NSString stringWithFormat:@"%@", score.goals];
            }else{
                goalsLabel.text = [NSString stringWithFormat:@"%@", @"0"];
            }
            
            UILabel *assistsLabel = (id)[cell.contentView viewWithTag:0xF5];
            if (score.assists) {
                assistsLabel.text = [NSString stringWithFormat:@"%@", score.assists];
            }else{
                assistsLabel.text = [NSString stringWithFormat:@"%@", @"0"];
            }
            
        }else
        {
            mesaageLabel.superview.hidden = NO;
            dateLabel.superview.hidden = YES;
            if (!self.isExploitsLoaded) {
                mesaageLabel.text = @"正在加载战绩...";
            }else if ([self.exploits isKindOfClass:[NSArray class]])
            {
                 mesaageLabel.text = @"暂无战绩信息";
            }else
            {
                mesaageLabel.text = @"战绩信息加载出错";
            }
        }
        
        
    }else
    {
        
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}
//push_exploits  push_schedule
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (self.isTeammateClickPush)
//    {
//        
//    }
//    else
//    {
    
        NSString *item = [self.dataSource objectAtIndex:indexPath.row];
        if ([item  isEqualToString:kUserInfoCellSchedule])
        {
            if([self.schedule count] > 0)
            {
                [self performSegueWithIdentifier:@"push_schedule" sender:nil];
            }
            
        }else if ([item  isEqualToString:kUserInfoCellExploits])
        {
            if([self.exploits count] > 0)
            {
                [self performSegueWithIdentifier:@"push_exploits" sender:nil];
            }
        }

        
//    }

    
}

#pragma mark - Event handler

//- (void)handleUserInfoChange
//{
//    [self loadUserInfo];
//}
//
//- (void)handleMatchChange
//{
//    [self loadUserInfo];
//    [self loadExploitsData];
//    [self loadScheduleData];
//   
//}

- (IBAction)onFriends:(id)sender {
    
    BDLog(@"on friends!");
}
- (IBAction)onNearbyMatch:(id)sender {
    
    BDLog(@"on nearby match!");
}

- (IBAction)onAddFriend:(id)sender
{
    BmobUser *user = [BmobUser getCurrentUser];
    BmobRelation *relation = [BmobRelation relation];
    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.userInfo.objectId]];
    [user addRelation:relation forKey:@"friends"];
    [self showLoadingView];
    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        [self hideLoadingView];
        if (isSuccessful)
        {
            [self showMessage:@"添加好友成功"];
            self.isFriend = YES;
            if ([self.dataSource indexOfObject:kUserInfoCellControll2] != NSNotFound)
            {
                NSIndexPath *index = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:kUserInfoCellControll2] inSection:0];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self performRunnable:^
            {
                [self addFriendPush];
            } afterDelay:1.5f];
        }else
        {
            BDLog(@"add friend error %@",error);
        }
        
    }];
}

- (IBAction)onDelFriend:(id)sender
{
    BmobUser *user = [BmobUser getCurrentUser];
    BmobRelation *relation = [BmobRelation relation];
    [relation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.userInfo.objectId]];
    [user addRelation:relation forKey:@"friends"];
    [self showLoadingView];
    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        [self hideLoadingView];
        if (isSuccessful)
        {
            [self showMessage:@"删除好友成功"];
            self.isFriend = NO;
            if ([self.dataSource indexOfObject:kUserInfoCellControll2] != NSNotFound)
            {
                NSIndexPath *index = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:kUserInfoCellControll2] inSection:0];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }else
        {
            BDLog(@"del friend error %@", error);
        }
        
    }];
}



-(IBAction)onDelTeammate:(id)sender
{
    Team *team = nil;
    if(self.viewType == UserInfoViewTypeTeam && [self.ownTeams count] == 1)
    {
        team = [self.ownTeams firstObject];
    }else
    {
        return ;
    }
    //删除关联
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:team.objectId];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.userInfo.objectId]];
    
    [obj addRelation:relation forKey:@"footballer"];
    
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        
        [self.navigationController popViewControllerAnimated:YES];

        if (isSuccessful)
        {
            [self showMessage:@"删除队友成功！"];
            [self performRunnable:^{
                if (self.navigationController)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } afterDelay:1.5];
            [self deleteTeammatePushWithTeam:team];
        }
        else
        {
            [self showMessage:@"删除队友失败！"];
        }
        
        
    }];


    
}

- (IBAction)onInviting:(UIButton *)sender
{
    if ([[self getCanInviteTeams] count] >= 2)
    {
        ValueSelectionViewController *selection = [self.storyboard instantiateViewControllerWithIdentifier:@"ValueSelectionViewController"];
        selection.title = @"所属球队";
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        for (Team *aTeam in [self getCanInviteTeams]) {
            [array addObject:aTeam.name];
        }
        selection.buttonTitle = @"发送";
        selection.dataSource = array;
        selection.delegate = self;
        [self.navigationController pushViewController:selection animated:YES];
        
    }else if([[self getCanInviteTeams] count] == 1)
    {
        
        [sender setTitle:@"已邀请" forState:UIControlStateNormal];
        [self invitePushWithTeam:[[self getCanInviteTeams] firstObject]];
        
        sender.enabled = NO;
        [self performSelector:@selector(enableInviteButton:) withObject:sender afterDelay:30.0f];
        
    }else
    {
        [self showMessage:@"无所属球队"];
    }


}


-(void)enableInviteButton:(UIButton *)button{
    button.enabled = YES;
    [button setTitle:@"邀请入队" forState:UIControlStateNormal];
}


- (IBAction)onSetting:(UIButton *)sender
{
    self.isSetting = !self.isSetting;
    if (self.isSetting) {
        [self showSettingToolView];
    }else
    {
        [self hideSettingToolView];
    }
}
- (IBAction)onLogout:(id)sender
{
    
//#warning 删除tag
    [TeamEngine getTeamsObjectIdWith:[BmobUser getCurrentUser]
                               block:^(id result, NSError *error) {
                                   NSArray *array = result;
                                   if (array && array.count > 0) {
                                       [BPushUtil deleteTags:array];
                                   }
                               }];
    //退出时把百度的userid和channelId置空
    BmobUser *user = [BmobUser getCurrentUser];
    if (user) {
        [user deleteForKey:@"pushChannelId"];
        [user deleteForKey:@"pushUserId"];
        [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            [BmobUser logout];
        }];
    }
    
    
    
    [[MainNavigationController shareMainNavigationController] popToLoginViewControllerAnimated:YES];
    if (![BmobUser getCurrentUser])
    {
        [NoticeManager updatePushProfile];
        [[NoticeManager sharedManager] unbindDB];
    }
    
}
- (IBAction)getShareUserClick:(id)sender
{
    
    [self hideSettingToolView];
    self.isSetting=NO;

    
    CHTumblrMenuView *menuView = [[CHTumblrMenuView alloc] init];
    [menuView addMenuItemWithTitle:@"短信" andIcon:[UIImage imageNamed:@"message.png"] andSelectedBlock:^{
        
        BDLog(@"短信 selected");
        
        
        [self showShareViewWithType:ShareTypeSMS];
        
        
    }];
    
    
    [menuView addMenuItemWithTitle:@"微信" andIcon:[UIImage imageNamed:@"wx.png"] andSelectedBlock:^{
        
        BDLog(@"微信 selected");
        
        [self showShareViewWithType:ShareTypeWeixiSession];
        
        
    }];
    
    
    [menuView addMenuItemWithTitle:@"微信朋友圈" andIcon:[UIImage imageNamed:@"pyq.png"] andSelectedBlock:^{
        
        
        BDLog(@"微信朋友圈");
        
        [self showShareViewWithType:ShareTypeWeixiTimeline];
        
        
    }];
    
    
    
    [menuView addMenuItemWithTitle:@"微博" andIcon:[UIImage imageNamed:@"wb.png"] andSelectedBlock:^{
        
        BDLog(@"微博 selected");
        
        [self showShareViewWithType:ShareTypeSinaWeibo];
        
        
    }];
    
    
    [menuView show];
    
    
}


-(void)showShareViewWithType:(ShareType)type
{
    
    self.shareTitle=@"个人总体数据";
    self.shareUrl=[NSString stringWithFormat:@"http://tq.codenow.cn/share/PersonTotalData?user=%@",[[BmobUser getCurrentUser] objectId]];
    self.shareContent=[NSString stringWithFormat:@"每一次进步，都是辛勤的付出！我的总体表现是:%@",self.shareUrl];
    
    
    id<ISSContent> content = [ShareSDK content:self.shareContent
                                defaultContent:nil
                                         image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@"res2.jpg"] quality:1]
                                         title:self.shareTitle
                                           url:self.shareUrl
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"踢球吧"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"踢球吧"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    __weak typeof(self) weakSelf = self;
    [ShareSDK shareContent:content
                      type:type
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                    
                        if (state == SSPublishContentStateSuccess)
                        {
                            BDLog(@"分享成功!");
                            if (type == ShareTypeSinaWeibo) {
                                [weakSelf showMessage:@"分享成功"];
                            }
                            
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            //                            if ([error errorCode] == -22003)
                            //                            {
                            //                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TEXT_TIPS", @"提示")
                            //                                                                                    message:[error errorDescription]
                            //                                                                                   delegate:nil
                            //                                                                          cancelButtonTitle:NSLocalizedString(@"TEXT_KNOW", @"知道了")
                            //                                                                          otherButtonTitles:nil];
                            //                                [alertView show];
                            //                            }
                            
                            
                            BDLog(@"分享失败!***%ld，%@", (long)[error errorCode], [error errorDescription]);
                            
                            
                        }
                    }];
}


//-(void)contactUs{
//    ;
//}
- (IBAction)contactUs:(id)sender {
    [self performSegueWithIdentifier:@"toContactUsVC" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"user_setting"]) {
        [segue.destinationViewController setValue:self.userInfo forKey:@"userInfo"];
    }else if ([segue.identifier isEqualToString:@"push_schedule"])
    {
        [segue.destinationViewController setValue:self.schedule forKey:@"schedule"];
        [segue.destinationViewController setValue:self.userInfo forKey:@"userInfo"];
    }else if ([segue.identifier isEqualToString:@"push_exploits"])
    {
        [segue.destinationViewController setValue:self.exploits forKey:@"exploits"];
        [segue.destinationViewController setValue:self.userInfo forKey:@"userInfo"];
        [segue.destinationViewController setValue:self.teams forKey:@"teams"];
    }
    //push_exploits
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

@end

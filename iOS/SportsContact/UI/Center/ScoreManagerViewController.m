//
//  ScoreManagerViewController.m
//  SportsContact
//
//  Created by bobo on 14-8-5.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "ScoreManagerViewController.h"
#import "Util.h"
#import "DateUtil.h"
#import "ViewUtil.h"
#import "NSObject+MGBlockPerformer.h"
#import <ODRefreshControl.h>
#import "NoticeManager.h"
#import "TeamEngine.h"
#import "LocationInfoManager.h"
#import "ManageTeamViewController.h"
#import "PickerViewController.h"
#import "CHTumblrMenuView.h"
#import <ShareSDK/ShareSDK.h>
#import "GamescoreTipView.h"

#define kScoreManagerCellBase @"base_cell"
#define kScoreManagerCellData @"data_cell"
#define kScoreManagerControll1 @"controll1_cell"

#define OwnGoalsAssistsChangeKey @"OwnGoalsAssistsChangeKey"
#define kScoreManagerSaveTag 121231299



#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"

#define TITLE @"测试_Title"
#define CONTENT @"测试_Content"
#define URL @"http://www.baidu.com"


typedef NS_OPTIONS(NSInteger, PickerViewSettingType){
    PickerViewSettingTypeNone = 0,
    PickerViewSettingTypePlayerScore = 1,
    PickerViewSettingTypeMyPlayerScore = 2,
    PickerViewSettingTypeMatchScore = 3
};


/**
 *  设置类型
 */
typedef NS_OPTIONS(NSInteger, ScoreManagerEditType){
    ScoreManagerEditTypeNone = 0,
    ScoreManagerEditTypeHomeCourt = 1,
    ScoreManagerEditTypeOpponentCourt = 2
};

@interface ScoreManagerViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, PickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *matchDate;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeCourtLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeCourtScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *debutButton;
@property (weak, nonatomic) IBOutlet UILabel *assistsLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalsLabel;

@property (strong, nonatomic) IBOutlet UIView *popToolView;
@property (weak, nonatomic) IBOutlet UIPickerView *valuePicker;

@property (nonatomic, strong) TeamScore *teamScore;
@property (nonatomic, strong) PlayerScore *playerScore;
@property (nonatomic, strong) NSString *playerScoreChangeKey;
@property (nonatomic, strong) NSArray *playerScoreArray;
@property (nonatomic, strong) NSMutableArray *homeCourtPlayers;
@property (nonatomic, strong) NSMutableArray *opponentPlayers;
@property (nonatomic, strong) NSMutableDictionary *goalsChange;
@property (nonatomic, strong) NSMutableDictionary *assistsChange;
//@property (nonatomic, strong) NSMutableArray *scoreChange;

@property (nonatomic, assign) BOOL dataLoaded;
@property (nonatomic, assign) BOOL loadedError;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, weak) PlayerScore *settingPlayerScore;
@property (nonatomic, assign) PickerViewSettingType settingType;
@property (nonatomic, assign) ScoreManagerEditType editType;

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic)  NSString *shareTitle;
@property (strong, nonatomic)  NSString *shareContent;
@property (strong, nonatomic)  NSString *shareUrl;

@property (nonatomic, assign) BOOL hasChanged;

@end

@implementation ScoreManagerViewController

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
    self.title = @"比赛结果";
    self.hasChanged = NO;
    self.dataLoaded = NO;
    self.loadedError = NO;
    self.goalsChange = [NSMutableDictionary dictionaryWithCapacity:0];
    self.assistsChange = [NSMutableDictionary dictionaryWithCapacity:0];
    self.playerScoreChangeKey = OwnGoalsAssistsChangeKey;
    
    
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"zf.png"] forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"zf_.png"] forState:UIControlStateHighlighted];

    self.shareButton.hidden=NO;
    
    
    UIButton *backBtn = [self backbutton];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    // Do any additional setup after loading the view.
    if (!self.userInfo) {
        self.userInfo = [[UserInfo  alloc] initWithDictionary:[BmobUser getCurrentUser]];
    }
    if (![self.userInfo.objectId isEqualToString:[BmobUser getCurrentUser].objectId])
    {
        self.canEdit = NO;
    }
    if ([[NSDate dateFromServer] timeIntervalSince1970] < [self.match.start_time timeIntervalSince1970]) {
        self.canEdit = NO;
    }
  
    UIView *toolBgView = [self.popToolView viewWithTag:0xF0];
    [ViewUtil addSingleTapGestureForView:toolBgView target:self action:@selector(hidePopToolView)];
    
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    if (!self.match)
    {
         [self loadMatchData];
    }else
    {
        
        if (!self.team)
        {
            [self loadTeams];
        }else
        {
            self.editType = ScoreManagerEditTypeNone;
            if ([self.team.objectId isEqualToString:self.match.home_court.objectId]) {
                self.editType = ScoreManagerEditTypeHomeCourt;
            }else if ([self.team.objectId isEqualToString:self.match.opponent.objectId]) {
                self.editType = ScoreManagerEditTypeOpponentCourt;
            }
            [self showLoadingView];
            [self loadTeamScoreWithHandler:^{
                [self hideLoadingView];
            }];
        }
    }
    if (self.match.isVerify) {
        self.canEdit = NO;
    }
    
    if (self.canEdit && [self isTeamCaptain] && self.team && self.match) {
        [self enableRightButton];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefresh) name:kObserverCommentScoreChanged object:nil];
    
    //显示
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"first_score_in"] boolValue]) {
        GamescoreTipView *tipView =  LoadNibOwner(@"GamescoreTipView", self);
        [self.navigationController.view addSubview:tipView];
        tipView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isNeedRefresh) {
        self.isNeedRefresh = NO;
        [self showLoadingView];
        [self loadPalyersScoreWithHandler:^{
            [self hideLoadingView];
        }];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kObserverCommentScoreChanged object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
//    if (self.hasChanged) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已修改了数据，刷新将放弃这些修改，是否刷新？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
//        [alertView show];
//    }else
//    {
//        [self reloadTeamScoreData];
//    }
//    self.dataLoaded = NO;
     [self loadTeamScoreWithHandler:nil];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)reloadTeamScoreData
{
    [self disenableRightButton];
    self.dataLoaded = NO;
    [self loadTeamScoreWithHandler:nil];
}

- (BOOL) isTeamCaptain
{
    return self.team && [self.team.captain.objectId isEqualToString:[BmobUser getCurrentUser].objectId];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self reloadTeamScoreData];
    }else
    {
        [self.refreshControl endRefreshing];
    }
}
#pragma mark - PickerViewControllerDelegate

- (NSInteger)numberOfComponentsInPickerViewController:(PickerViewController *)pickerViewController
{
    return 1;
}

- (NSInteger)pickerViewController:(PickerViewController *)pickerViewController numberOfRowsInComponent:(NSInteger)component
{
    return 50;
}

- (NSString *)pickerViewController:(PickerViewController *)pickerViewController titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", (long)row];
}

- (void)didConfirmForPickerViewController:(PickerViewController *)pickerViewController
{
    if ([pickerViewController.userInfo isKindOfClass:[UILabel class]]) {
        self.hasChanged = YES;
        UILabel *targetLabel = pickerViewController.userInfo;
        targetLabel.text = [NSString stringWithFormat:@"%ld", (long)[pickerViewController.pickerView selectedRowInComponent:0]];
        [pickerViewController hide];
    
        
//        [self onDebut:self.debutButton];
        [self debutWithoutButton];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"push_comment"]) {
        if ([sender isKindOfClass:[UserInfo class]])
        {
            [segue.destinationViewController setValue:sender forKeyPath:@"userInfo"];
        }else if([sender isKindOfClass:[NSArray class]])
        {
            [segue.destinationViewController setValue:[sender[0] player] forKeyPath:@"userInfo"];
            [segue.destinationViewController setValue:sender[0] forKeyPath:@"playerScore"];
            [segue.destinationViewController setValue:sender[1] forKey:@"needInputCell"];
        }
        
        [segue.destinationViewController setValue:self.match forKeyPath:@"match"];
        
    }
}

#pragma mark - Private Method
- (void)loadMatchData
{
    [self showLoadingView];
//    if (![self.refreshControl refreshing])
//    {
//        [self.refreshControl beginRefreshing];
//    }
    [MatchEngine getNextMatchWithUserId:[[BmobUser getCurrentUser] objectId] block:^(id result, NSError *error)
    {
        [self hideLoadingView];
        if (error)
        {
//            [self.refreshControl endRefreshing];
            self.errorMessage = @"加载比赛数据错误！";
            self.loadedError = YES;
            self.dataLoaded = YES;
            [self.tableView reloadData];
        }else
        {
            if (result)
            {
                self.match = result;
                if (self.match.isVerify) {
                    self.canEdit = NO;
                }
                if ([[NSDate dateFromServer] timeIntervalSince1970] < [self.match.start_time timeIntervalSince1970]) {
                    self.canEdit = NO;
                }
                if (self.team && self.canEdit && [self isTeamCaptain]) {
                    [self enableRightButton];
                }
                if (!self.team)
                {
                    [self loadTeams];
                }
            }else
            {
                [self.refreshControl endRefreshing];
                self.errorMessage = @"暂无可编辑球赛！";
                self.loadedError = YES;
                self.dataLoaded = YES;
                [self.tableView reloadData];
            }
        }
    }];
}

- (void)loadTeams
{
    [self showLoadingView];
    [InfoEngine getTeamsWithUserId:[[BmobUser getCurrentUser] objectId] block:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (!error)
         {
             if ([(NSArray*)result count] == 0)
             {
//                 [self showMessage:@"无所属球队！"];
//                 [self hideLoadingView];
                 [self.refreshControl endRefreshing];
                 self.errorMessage = @"无所属球队！";
                 self.loadedError = YES;
                 self.dataLoaded = YES;
                 [self.tableView reloadData];
             }else if([(NSArray*)result count] == 1)
             {
                 self.team = [result firstObject];
                 [self loadTeamScoreWithHandler:nil];
             }else
             {
                 for (Team *team in result)
                 {
                     if([team.objectId isEqualToString:self.match.home_court.objectId] || [team.objectId isEqualToString:self.match.opponent.objectId])
                     {
                         self.team = team;
                         [self loadTeamScoreWithHandler:nil];
                     }
                 }
             }
             if (self.team && self.canEdit && [self isTeamCaptain]) {
                 [self enableRightButton];
             }
             self.editType = ScoreManagerEditTypeNone;
             if ([self.team.objectId isEqualToString:self.match.home_court.objectId]) {
                 self.editType = ScoreManagerEditTypeHomeCourt;
             }else if ([self.team.objectId isEqualToString:self.match.opponent.objectId]) {
                 self.editType = ScoreManagerEditTypeOpponentCourt;
             }
         }else
         {
             [self.refreshControl endRefreshing];
             self.errorMessage = @"加载所属球队错误！";
             self.loadedError = YES;
             self.dataLoaded = YES;
             [self.tableView reloadData];
//             [self showMessage:[Util errorStringWithCode:error.code]];
//             [self hideLoadingView];
//             [self performRunnable:^{
//                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//             } afterDelay:1.5f];
         }
         
     }];
}
- (void)reloadMatchDataWithHandler:(void (^)())handler
{
    [MatchEngine getMatchWithMatchId:self.match.objectId block:^(id result, NSError *error)
     {
         if (error) {
             [self.refreshControl endRefreshing];
             self.errorMessage = @"加载数据错误！";
             self.loadedError = YES;
             self.dataLoaded = YES;
             [self.tableView reloadData];
             if (handler) {
                 handler();
             }
         }else
         {
             self.match = result;
             [self loadTeamScoreWithHandler:handler];
             [self setUpMatchInfo];
             self.canEdit = !self.match.isVerify;
             if (self.team && self.canEdit && [self isTeamCaptain]) {
                 [self enableRightButton];
             }else
             {
                 [self disenableRightButton];
             }
         }
     }];
}

- (void)loadTeamScoreWithHandler:(void (^)())handler
{

//    if (self.team.objectId && [self.team.objectId isEqualToString:self.match.home_court.objectId]) {
//        TeamScore *result = [[TeamScore alloc] init];
//        if (self.match.score_h) {
//            result.goals = [NSNumber numberWithInteger: [self.match.score_h integerValue] ];
//        }
//        if (self.match.score_h2) {
//            result.goals_against = [NSNumber numberWithInteger: [self.match.score_h2 integerValue] ];
//        }
//        self.teamScore = result;
//        [self loadPalyersScoreWithHandler:handler];
//    }else if(self.team.objectId && [self.team.objectId isEqualToString:self.match.opponent.objectId]){
//        TeamScore *result = [[TeamScore alloc] init];
//        if (self.match.score_o) {
//            result.goals = [NSNumber numberWithInteger: [self.match.score_o integerValue] ];
//        }
//        if (self.match.score_o2) {
//            result.goals_against = [NSNumber numberWithInteger: [self.match.score_o2 integerValue] ];
//        }
//        self.teamScore = result;
//        [self loadPalyersScoreWithHandler:handler];
//    }
    
    [MatchEngine getTeamTeamScoreWithTournamentId:self.match.objectId teamId:self.team.objectId block:^(id result, NSError *error)
     {
         
         if (error)
         {
             [self.refreshControl endRefreshing];
             self.errorMessage = @"加载所属球队数据错误！";
             self.loadedError = YES;
             self.dataLoaded = YES;
             [self.tableView reloadData];
             if (handler) {
                 handler();
             }
         }else
         {
             self.teamScore = result;
             [self loadPalyersScoreWithHandler:handler];
         }
     }];
}

- (void)loadPalyersScoreWithHandler:(void (^)())handler
{
    [MatchEngine getPlayerScoreWithTournament:self.match.objectId block:^(id result, NSError *error)
    {
        if (handler)
        {
            handler();
        }
        
        self.dataLoaded = YES;
        [self.refreshControl endRefreshing];
        if (error)
        {
            self.errorMessage = @"加载比赛队员数据错误！";
            self.loadedError = YES;
            [self.tableView reloadData];
        }else
        {
            self.playerScoreArray = result;
            [self setUpPlayersData];
        }
        self.debutButton.userInteractionEnabled = self.canEdit;
    }];
}

- (void)setUpPlayersData
{
    self.homeCourtPlayers = [NSMutableArray arrayWithCapacity:0];
    self.opponentPlayers = [NSMutableArray arrayWithCapacity:0];
    for (PlayerScore *playerScore in self.playerScoreArray ) {
        if ([playerScore.player.objectId  isEqualToString:[BmobUser getCurrentUser].objectId])
        {
            self.playerScore = playerScore;
            self.playerScoreChangeKey = self.playerScore.objectId;
        }else if ([playerScore.team.objectId isEqualToString:self.match.home_court.objectId])
        {
            BOOL exist = NO;
            for (PlayerScore *homeCourtPlayer in self.homeCourtPlayers) {
                if ([homeCourtPlayer.player.objectId isEqualToString:playerScore.player.objectId]) {
                    exist = YES;
                }
            }
            if (!exist) {
                [self.homeCourtPlayers addObject:playerScore];
            }
        }else if ([playerScore.team.objectId isEqualToString:self.match.opponent.objectId])
        {
            BOOL exist = NO;
            for (PlayerScore *opponentPlayer in self.opponentPlayers) {
                if ([opponentPlayer.player.objectId isEqualToString:playerScore.player.objectId]) {
                    exist = YES;
                }
            }
            if (!exist) {
                [self.opponentPlayers addObject:playerScore];
            }
        }
    }
    self.dataLoaded = YES;
    self.loadedError = NO;
    [self.tableView reloadData];
}

- (void)setUpMatchInfo
{
    //, [DateUtil formatedDate:self.match.event_date byDateFormat:@"HH:mm"]
    self.matchDate.text = [NSString stringWithFormat:@"%@", [DateUtil formatedDate:self.match.event_date byDateFormat:@"yyyy.MM.dd"]];
    LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[self.match.city integerValue]]];
    NSString *adressString = locInfo.cityName ? [NSString stringWithFormat:@"%@ ", locInfo.cityName] : @"";
    self.addressLabel.text =[adressString stringByAppendingString:self.match.site ? self.match.site : @""];
    self.typeLabel.text = tournamentTypeStringFromEnum([self.match.nature integerValue]);
    self.homeCourtLabel.text = self.match.home_court.name;
    self.opponentLabel.text = self.match.opponent.name;
    self.homeCourtScoreLabel.text = @"0";
    self.opponentScoreLabel.text = @"0";
    if ([self.team.objectId isEqualToString: self.match.home_court.objectId])
    {
        self.homeCourtScoreLabel.text = self.match.score_h ? self.match.score_h : @"0";;//[NSString stringWithFormat:@"%d", [self.teamScore.goals integerValue]];
        self.opponentScoreLabel.text = self.match.score_h2 ? self.match.score_h2 : @"0";//[NSString stringWithFormat:@"%d", [self.teamScore.goals_against integerValue]];
    }else if (  [self.team.objectId isEqualToString: self.match.opponent.objectId])
    {
        self.homeCourtScoreLabel.text = self.match.score_o2 ? self.match.score_o2 : @"0";//[NSString stringWithFormat:@"%d", [self.teamScore.goals_against integerValue]];
        self.opponentScoreLabel.text = self.match.score_o ? self.match.score_o : @"0";;//[NSString stringWithFormat:@"%d", [self.teamScore.goals integerValue]];
    }
//    else
//    {
//        self.homeCourtScoreLabel.text = self.match.score_h ? self.match.score_h : @"0";
//        self.opponentScoreLabel.text = self.match.score_o ? self.match.score_o : @"0";
//    }
    
//    self.
}


- (void)showPopToolView
{
    self.popToolView.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:self.popToolView];
    self.popToolView.hidden = NO;
    UIView *bgView = [self.popToolView viewWithTag:0xF0];
    UIView *toolView = [self.popToolView viewWithTag:0xF1];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = toolView.frame;
        frame.origin.y = self.popToolView.frame.size.height - frame.size.height;
        toolView.frame  = frame;
        bgView.alpha = 0.3;
    } completion:nil];
}

- (void)hidePopToolView
{
    UIView *bgView = [self.popToolView viewWithTag:0xF0];
    UIView *toolView = [self.popToolView viewWithTag:0xF1];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = toolView.frame;
        frame.origin.y = self.popToolView.frame.size.height;
        toolView.frame  = frame;
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        self.popToolView.hidden = YES;
        [self.popToolView removeFromSuperview];
    }];
    self.settingPlayerScore = nil;
}

- (void)loadTeamToTransformTeamInfoWithTeam:(Team *)team
{
    [self showLoadingView];
    [TeamEngine getInfoWithTeamId:team.objectId block:^(id result, NSError *error) {
        [self hideLoadingView];
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            if (result)
            {
                UIStoryboard *teamStoryboard = [UIStoryboard storyboardWithName:@"Teams" bundle:[NSBundle mainBundle]];
                ManageTeamViewController *teamInfoVC = [teamStoryboard instantiateViewControllerWithIdentifier:@"ManageTeamViewController"];
                teamInfoVC.title=@"球队资料";
                teamInfoVC.teamInfo=result;
                teamInfoVC.isScoremanagerBool=YES;
                [self.navigationController pushViewController:teamInfoVC animated:YES];

            }else
            {
                [self showMessage:@"未找到球队！"];
            }
        }
    }];
}
- (void)loadTeamToTransformLineupWithTeam:(Team *)team
{
    [self showLoadingView];
    [TeamEngine getInfoWithTeamId:team.objectId block:^(id result, NSError *error) {
        [self hideLoadingView];
        if (error) {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            if (result)
            {
                UIStoryboard *teamStoryboard = [UIStoryboard storyboardWithName:@"Teams" bundle:[NSBundle mainBundle]];
                UIViewController *viewController = [teamStoryboard instantiateViewControllerWithIdentifier:@"FormationViewController"];
                [viewController setValue:result forKey:@"teamInfo"];
                [self.navigationController pushViewController:viewController animated:YES];
            }else
            {
                [self showMessage:@"未找到球队！"];
            }
            
        }
    }];
}

- (void)callTeamData
{
    [self showLoadingView];
    [BmobCloud callFunctionInBackground:@"teamData" withParameters:@{@"objectId": self.team.objectId} block:^(id object, NSError *error)
     {
         [self hideLoadingView];
         if (!error)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMatchInfoChanged object:nil];
         }else
         {
             BDLog(@"**********Call commentScore err :%@",  error);
         }
     }] ;
}

- (void)callUserGoalAssist
{
    [self showLoadingView];
    [BmobCloud callFunctionInBackground:@"userGoalAssist" withParameters:@{@"objectId": self.userInfo.objectId} block:^(id object, NSError *error)
     {
         [self hideLoadingView];
         if (!error)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMatchInfoChanged object:nil];
         }else
         {
             BDLog(@"**********Call commentScore err :%@",  error);
         }
     }] ;
}

- (void)enableRightButton
{
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:@"提交" forState:UIControlStateNormal];
    [rButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
}

- (void)disenableRightButton
{
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.loadedError)
    {
        return 45.0f;
    }
    if (indexPath.row == 0) {
        return 180.0;
    }else if (indexPath.row == 1) {
        if (self.isOtherTeam) {
            return 0;
        }
        return 148.0;
    }
    {
        return 62.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.dataLoaded) {
        return 0;
    }
    if (self.loadedError)
    {
        return 1;
    }else
    {
        return 2 + MAX([self.homeCourtPlayers count], [self.opponentPlayers count]);
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    if (self.loadedError) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"message_cell" forIndexPath:indexPath];
        UILabel *msgLabel  = (id)[cell.contentView viewWithTag:0xF0];
        msgLabel.text = self.errorMessage;
        return cell;
    }
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"info_cell" forIndexPath:indexPath];
        self.matchDate = (id)[cell.contentView viewWithTag:0xF0];
        self.addressLabel = (id)[cell.contentView viewWithTag:0xF1];
        self.typeLabel = (id)[cell.contentView viewWithTag:0xF2];
        self.homeCourtLabel = (id)[cell.contentView viewWithTag:0xF3];
        self.homeCourtScoreLabel = (id)[cell.contentView viewWithTag:0xF4];
        self.opponentScoreLabel = (id)[cell.contentView viewWithTag:0xF5];
        self.opponentLabel = (id)[cell.contentView viewWithTag:0xF6];
        [self setUpMatchInfo];
        
        UIButton *homeCourtTeamButton = (id)[cell.contentView viewWithTag:0xFA];
        [self embeddedClickEvent:homeCourtTeamButton setBindingRunnable:^{
            [self loadTeamToTransformTeamInfoWithTeam:self.match.home_court];
            
        }];
        UIButton *opponentTeamButton = (id)[cell.contentView viewWithTag:0xFB];
        [self embeddedClickEvent:opponentTeamButton setBindingRunnable:^{
             [self loadTeamToTransformTeamInfoWithTeam:self.match.opponent];
        }];
        UIButton *homeCourtLineupButton = (id)[cell.contentView viewWithTag:0xFC];
        [self embeddedClickEvent:homeCourtLineupButton setBindingRunnable:^{
            [self loadTeamToTransformLineupWithTeam:self.match.home_court];
            
        }];
        UIButton *opponentLineupButton = (id)[cell.contentView viewWithTag:0xFD];
        [self embeddedClickEvent:opponentLineupButton setBindingRunnable:^{
            [self loadTeamToTransformLineupWithTeam:self.match.opponent];
        }];
        
    }else if (indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"self_cell" forIndexPath:indexPath];
        if (self.isOtherTeam)
        {
            cell.hidden = YES;
            return cell;
        }
        cell.hidden = NO;
        UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF0];
        nameLabel.text = self.userInfo.nickname ? self.userInfo.nickname : self.userInfo.username;
        
        UILabel *goalsLabel = (id)[cell.contentView viewWithTag:0xF3];
        self.goalsLabel = goalsLabel;
        goalsLabel.userInteractionEnabled = YES;
        for (UITapGestureRecognizer *tap in goalsLabel.gestureRecognizers) {
            [goalsLabel removeGestureRecognizer:tap];
        }
        
        UITapGestureRecognizer *goalsTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGoalsDoubleTap:)];
        goalsTap2.numberOfTapsRequired = 2;
//        [goalsLabel addGestureRecognizer:goalsTap2];
        
        UITapGestureRecognizer *goalsTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGoalsSingleTap:)];
        goalsTap1.numberOfTapsRequired = 1;
//        [goalsTap1 requireGestureRecognizerToFail:goalsTap2];
        [goalsLabel addGestureRecognizer:goalsTap1];
        if ([self.goalsChange objectForKey:self.playerScoreChangeKey])
        {
            goalsLabel.text = [NSString stringWithFormat:@"%@", [self.goalsChange objectForKey:self.playerScoreChangeKey]];
        }else if (self.playerScore.goals)
        {
            goalsLabel.text =[NSString stringWithFormat:@"%@", self.playerScore.goals];
        }else
        {
            goalsLabel.text = @"0";
        }
        
        UILabel *assistsLabel = (id)[cell.contentView viewWithTag:0xF4];
        self.assistsLabel = assistsLabel;
        assistsLabel.userInteractionEnabled = YES;
        for (UITapGestureRecognizer *tap in assistsLabel.gestureRecognizers) {
            [assistsLabel removeGestureRecognizer:tap];
        }
        
        UITapGestureRecognizer *assistsTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAssistsDoubleTap:)];
        assistsTap2.numberOfTapsRequired = 2;
//        [assistsLabel addGestureRecognizer:assistsTap2];
        
        UITapGestureRecognizer *assistsTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAssistsSingleTap:)];
        assistsTap1.numberOfTapsRequired = 1;
//        [assistsTap1 requireGestureRecognizerToFail:assistsTap2];
        [assistsLabel addGestureRecognizer:assistsTap1];
        
        
        if ([self.assistsChange objectForKey:self.playerScoreChangeKey])
        {
            assistsLabel.text = [NSString stringWithFormat:@"%@", [self.assistsChange objectForKey:self.playerScoreChangeKey]];
        }else if (self.playerScore.assists)
        {
            assistsLabel.text =[NSString stringWithFormat:@"%@", self.playerScore.assists];
        }else
        {
            assistsLabel.text = @"0";
        }
        
        UILabel *avgLabel = (id)[cell.contentView viewWithTag:0xF5];
        avgLabel.text = @"0";
        if (self.playerScore.avg)
        {
            avgLabel.text = [NSString stringWithFormat:@"%.1f", [self.playerScore.avg floatValue]];
        }
        avgLabel.userInteractionEnabled = YES;
        for (UITapGestureRecognizer *tap in avgLabel.gestureRecognizers) {
            [avgLabel removeGestureRecognizer:tap];
        }
        [ViewUtil addSingleTapGestureForView:avgLabel target:self action:@selector(onAvgSingleTap:)];
        
        self.debutButton = (id)[cell.contentView viewWithTag:0xF6];
        self.debutButton.layer.cornerRadius = 6.0;
        
        if (self.playerScore || [self.goalsChange objectForKey:self.playerScoreChangeKey] || [self.assistsChange objectForKey:self.playerScoreChangeKey]) {
            
            self.debutButton.selected = YES;
            
            
            if (self.match.isVerify)
            {
                self.shareButton.hidden=NO;

            }
            
        }
//        self.debutButton.selected = YES;
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"player_cell" forIndexPath:indexPath];
        NSInteger index = [indexPath row] - 2;
        for (int i = 0 ; i < 2; i ++)
        {
            UIView *contentView = [cell.contentView viewWithTag:(0xF0 + i)];
            PlayerScore *playerScore = nil;
            if (i == 0)
            {
                if (index < [self.homeCourtPlayers count]) {
                    playerScore = [self.homeCourtPlayers objectAtIndex:index];
                }
                
            }else
            {
                if (index < [self.opponentPlayers count]) {
                    playerScore = [self.opponentPlayers objectAtIndex:index];
                }
                
            }
            if (playerScore)
            {
                contentView.hidden = NO;
                UILabel *goalsLabel = (id)[contentView viewWithTag:0xF5];
                NSInteger goals = [playerScore.goals integerValue];
                if ([self.goalsChange objectForKey:playerScore.objectId]) {
                    goals = [[self.goalsChange objectForKey:playerScore.objectId] integerValue];
                }
                goalsLabel.text = [NSString stringWithFormat:@"%ld", (long)goals];
                UILabel *assistsLabel = (id)[contentView viewWithTag:0xF6];
                NSInteger assists = [playerScore.assists integerValue];
                if ([self.assistsChange objectForKey:playerScore.objectId]) {
                    assists = [[self.assistsChange objectForKey:playerScore.objectId] integerValue];
                }
                assistsLabel.text = [NSString stringWithFormat:@"%ld", (long)assists];
                UILabel *nameLabel = (id)[contentView viewWithTag:0XF7];
                nameLabel.text = playerScore.player.nickname ? playerScore.player.nickname : playerScore.player.username;
                UILabel *avgLabel = (id)[contentView viewWithTag:0XF8];
                avgLabel.text = [NSString stringWithFormat:@"%.1f", [playerScore.avg floatValue]];
                avgLabel.userInteractionEnabled = YES;
                [ViewUtil addSingleTapGestureForView:avgLabel target:self action:@selector(onEmbeddedClick:)];
                [self embeddedClickEvent:avgLabel setBindingRunnable:^
                 {
                     [self performSegueWithIdentifier:@"push_comment" sender:@[playerScore, @(i == self.editType - 1)]];
                 }];
                UIButton *controll = (id)[contentView viewWithTag:0XF9];
                [ViewUtil addSingleTapGestureForView:controll target:self action:@selector(onEmbeddedClick:)];
                [controll addTarget:self action:@selector(onEmbeddedClick:) forControlEvents:UIControlEventTouchUpInside];
                [self embeddedClickEvent:controll setBindingRunnable:^
                 {
                     if (i == self.editType - 1 && [self.team.captain.objectId isEqualToString:[BmobUser getCurrentUser].objectId])
                     {
                         self.settingType = PickerViewSettingTypePlayerScore;
                         self.valuePicker.hidden = NO;
                         [self.valuePicker reloadAllComponents];
                         
                         [self.valuePicker selectRow:goals inComponent:0 animated:YES];
                         [self.valuePicker selectRow:assists inComponent:2 animated:YES];
                         self.settingPlayerScore = playerScore;
                         [self showPopToolView];
                     }
                 }];
            }else
            {
                contentView.hidden = YES;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return component == 1 ? 1 : 50;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 1) {
        return self.settingType == PickerViewSettingTypeMatchScore ? @"-" : @":";
    }else
    {
        return [NSString stringWithFormat:@"%ld", (long)row];
    }
//    return  component == 1 ? @"-" : [NSString stringWithFormat:@"%d", row];
}
#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kScoreManagerSaveTag) {
        if (buttonIndex == 0) {
            [self saveDataInCaptain];
        }
       
    }
}
#pragma mark - Event handler

/**
 *  单击比分时进行修改
 */
-(void)onlySaveGameScore{
    if (self.editType != ScoreManagerEditTypeHomeCourt && self.editType != ScoreManagerEditTypeOpponentCourt) {
        [self showMessage:@"您无编辑比分数据权限！"];
        return ;
    }
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:self.match.objectId];
    BOOL isHomeTeam = [self.team.objectId isEqualToString:self.match.home_court.objectId];
    
    if (isHomeTeam) {
        if (!self.match.score_h || self.match.score_h.length == 0) {
            
        }else if(!self.match.score_h2 || self.match.score_h2.length == 0){
        
        }else if ([self.homeCourtScoreLabel.text intValue] == [self.match.score_h intValue] && [self.opponentScoreLabel.text integerValue] == [self.match.score_h2 intValue]) {
            return;
        }
        [obj setObject:self.homeCourtScoreLabel.text forKey:@"score_h"];
        [obj setObject:self.opponentScoreLabel.text forKey:@"score_h2"];
        
    }else{
        if ([self.homeCourtScoreLabel.text intValue] == [self.match.score_o2 intValue] && [self.opponentScoreLabel.text integerValue] == [self.match.score_o intValue]) {
            return;
        }
        [obj setObject:self.homeCourtScoreLabel.text forKey:@"score_o2"];
        [obj setObject:self.opponentScoreLabel.text forKey:@"score_o"];
    }
    __weak typeof(BmobObject *)weakObj = obj;
    [weakObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            if (isHomeTeam) {
                self.match.score_h = self.homeCourtScoreLabel.text;
                self.match.score_h2= self.opponentScoreLabel.text;
            }else{
                self.match.score_o2 = self.homeCourtScoreLabel.text;
                self.match.score_o= self.opponentScoreLabel.text;
            }
            [self updateOrCreateTeamScore];
        }
    }];
}

-(void)updateOrCreateTeamScore{
    if (self.teamScore)
    {
        BmobObject *teamScore = [BmobObject objectWithoutDatatWithClassName:kTableTeamScore objectId:self.teamScore.objectId];
        
        if ([self.team.objectId isEqualToString: self.match.home_court.objectId])
        {
//            //比分一样就不提交
//            if ([self.homeCourtScoreLabel.text intValue] == [self.teamScore.goals intValue] && [self.opponentScoreLabel.text integerValue] == [self.teamScore.goals_against intValue]) {
//                return;
//            }
            [teamScore setObject:[NSNumber numberWithInteger:[self.homeCourtScoreLabel.text integerValue]] forKey:@"goals"];
            [teamScore setObject:[NSNumber numberWithInteger:[self.opponentScoreLabel.text integerValue]] forKey:@"goals_against"];
        }else if (self.teamScore &&  [self.team.objectId isEqualToString: self.match.opponent.objectId])
        {
//            //比分一样就不提交
//            if ([self.opponentScoreLabel.text intValue] == [self.teamScore.goals intValue] && [self.homeCourtScoreLabel.text integerValue] == [self.teamScore.goals_against intValue]) {
//                return;
//            }
            [teamScore setObject:[NSNumber numberWithInteger:[self.opponentScoreLabel.text integerValue]] forKey:@"goals"];
            [teamScore setObject:[NSNumber numberWithInteger:[self.homeCourtScoreLabel.text integerValue]] forKey:@"goals_against"];
        }
        int goalDifference = [[teamScore objectForKey:@"goals"] intValue] - [[teamScore objectForKey:@"goals_against"] intValue];
        [teamScore setObject:[NSNumber numberWithInt:goalDifference] forKey:@"goal_difference"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference > 0] forKey:@"win"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference == 0] forKey:@"draw"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference < 0] forKey:@"loss"];
        NSInteger score = 0;
        if (goalDifference > 0)
        {
            score = 3;
        }else if (goalDifference == 0)
        {
            score = 1;
        }else
        {
            score = 0;
        }
        [teamScore setObject:[NSNumber numberWithInteger:score] forKey:@"score"];
        //            isSave = YES;
        [self showLoadingView];
        [teamScore updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
         {
             [self hideLoadingView];
             [self loadTeamScoreWithHandler:nil];
         }];
        
    }else
    {
        BmobObject *teamScore = [BmobObject objectWithClassName:kTableTeamScore];
        [teamScore setObject:self.team.name forKey:@"name"];
        if (self.match.league.objectId)
        {
            [teamScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:self.match.league.objectId] forKey:@"league"];
        }
        [teamScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:self.match.objectId] forKey:@"competition"];
        [teamScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.team.objectId] forKey:@"team"];
        if ([self.team.objectId isEqualToString: self.match.home_court.objectId])
        {
            [teamScore setObject:[NSNumber numberWithInteger:[self.homeCourtScoreLabel.text integerValue]] forKey:@"goals"];
            [teamScore setObject:[NSNumber numberWithInteger:[self.opponentScoreLabel.text integerValue]] forKey:@"goals_against"];
        }else if ([self.team.objectId isEqualToString: self.match.opponent.objectId])
        {
            [teamScore setObject:[NSNumber numberWithInteger:[self.opponentScoreLabel.text integerValue]] forKey:@"goals"];
            [teamScore setObject:[NSNumber numberWithInteger:[self.homeCourtScoreLabel.text integerValue]] forKey:@"goals_against"];
        }
        int goalDifference = [[teamScore objectForKey:@"goals"] intValue] - [[teamScore objectForKey:@"goals_against"] intValue];
        [teamScore setObject:[NSNumber numberWithInt:goalDifference] forKey:@"goal_difference"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference > 0] forKey:@"win"];
        [teamScore setObject:[NSNumber numberWithBool:(goalDifference == 0)] forKey:@"draw"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference < 0] forKey:@"loss"];
        NSInteger score = 0;
        if (goalDifference > 0)
        {
            score = 3;
        }else if (goalDifference == 0)
        {
            score = 1;
        }else
        {
            score = 0;
        }
        [teamScore setObject:[NSNumber numberWithInteger:score] forKey:@"score"];
        [self showLoadingView];
        [teamScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            [self hideLoadingView];
            [self loadTeamScoreWithHandler:nil];
        }];
        
    }
}

- (void)saveDataInCaptain
{
    NSArray *playerScoreArray = nil;
    if (self.editType == ScoreManagerEditTypeHomeCourt) {
        playerScoreArray = self.homeCourtPlayers;
    }else if(self.editType == ScoreManagerEditTypeOpponentCourt)
    {
        playerScoreArray= self.opponentPlayers;
    }else
    {
        [self showMessage:@"您无编辑比分数据权限！"];
        return ;
    }
    int countGoals = 0;
    int countAssists = 0;
    for (PlayerScore *playScore in playerScoreArray ) {
        NSString *playerScoreId = playScore.objectId;
        if ([self.goalsChange objectForKey:playerScoreId])
        {
            countGoals += [[self.goalsChange objectForKey:playerScoreId] integerValue];
        }else
        {
            countGoals += [playScore.goals integerValue];
        }
        if ([self.assistsChange objectForKey:playerScoreId]) {
            countAssists += [[self.goalsChange objectForKey:playerScoreId] integerValue];
        }else
        {
            countAssists += [playScore.assists integerValue];
        }
    }
    if (self.playerScore) {
        countGoals += [self.playerScore.goals integerValue];
        countAssists += [self.playerScore.assists integerValue];
    }
    if (self.editType == ScoreManagerEditTypeHomeCourt) {
        if([self.homeCourtScoreLabel.text integerValue] < countGoals || [self.homeCourtScoreLabel.text integerValue] < countAssists)
        {
            [self showMessageText:@"本队进球数小于球员进球总数或助攻总数！"];
            return ;
        }
        
    }else if(self.editType == ScoreManagerEditTypeOpponentCourt)
    {
        if([self.opponentScoreLabel.text integerValue] < countGoals || [self.opponentScoreLabel.text integerValue] < countAssists)
        {
            [self showMessageText:@"本队进球数小于球员进球总数或助攻总数！"];
            return ;
        }
    }
    [self disenableRightButton];
//    NSMutableSet *playerScoreIdUpdateSet = [NSMutableSet setWithCapacity:0];
//    [playerScoreIdUpdateSet addObjectsFromArray:self.goalsChange.allKeys];
//    [playerScoreIdUpdateSet addObjectsFromArray:self.assistsChange.allKeys];
//    [playerScoreIdUpdateSet removeObject:self.playerScoreChangeKey];
    
    __block NSInteger numberOfRequest = [playerScoreArray count] + 2;
    __block BOOL isRequestSuccessful = YES;
    
    for (PlayerScore *playerScore in playerScoreArray)
    {
        NSString *playerScoreId = playerScore.objectId;
        if ([self.goalsChange objectForKey:playerScoreId] && [self.assistsChange objectForKey:playerScoreId])
        {
            numberOfRequest --;
            continue ;
        }
        BmobObject *playerScore = [BmobObject objectWithoutDatatWithClassName:kTablePlayerScore objectId:playerScoreId];
        if ([self.goalsChange objectForKey:playerScoreId])
        {
            [playerScore setObject:[self.goalsChange objectForKey:playerScoreId] forKey:@"goals"];
        }
        if ([self.assistsChange objectForKey:playerScoreId]) {
            [playerScore setObject: [self.assistsChange objectForKey:playerScoreId] forKey:@"assists"];
        }
//        isSave = YES;
        [self showLoadingView];
        [playerScore updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
         {
             numberOfRequest --;
             [self hideLoadingView];
             if (isSuccessful)
             {
             }else
             {
                 isRequestSuccessful = NO;
                 BDLog(@"**********Update player score err :%@",  error);
             }
             if (numberOfRequest <= 0) {
                 [self saveCompleteWithIsRequestSuccessful:isRequestSuccessful];
             }
         }];
    }
    
    if (self.teamScore)
    {
        BmobObject *teamScore = [BmobObject objectWithoutDatatWithClassName:kTableTeamScore objectId:self.teamScore.objectId];
        if ([self.team.objectId isEqualToString: self.match.home_court.objectId])
        {
            [teamScore setObject:[NSNumber numberWithInteger:[self.homeCourtScoreLabel.text integerValue]] forKey:@"goals"];
            [teamScore setObject:[NSNumber numberWithInteger:[self.opponentScoreLabel.text integerValue]] forKey:@"goals_against"];
        }else if (self.teamScore &&  [self.team.objectId isEqualToString: self.match.opponent.objectId])
        {
            [teamScore setObject:[NSNumber numberWithInteger:[self.opponentScoreLabel.text integerValue]] forKey:@"goals"];
            [teamScore setObject:[NSNumber numberWithInteger:[self.homeCourtScoreLabel.text integerValue]] forKey:@"goals_against"];
        }
        int goalDifference = [[teamScore objectForKey:@"goals"] intValue] - [[teamScore objectForKey:@"goals_against"] intValue];
        [teamScore setObject:[NSNumber numberWithInt:goalDifference] forKey:@"goal_difference"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference > 0] forKey:@"win"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference == 0] forKey:@"draw"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference < 0] forKey:@"loss"];
        NSInteger score = 0;
        if (goalDifference > 0)
        {
            score = 3;
        }else if (goalDifference == 0)
        {
            score = 1;
        }else
        {
            score = 0;
        }
        [teamScore setObject:[NSNumber numberWithInteger:score] forKey:@"score"];
        //            isSave = YES;
        [self showLoadingView];
        [teamScore updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
         {
             numberOfRequest --;
             [self hideLoadingView];
             if (isSuccessful)
             {
             }else
             {
                 isRequestSuccessful = NO;
                 BDLog(@"**********Update team score err :%@",  error);
             }
             if (numberOfRequest <= 0) {
                 [self saveCompleteWithIsRequestSuccessful:isRequestSuccessful];
             }
         }];
        
    }else
    {
        BmobObject *teamScore = [BmobObject objectWithClassName:kTableTeamScore];
        [teamScore setObject:self.team.name forKey:@"name"];
        if (self.match.league.objectId)
        {
            [teamScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:self.match.league.objectId] forKey:@"league"];
        }
        [teamScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:self.match.objectId] forKey:@"competition"];
        [teamScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.team.objectId] forKey:@"team"];
        if ([self.team.objectId isEqualToString: self.match.home_court.objectId])
        {
            [teamScore setObject:[NSNumber numberWithInteger:[self.homeCourtScoreLabel.text integerValue]] forKey:@"goals"];
            [teamScore setObject:[NSNumber numberWithInteger:[self.opponentScoreLabel.text integerValue]] forKey:@"goals_against"];
        }else if ([self.team.objectId isEqualToString: self.match.opponent.objectId])
        {
            [teamScore setObject:[NSNumber numberWithInteger:[self.opponentScoreLabel.text integerValue]] forKey:@"goals"];
            [teamScore setObject:[NSNumber numberWithInteger:[self.homeCourtScoreLabel.text integerValue]] forKey:@"goals_against"];
        }
        int goalDifference = [[teamScore objectForKey:@"goals"] intValue] - [[teamScore objectForKey:@"goals_against"] intValue];
        [teamScore setObject:[NSNumber numberWithInt:goalDifference] forKey:@"goal_difference"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference > 0] forKey:@"win"];
        [teamScore setObject:[NSNumber numberWithBool:(goalDifference == 0)] forKey:@"draw"];
        [teamScore setObject:[NSNumber numberWithBool:goalDifference < 0] forKey:@"loss"];
        NSInteger score = 0;
        if (goalDifference > 0)
        {
            score = 3;
        }else if (goalDifference == 0)
        {
            score = 1;
        }else
        {
            score = 0;
        }
        [teamScore setObject:[NSNumber numberWithInteger:score] forKey:@"score"];
        //            isSave = YES;
        [self showLoadingView];
        [teamScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            numberOfRequest --;
            [self hideLoadingView];
            if (isSuccessful)
            {
            }else
            {
                isRequestSuccessful = NO;
                BDLog(@"**********Update team score err :%@",  error);
            }
            if (numberOfRequest <= 0) {
                [self saveCompleteWithIsRequestSuccessful:isRequestSuccessful];
            }
        }];
        
    }
    BmobObject *match = [BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:self.match.objectId];
    if ([self.team.objectId isEqualToString: self.match.home_court.objectId])
    {
        [match setObject:[NSString stringWithFormat:@"%ld", (long)[self.homeCourtScoreLabel.text integerValue]] forKey:@"score_h"];
        [match setObject:[NSString stringWithFormat:@"%ld", (long)[self.opponentScoreLabel.text integerValue]] forKey:@"score_h2"];
    }else
    {
        [match setObject:[NSString stringWithFormat:@"%ld", (long)[self.opponentScoreLabel.text integerValue]] forKey:@"score_o"];
        [match setObject:[NSString stringWithFormat:@"%ld", (long)[self.homeCourtScoreLabel.text integerValue]] forKey:@"score_o2"];
    }
    [self showLoadingView];
    [match updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        numberOfRequest --;
        [self hideLoadingView];
        if (isSuccessful)
        {
        }else
        {
            isRequestSuccessful = NO;
            BDLog(@"**********Update tournament score err :%@",  error);
        }
        if (numberOfRequest <= 0) {
            [self saveCompleteWithIsRequestSuccessful:isRequestSuccessful];
        }
    }];
}

- (void)saveCompleteWithIsRequestSuccessful:(BOOL) isRequestSuccessful
{
    if (isRequestSuccessful)
    {
        [self showLoadingView];
        __weak typeof(self)weakSelf = self;
        [BmobCloud callFunctionInBackground:@"authTournament" withParameters:@{@"objectId": self.match.objectId} block:^(id object, NSError *error)
         {
             __strong typeof(self)strongSelf = weakSelf;
             if (error)
             {
                 [strongSelf showMessage:@"提交失败，请重试！"];
             }else
             {
                 BOOL isVerify = ![[NSString stringWithFormat:@"%@", object] isEqualToString:@"0"];
                 if (isVerify) {
                     [strongSelf showMessage:@"认证成功"];
                 }else
                 {
                     [strongSelf showMessage:@"提交成功"];
                 }
                 
                 strongSelf.dataLoaded = NO;
                 strongSelf.loadedError = NO;
                 strongSelf.goalsChange = [NSMutableDictionary dictionaryWithCapacity:0];
                 strongSelf.assistsChange = [NSMutableDictionary dictionaryWithCapacity:0];
                 strongSelf.playerScoreChangeKey = OwnGoalsAssistsChangeKey;
                 [strongSelf.refreshControl beginRefreshing];
                 [strongSelf reloadMatchDataWithHandler:^{
                     [strongSelf hideLoadingView];
                 }];
                 
                 
                 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                 [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
                 [formatter setDateFormat:@"MM月dd日"];
                 NSString *timeString = [formatter stringFromDate:self.match.event_date];
                 
                 if (isVerify) {
                     NSString *content = [NSString stringWithFormat:@"%@%@与%@的比赛结果已认证",strongSelf.match.home_court.name,timeString,strongSelf.match.opponent.name ];
                     NSString *homeTargetId  = [NSString stringWithFormat:@"%@&%@", strongSelf.match.objectId, strongSelf.match.home_court.objectId];
                     NSString *oppentTargetId = [NSString stringWithFormat:@"%@&%@", strongSelf.match.objectId, strongSelf.match.opponent.objectId];
                     ;
                     //发送给主队
                     [strongSelf pushNoticeMatchResult:YES
                                               content:content
                                              targetId:homeTargetId
                                                teamId:strongSelf.match.home_court.objectId
                                              username:nil
                                          isTeamNotice:YES];
                     //发送给客队
                     [strongSelf pushNoticeMatchResult:YES
                                               content:content
                                              targetId:oppentTargetId
                                                teamId:strongSelf.match.opponent.objectId
                                              username:nil
                                          isTeamNotice:YES];
                 }else{
                     NSString *content = [NSString stringWithFormat:@"%@在%@与%@的比赛结果未认证",strongSelf.match.home_court.name,timeString,strongSelf.match.opponent.name ];
                     NSString *homeTargetId  = [NSString stringWithFormat:@"%@&%@", strongSelf.match.objectId, strongSelf.match.home_court.objectId];
                     NSString *oppentTargetId = [NSString stringWithFormat:@"%@&%@", strongSelf.match.objectId, strongSelf.match.opponent.objectId];
                     NSString *homeTeamCaptainName = [strongSelf.match.home_court.captain.username copy];
                     NSString *oppentTeamCaptainName = [strongSelf.match.opponent.captain.username copy];
                     //发送给主队队长
                     [strongSelf pushNoticeMatchResult:NO
                                               content:content
                                              targetId:homeTargetId
                                                teamId:nil
                                              username:homeTeamCaptainName
                                          isTeamNotice:NO];
                     //发送给客队队长
                     [strongSelf pushNoticeMatchResult:NO
                                               content:content
                                              targetId:oppentTargetId
                                                teamId:nil
                                              username:oppentTeamCaptainName
                                          isTeamNotice:NO];
                 }
                 
                 [self callTeamData];
                 [self callUserGoalAssist];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMatchInfoChanged object:nil];
//                 [self pushNoticeToOtherTeamCaptain];
                 [self pushNoticeToSelfTeamMembers];
             }
             
         }] ;
    }else
    {
        [self showMessage:@"提交失败，请重试！"];
    }
    
}

-(void)pushNoticeMatchResult:(BOOL)isVerify
                     content:(NSString *)content1
                    targetId:(NSString *)targetId
                      teamId:(NSString *)teamId
                    username:(NSString *)username
                isTeamNotice:(BOOL)isTeamNotice{
    Notice *msg        = [[Notice alloc] init];
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    NSString *content  = content1;
    if (isVerify) {
    msg.subtype        = NoticeSubtypeMatchReportSuccess;
    }else{
    msg.subtype        = NoticeSubtypeMatchReportFail;
    }
    msg.targetId       = targetId;
    msg.aps            = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time           = [[NSDate date] timeIntervalSince1970];
    msg.belongId       = selfUser.username;
    msg.title          = self.team.name;
    msg.type           = NoticeTypeTeam;
    
    if (isTeamNotice) {
        [[NoticeManager sharedManager] pushNotice:msg toTeam:teamId];
    }else{
        [[NoticeManager sharedManager] pushNotice:msg toUsername:username];
    }
}

-(void)pushNoticeToSelfTeamMembers{
    
    Team *otherTeam = nil;
    if ([self.match.opponent.objectId isEqualToString:self.team.objectId]) {
        otherTeam = self.match.home_court;
    }else
    {
        otherTeam = self.match.opponent;
    }
    
    
    Notice *msg = [[Notice alloc] init];
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    
    //                 NSString *content = [NSString stringWithFormat:@"您最近的一场比赛报告已更新，比赛结果认证成功"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [formatter setDateFormat:@"MM月dd日"];
    NSString *timeString = [formatter stringFromDate:self.match.event_date];
    
    NSString *content = [NSString stringWithFormat:@"%@与球队%@的比赛报告已生成",timeString,otherTeam.name ];
    
    msg.targetId = [NSString stringWithFormat:@"%@&%@", self.match.objectId, self.team.objectId];/*@"b166a2f269"*/
    
    
    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.title = self.team.name;
    //    msg.content = content;
    msg.type = NoticeTypeTeam;
    msg.subtype = NoticeSubtypeMatchReport;//NoticeSubtypeMatchReportOtherFeed;
    [[NoticeManager sharedManager] pushNotice:msg toTeam:self.team.objectId];
}

- (void)pushNoticeToOtherTeamCaptain
{
    Team *otherTeam = nil;
    if ([self.match.opponent.objectId isEqualToString:self.team.objectId]) {
        otherTeam = self.match.home_court;
    }else
    {
        otherTeam = self.match.opponent;
    }
    if (otherTeam && otherTeam.captain && otherTeam.captain.username) {
        Notice *msg = [[Notice alloc] init];
        UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
        NSString *matchDateText = [NSString stringWithFormat:@"%@", [DateUtil formatedDate:self.match.event_date byDateFormat:@"MM月dd日"]];
        NSString *content = [NSString stringWithFormat:@"%@球队队长更新了%@的比赛比分，%@-%@", self.team.name, matchDateText, self.homeCourtScoreLabel.text, self.opponentScoreLabel.text];
        msg.subtype = NoticeSubtypeMatchReportOtherFeed;
        msg.targetId = [NSString stringWithFormat:@"%@&%@", self.match.objectId, otherTeam.objectId];/*@"b166a2f269"*/
        msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
        msg.time = [[NSDate date] timeIntervalSince1970];
        msg.belongId = selfUser.username;
        msg.title = otherTeam.name;
        //    msg.content = content;
        msg.type = NoticeTypeTeam;
        [[NoticeManager sharedManager] pushNotice:msg toUsername:otherTeam.captain.username];
    }
    
}

- (void)onSave:(id)sender
{
    if (!self.canEdit) {
        return ;
    }
    if (!self.dataLoaded)
    {
        [self showMessage:@"初始数据未加载完毕！"];
        return;
    }
    
    if (![self isTeamCaptain]) {
        return ;
    }

    
//    if (self.teamScore) {
//        [self saveDataInCaptain];
//    }else
//    {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"队长提交数据后，其他球员将无法上传比赛数据，不再等一等吗？" delegate:self cancelButtonTitle:@"再等等" destructiveButtonTitle:nil otherButtonTitles:@"提交", nil];
        
    [actionSheet setTag:kScoreManagerSaveTag];
    [actionSheet showInView:self.view];
//    }
    
//    if (!self.playerScore)
//    {
//        if (self.debutButton.selected)
//        {
//            numberOfRequest ++;
//            BmobObject *playerScore = [BmobObject objectWithClassName:kTablePlayerScore];
//            [playerScore setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.userInfo.objectId] forKey:@"player"];
//            if (self.match.league.objectId)
//            {
//                [playerScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:self.match.league.objectId] forKey:@"league"];
//            }
//            [playerScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:self.match.objectId] forKey:@"competition"];
//            [playerScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.team.objectId] forKey:@"team"];
//            [playerScore setObject:@(0) forKey:@"avg"];
//            
//            [playerScore setObject:[self.goalsChange objectForKey:self.playerScoreChangeKey]? [self.goalsChange objectForKey:self.playerScoreChangeKey]: @(0) forKey:@"goals"];
//            [playerScore setObject:[self.assistsChange objectForKey:self.playerScoreChangeKey]? [self.assistsChange objectForKey:self.playerScoreChangeKey] : @(0) forKey:@"assists"];
//            isSave = YES;
//            [self showLoadingView];
//            [playerScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
//             {
//                 [self hideLoadingView];
//                 numberOfRequest --;
//                 if (isSuccessful)
//                 {
//                 }else
//                 {
//                     isRequestSuccessful = NO;
//                     BDLog(@"**********Save player score err :%@",  error);
//                 }
//                 if (numberOfRequest <= 0) {
//                     [self saveCompleteWithIsRequestSuccessful:isRequestSuccessful];
//                 }
//             }];
//        }
//    }
   
}

- (void)goBack
{
    if ([self.navigationController.viewControllers count] > 1) {
        
        [super goBack];
    }else
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)onGoalsSingleTap:(UITapGestureRecognizer *)sender
{
    
    if (!self.canEdit) {
        return ;
    }
    if (self.teamScore && ![self isTeamCaptain]) {
        [self showMessageText:@"队长已经提交比赛分数了，记得下次早点来记录哦！"];
        return ;
    }
//    self.valuePicker.hidden = NO;
//    self.settingType = PickerViewSettingTypeMyPlayerScore;
//    [self.valuePicker reloadAllComponents];
//    [self.valuePicker selectRow:[self.goalsLabel.text integerValue] inComponent:0 animated:YES];
//    [self.valuePicker selectRow:[self.assistsLabel.text integerValue] inComponent:2 animated:YES];
//    [self showPopToolView];
    PickerViewController *picker = [PickerViewController pickerViewController];
    picker.userInfo = self.goalsLabel;
    [picker showInView:self.view parentViewController:self delegate:self];
    [picker.pickerView reloadAllComponents];
    [picker.pickerView selectRow:[self.goalsLabel.text integerValue] inComponent:0 animated:NO];
    return ;
//    self.debutButton.selected = YES;
//    BDLog(@"UITapGestureRecognizer count %d", [sender numberOfTapsRequired]);
    NSNumber *num = @(0);
    if ([self.goalsChange objectForKey:self.playerScoreChangeKey]) {
        num = [NSNumber numberWithInteger:[[self.goalsChange objectForKey:self.playerScoreChangeKey] integerValue] + 1];
        [self.goalsChange setObject:num forKey:self.playerScoreChangeKey];
    }else
    {
        num = [NSNumber numberWithInteger:self.playerScore.goals ? [self.playerScore.goals integerValue] + 1 : 1];
        [self.goalsChange setObject:num forKey:self.playerScoreChangeKey];
    }
    self.goalsLabel.text = [NSString stringWithFormat:@"%@", num];
    
//    [self onDebut:self.debutButton];
    [self debutWithoutButton];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)onGoalsDoubleTap:(id)sender
{
    if (!self.canEdit) {
        return ;
    }
    if (self.teamScore && ![self isTeamCaptain]) {
        [self showMessageText:@"队长已经提交比赛分数了，记得下次早点来记录哦！"];
        return ;
    }
//     self.debutButton.selected = YES;
//     BDLog(@"UITapGestureRecognizer count %d", [sender numberOfTapsRequired]);
     NSNumber *num = @(0);
    if ([self.goalsChange objectForKey:self.playerScoreChangeKey])
    {
        NSInteger value ;
        if ([[self.goalsChange objectForKey:self.playerScoreChangeKey] intValue] <= 0) {
            value = 0;
        }else
        {
            value = [[self.goalsChange objectForKey:self.playerScoreChangeKey] integerValue] - 1;
        }
        num = [NSNumber numberWithInteger:value];
        [self.goalsChange setObject:num forKey:self.playerScoreChangeKey];
        
    }else
    {
        NSInteger value;
        if (!self.playerScore.goals || [self.playerScore.goals intValue] <= 0) {
            value = 0;
        }else
        {
            value = [self.playerScore.goals integerValue] - 1;
        }
        
        num = [NSNumber numberWithInteger:value];
        [self.goalsChange setObject:num forKey:self.playerScoreChangeKey];
    }
    self.goalsLabel.text = [NSString stringWithFormat:@"%@", num];
    if (self.playerScore)
    {
//        [self onDebut:self.debutButton];
        [self debutWithoutButton];
    }
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)onAssistsSingleTap:(UITapGestureRecognizer *)sender
{
    if (!self.canEdit) {
        return ;
    }
    if (self.teamScore && ![self isTeamCaptain]) {
        [self showMessageText:@"队长已经提交比赛分数了，记得下次早点来记录哦！"];
        return ;
    }
//    self.valuePicker.hidden = NO;
//    self.settingType = PickerViewSettingTypeMyPlayerScore;
//    [self.valuePicker reloadAllComponents];
//    [self.valuePicker selectRow:[self.goalsLabel.text integerValue] inComponent:0 animated:YES];
//    [self.valuePicker selectRow:[self.assistsLabel.text integerValue] inComponent:2 animated:YES];
//    [self showPopToolView];
    PickerViewController *picker = [PickerViewController pickerViewController];
    picker.userInfo = self.assistsLabel;
    [picker showInView:self.view parentViewController:self delegate:self];
    [picker.pickerView reloadAllComponents];
    [picker.pickerView selectRow:[self.assistsLabel.text integerValue] inComponent:0 animated:NO];
    return ;
//     self.debutButton.selected = YES;
//    BDLog(@"UITapGestureRecognizer count %d", [sender numberOfTapsRequired]);
     NSNumber *num = @(0);
    if ([self.assistsChange objectForKey:self.playerScoreChangeKey]) {
        num = [NSNumber numberWithInteger:[[self.assistsChange objectForKey:self.playerScoreChangeKey] integerValue] + 1];
        [self.assistsChange setObject:num forKey:self.playerScoreChangeKey];
    }else
    {
        num = [NSNumber numberWithInteger:self.playerScore.assists ? [self.playerScore.assists integerValue] + 1 : 1];
        [self.assistsChange setObject:num forKey:self.playerScoreChangeKey];
    }
    self.assistsLabel.text = [NSString stringWithFormat:@"%@", num];
//    [self onDebut:self.debutButton];
    
    [self debutWithoutButton];
    
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)onAssistsDoubleTap:(id)sender
{
    if (!self.canEdit) {
        return ;
    }
    if (self.teamScore && ![self isTeamCaptain]) {
        [self showMessageText:@"队长已经提交比赛分数了，记得下次早点来记录哦！"];
        return ;
    }
//    self.debutButton.selected = YES;
//    BDLog(@"UITapGestureRecognizer count %d", [sender numberOfTapsRequired]);
     NSNumber *num = @(0);
    if ([self.assistsChange objectForKey:self.playerScoreChangeKey])
    {
        NSInteger value ;
        if ([[self.assistsChange objectForKey:self.playerScoreChangeKey] intValue] <= 0) {
            value = 0;
        }else
        {
            value = [[self.assistsChange objectForKey:self.playerScoreChangeKey] integerValue] - 1;
        }
        num = [NSNumber numberWithInteger:value];
        [self.assistsChange setObject:num forKey:self.playerScoreChangeKey];
        
    }else
    {
        NSInteger value;
        if (!self.playerScore.assists || [self.playerScore.assists intValue] <= 0) {
            value = 0;
        }else
        {
            value = [self.playerScore.assists integerValue] - 1;
        }
        
        num = [NSNumber numberWithInteger:value];
        [self.assistsChange setObject:num forKey:self.playerScoreChangeKey];
    }
     self.assistsLabel.text = [NSString stringWithFormat:@"%@", num];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (self.playerScore)
    {
//        [self onDebut:self.debutButton];
        [self debutWithoutButton];
    }
}

- (void)onAvgSingleTap:(UITapGestureRecognizer *)sender
{
    if (!self.canEdit) {
        return ;
    }
    [self performSegueWithIdentifier:@"push_comment" sender:self.userInfo];
}

- (IBAction)onSettingScore:(id)sender
{
    if (!self.canEdit) {
        return ;
    }
    if ([self.team.captain.objectId isEqualToString:self.userInfo.objectId])
    {
        self.settingType = PickerViewSettingTypeMatchScore;
        self.valuePicker.hidden = NO;
        [self.valuePicker reloadAllComponents];
        
        [self.valuePicker selectRow:[self.homeCourtScoreLabel.text integerValue] inComponent:0 animated:YES];
        [self.valuePicker selectRow:[self.opponentScoreLabel.text integerValue] inComponent:2 animated:YES];
        [self showPopToolView];
    }
}

- (IBAction)onPickerCancel:(id)sender
{
    [self hidePopToolView];
}

- (IBAction)onPickerSure:(id)sender
{
    if(self.settingType == PickerViewSettingTypeMatchScore)
    {
        self.homeCourtScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.valuePicker selectedRowInComponent:0]];
        self.opponentScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.valuePicker selectedRowInComponent:2]];
        self.hasChanged = YES;
        
        [self onlySaveGameScore];
        
    }else if (self.settingType == PickerViewSettingTypeMyPlayerScore)
    {
        self.goalsLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.valuePicker selectedRowInComponent:0]];
        self.assistsLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.valuePicker selectedRowInComponent:2]];
//        [self onDebut:self.debutButton];
        [self debutWithoutButton];
        
    }else
    {
        self.hasChanged = YES;
        if(self.settingPlayerScore)
        {
            if ([self.valuePicker selectedRowInComponent:0] == [self.settingPlayerScore.goals integerValue])
            {
                [self.goalsChange removeObjectForKey:self.settingPlayerScore.objectId];
            }else
            {
                [self.goalsChange setObject:[NSNumber numberWithInteger:[self.valuePicker selectedRowInComponent:0]] forKey:self.settingPlayerScore.objectId];
            }
            if ([self.valuePicker selectedRowInComponent:2] == [self.settingPlayerScore.assists integerValue])
            {
                [self.assistsChange removeObjectForKey:self.settingPlayerScore.objectId];
            }else
            {
                [self.assistsChange setObject:[NSNumber numberWithInteger:[self.valuePicker selectedRowInComponent:2]] forKey:self.settingPlayerScore.objectId];
            }
            NSInteger index = [self.homeCourtPlayers indexOfObject:self.settingPlayerScore];
            if (index == NSNotFound) {
                index = [self.opponentPlayers indexOfObject:self.settingPlayerScore];
            }
            if (index != NSNotFound && index < MAX([self.homeCourtPlayers count], [self.opponentPlayers count])) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index + 2 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }
    }
    
    [self hidePopToolView];
}




- (IBAction)onDebut:(UIButton *)sender
{
    if (!self.canEdit) {
        return ;
    }
    
    if (self.teamScore && ![self isTeamCaptain]) {
        [self showMessageText:@"队长已经提交比赛分数了，记得下次早点来记录哦！"];
        return ;
    }
   
    
//    if ([self.goalsLabel.text integerValue] != 0 || [self.assistsLabel.text integerValue] != 0 ) {
//        return ;
//    }
    
//    NSInteger index = [self.homeCourtPlayers indexOfObject:self.playerScore];
//    
//    if (index == NSNotFound) {
//        index = [self.opponentPlayers indexOfObject:self.playerScore];
//    }
//    if (index != NSNotFound) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index + 2 inSection:0];
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
    

    sender.selected = !sender.selected;
    
    [self saveOrUpdatePlayerScore:sender];
}


-(void)debutWithoutButton{
    
    if (!self.canEdit) {
        return ;
    }
    
    if (self.teamScore && ![self isTeamCaptain]) {
        [self showMessageText:@"队长已经提交比赛分数了，记得下次早点来记录哦！"];
        return ;
    }
    
    self.debutButton.selected = YES;
    [self saveOrUpdatePlayerScore:self.debutButton];
}



-(void)saveOrUpdatePlayerScore:(UIButton *)sender{
    if (self.playerScore) {
        NSString *playerScoreId = self.playerScoreChangeKey;
        BmobObject *playerScore = [BmobObject objectWithoutDatatWithClassName:kTablePlayerScore objectId:playerScoreId];
        //        if ([self.goalsChange objectForKey:playerScoreId])
        //        {
        //            [playerScore setObject:[self.goalsChange objectForKey:playerScoreId] forKey:@"goals"];
        //        }
        //        if ([self.assistsChange objectForKey:playerScoreId]) {
        //            [playerScore setObject: [self.assistsChange objectForKey:playerScoreId] forKey:@"assists"];
        //        }
        //        [self showLoadingView];
    
        if (!sender.selected) {
            if ([self.goalsLabel.text integerValue] != 0 || [self.assistsLabel.text integerValue] != 0 ) {
                [self showMessageText:@"进球数或者助攻数不为0"];
                sender.selected = YES;
                return ;
            }
            [self showLoadingView];
//            [playerScore deleteForKey:@"player"];
//            [playerScore deleteForKey:@"avg"];
//            [playerScore deleteForKey:@"goals"];
//            [playerScore deleteForKey:@"assists"];
            [playerScore deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                [self hideLoadingView];
                if (isSuccessful)
                {
                    self.playerScore.goals = @0;
                    self.playerScore.assists = @0;
                    self.playerScore.avg = @0;
                    
                    [self.tableView reloadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMatchInfoChanged object:nil];
                    [self callUserGoalAssist];
                    self.playerScore = nil;
//                    self.goalsLabel.text = @"0";
//                    self.assistsLabel.text = @"0";
//                    UILabel *avgLabel = (id)[cell.contentView viewWithTag:0xF5];
//                    avgLabel.text = @"0";
                }else
                {
                    BDLog(@"**********Update player score err :%@",  error);
                    [self showMessage:@"数据保存出错！"];
                }
            }];
        }else{
            if ([self.goalsLabel.text integerValue] == [self.playerScore.goals integerValue] && [self.assistsLabel.text integerValue] == [self.playerScore.assists integerValue] ) {
                return ;
            }
            [playerScore setObject:[NSNumber numberWithInteger:[self.goalsLabel.text integerValue]] forKey:@"goals"];
            [playerScore setObject:[NSNumber numberWithInteger:[self.assistsLabel.text integerValue]] forKey:@"assists"];
            
            if ([self.goalsLabel.text integerValue] == 0 && [self.assistsLabel.text integerValue] == 0) {
                [playerScore setObject:@(0) forKey:@"avg"];
            }
            
            [self showLoadingView];
            [playerScore updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
             {
                 [self hideLoadingView];
                 if (isSuccessful)
                 {
                     self.playerScore.goals = [playerScore objectForKey:@"goals"];
                     self.playerScore.assists = [playerScore objectForKey:@"assists"];
                     [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMatchInfoChanged object:nil];
                     [self callUserGoalAssist];
                 }else
                 {
                     BDLog(@"**********Update player score err :%@",  error);
                     [self showMessage:@"数据保存出错！"];
                 }
                 
             }];
        }
        
    }else
    {
        if (!sender.selected) {
            return;
        }
        BmobObject *playerScore = [BmobObject objectWithClassName:kTablePlayerScore];
        [playerScore setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.userInfo.objectId] forKey:@"player"];
        if (self.match.league.objectId)
        {
            [playerScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableLeague objectId:self.match.league.objectId] forKey:@"league"];
        }
        [playerScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableTournament objectId:self.match.objectId] forKey:@"competition"];
        [playerScore setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.team.objectId] forKey:@"team"];
        
        if ([self.goalsLabel.text integerValue] == 0 && [self.assistsLabel.text integerValue] == 0) {
            [playerScore setObject:@(0) forKey:@"avg"];
        }else{
            [playerScore setObject:@(6) forKey:@"avg"];
        }
        
        
        
        //        [playerScore setObject:[self.goalsChange objectForKey:self.playerScoreChangeKey]? [self.goalsChange objectForKey:self.playerScoreChangeKey]: @(0) forKey:@"goals"];
        //        [playerScore setObject:[self.assistsChange objectForKey:self.playerScoreChangeKey]? [self.assistsChange objectForKey:self.playerScoreChangeKey] : @(0) forKey:@"assists"];
        [playerScore setObject:[NSNumber numberWithInteger:[self.goalsLabel.text integerValue]] forKey:@"goals"];
        [playerScore setObject:[NSNumber numberWithInteger:[self.assistsLabel.text integerValue]] forKey:@"assists"];
        [self showLoadingView];
        [playerScore saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
         {
             if (isSuccessful)
             {
                 [self callUserGoalAssist];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kObserverMatchInfoChanged object:nil];
                 [self loadPalyersScoreWithHandler:^{
                     [self hideLoadingView];
                     
                 }];
                 
             }else
             {
                 BDLog(@"**********Save player score err :%@",  error);
             }
         }];
    }
}







#pragma mark - shareAction

- (IBAction)shareButtonClick:(id)sender
{
    
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
    
    self.shareTitle=@"个人比赛数据";
    self.shareUrl=[NSString stringWithFormat:@"http://tq.codenow.cn/share/PersonGameData?player=%@&game=%@",[[BmobUser getCurrentUser] objectId],self.match.objectId];
    self.shareContent=[NSString stringWithFormat:@"每一次进步，都是辛勤的付出，我在%@VS%@比赛中进球%@次，助攻%@次，大家对我的综合评分是%@分，谢谢鼓励！ 链接：%@", self.match.home_court.name, self.match.opponent.name,self.playerScore.goals,self.playerScore.assists,self.playerScore.avg,self.shareUrl];
    
    
    
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    
    id<ISSContent> publishContent = [ShareSDK content:self.shareContent
                                       defaultContent:nil
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:self.shareTitle
                                                  url:self.shareUrl
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    //    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
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
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:type
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     BDLog(@"发表成功");
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     
                                     BDLog(@"error code == %ld, error code == %@",(long)[error errorCode],[error errorDescription]);
                                 }
                             }];
    
    
}





@end

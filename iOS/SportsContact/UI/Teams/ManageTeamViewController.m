

//
//  ManageTeamViewController.m
//  SportsContact
//
//  Created by Nero on 7/22/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "ManageTeamViewController.h"
#import "ViewUtil.h"
#import "DataDef.h"
#import "LocationInfoManager.h"
#import "TeamEngine.h"
#import <UIImageView+WebCache.h>
#import "DateUtil.h"
#import "exploitsTableViewCell.h"
#import "ScheduleTableViewCell.h"
#import "FormationTableViewCell.h"
#import "CompetitionInfoTableViewCell.h"
#import "NoticeManager.h"

#import "TeamsViewController.h"
#import "CreateTeamViewController.h"

#import "ScoreboardViewController.h"
#import "MatchDetailViewController.h"

#import "CHTumblrMenuView.h"
#import <ShareSDK/ShareSDK.h>


#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"

#define TITLE @"测试_Title"
#define CONTENT @"测试_Content"
#define URL @"http://www.baidu.com"



@interface ManageTeamViewController ()

//@property (nonatomic,strong) Team *teamInfo;
//@property (nonatomic,strong) NSString *teamName;

@property (weak, nonatomic) IBOutlet UIImageView *teamAvatorImage;
@property (weak, nonatomic) IBOutlet UILabel *teamMemberCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *teamAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *teamDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *teamCaptain;


@property (weak, nonatomic) IBOutlet UITableView *teamTableview;
@property (weak, nonatomic) IBOutlet UIScrollView *teamDataScroll;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;


@property (weak, nonatomic) IBOutlet UIButton *introButton;
@property (weak, nonatomic) IBOutlet UIButton *applyForJoinButton;
@property (strong, nonatomic) UIButton *rightBtn;
@property (strong,nonatomic) NSString *isInTheTeamBool;


//分数
@property (weak, nonatomic) IBOutlet UILabel *joinNumberLabel;//参数数
@property (weak, nonatomic) IBOutlet UILabel *winNumber;//胜
@property (weak, nonatomic) IBOutlet UILabel *lostNumber;//负
@property (weak, nonatomic) IBOutlet UILabel *tieNumber;//平
@property (weak, nonatomic) IBOutlet UILabel *goalNumber;//进球
@property (weak, nonatomic) IBOutlet UILabel *fumbleNumber;//失球
@property (weak, nonatomic) IBOutlet UILabel *onlyWinNumber;//净胜球


@property (weak, nonatomic) IBOutlet UILabel *totalNumber1;
@property (weak, nonatomic) IBOutlet UILabel *totalNumber2;
@property (weak, nonatomic) IBOutlet UILabel *totalNumber3;
@property (weak, nonatomic) IBOutlet UILabel *totalNumber4;
@property (weak, nonatomic) IBOutlet UILabel *totalNumber5;
@property (weak, nonatomic) IBOutlet UILabel *totalNumber6;
@property (weak, nonatomic) IBOutlet UILabel *totalNumber7;



//settingview
@property (nonatomic) BOOL isSetting;

@property (weak, nonatomic) IBOutlet UIView *settingToolView;
@property (weak, nonatomic) IBOutlet UIView *settingBgView;
@property (weak, nonatomic) IBOutlet UIView *settingOptionView;



@property (weak, nonatomic) IBOutlet UIView *teamInfoView;
@property (weak, nonatomic) IBOutlet UIView *shareTeamView;
@property (weak, nonatomic) IBOutlet UIView *memberMangeView;
@property (weak, nonatomic) IBOutlet UIView *searchTeamView;
@property (weak, nonatomic) IBOutlet UIView *switchTeamView;
@property (weak, nonatomic) IBOutlet UIView *quitTeamView;


//@property (weak, nonatomic) IBOutlet UIView *secondView;
//@property (weak, nonatomic) IBOutlet UIView *thirdView;
//@property (weak, nonatomic) IBOutlet UIView *fourthView;
//@property (weak, nonatomic) IBOutlet UIView *fifthView;




@property (weak, nonatomic) IBOutlet UIButton *changeTeamButton;//创建、切换球队



//team introduce view
@property (nonatomic) BOOL isIntroClicking;
@property (weak, nonatomic) IBOutlet UIView *teamIntroView;
@property (strong, nonatomic) IBOutlet UITextView *introTextview;



@property (strong, nonatomic)  NSString *leagueName;
@property (strong, nonatomic)  NSString *leagueId;



@property (nonatomic, strong) NSArray *teamTournamentArr;
@property (nonatomic, strong) NSMutableArray *exploitsTotalArr;
@property (nonatomic, strong) NSMutableArray *scheduleTotalArr;


@property (nonatomic, assign) BOOL isLineupLoaded;
@property (nonatomic, strong) Lineup *lineup;
//@property (nonatomic, assign) BOOL isFormationCanClickBool;




@property (nonatomic, strong) UIAlertView *captainQuitAlertview;
@property (nonatomic, strong) UIAlertView *memberQuitAlertview;



@property (nonatomic, strong) NSMutableArray *joinTeamArr;




@property (strong, nonatomic)  NSString *shareTitle;
@property (strong, nonatomic)  NSString *shareContent;
@property (strong, nonatomic)  NSString *shareUrl;




@end



@implementation ManageTeamViewController

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
    
    if (self.isCreateteamBool)
    {
        [self hideBackButton];
        
        [self showBackRootButton];
    }
    

    
    

    
    self.rightBtn = [self rightButtonWithImage:[UIImage imageNamed:@"btn_setting"] hightlightedImage:[UIImage imageNamed:@"btn_setting_hl"]];
    [self.rightBtn addTarget:self action:@selector(onTeamSetting:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    
    self.isSetting = NO;
    self.settingToolView.hidden = YES;
    [ViewUtil addSingleTapGestureForView:[self.settingToolView viewWithTag:0xF0] target:self action:@selector(onTeamSetting:)];
    
    

    
    
    
    [self.introButton setBackgroundImage:[UIImage imageNamed:@"TeamManage_btn_.png"] forState:UIControlStateNormal];
    [self.introButton setBackgroundImage:[UIImage imageNamed:@"TeamManage_btn_.png"] forState:UIControlStateHighlighted];
    
    
    [self.introButton addTarget:self action:@selector(introButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.isIntroClicking = NO;
    self.teamIntroView.hidden = YES;
    [ViewUtil addSingleTapGestureForView:[self.teamIntroView viewWithTag:0xF0] target:self action:@selector(hideTeamIntroview)];

    
    
    
    
    [self.teamDataScroll setContentSize:CGSizeMake(640.0, 115.0)];
    self.pageControl.pageIndicatorTintColor=[ViewUtil hexStringToColor:@"e5e5e5"];
    self.pageControl.currentPageIndicatorTintColor=[ViewUtil hexStringToColor:@"f27602"];
    
    
    
    
    
//    [self showLoadingView];
//
//    [self loadTheTeamViewWithHandler:^{
//        
//        [self hideLoadingView];
//        
//    }];
    

    
    
    
    
    //更新球队资料
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTheTeamView) name:kObserverTeamInfoChanged object:nil];
    
    
    self.isLineupLoaded = NO;
    
    
    //下拉刷新
    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.teamTableview];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    


    
    
//    BmobObject *team = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.teamInfo.objectId];
//    //新建relation对象
//    BmobRelation *relation = [BmobRelation relation];
//    //relation添加id为25fb9b4a61的用户
//    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"b4eaf03a7f"]];   //obj 添加关联关系到footballer列中
//    [team addRelation:relation forKey:@"footballer"];
//    //异步更新team的数据
//    [team updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
//     {
//         BDLog(@"error %@",[error description]);
//         
//         
//         
//     }];
    
    
    
    
    
//    //删除关联
//    //表名为Post,id为a1419df47a的BmobObject对象
//    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.teamInfo.objectId];
//    //新建relation对象
//    BmobRelation *relation = [[BmobRelation alloc] init];
//    //relation要移除id为27bb999834的用户
//    [relation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"c65fd9559f"]];
//    //obj 更新关联关系到likes列中
//    [obj addRelation:relation forKey:@"footballer"];
//    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
//        BDLog(@"error %@",[error description]);
//    }];

    
    
    
    
//    //创建阵容
//    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableLineup objectId:@"球队id"];
//    BmobRelation *relation = [[BmobRelation alloc] init];
//    
//    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"球员id"]];
//    [obj addRelation:relation forKey:@"back"];
//    
//    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"球员id"]];
//    [obj addRelation:relation forKey:@"striker"];
//    
//    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"球员id"]];
//    [obj addRelation:relation forKey:@"forward"];
//
//
//    [obj setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.teamInfo.objectId] forKey:@"team"];
//    
//    
//    [obj setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"球员id"] forKey:@"goalkeeper"];
//    
//    //异步更新obj的数据
//    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
//     {
//        BDLog(@"error %@",[error description]);
//        
//    }];
    
    

    
    

   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (IOS7) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    [self getUserJoinedTeamForControllBackButton];
    
    
    [self showLoadingView];
    
    [self loadTheTeamViewWithHandler:^{
        
        [self hideLoadingView];
        
    }];

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideSettingToolView];
    self.isSetting = NO;
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)hidesBottomBarWhenPushed
{
    return NO;
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    
    [self loadTheTeamViewWithHandler:^{
        
        [refreshControl   endRefreshing];
        
    }];
    
    

}



-(void)getUserJoinedTeamForControllBackButton
{
    
    self.joinTeamArr=[[NSMutableArray alloc]init];
    
    //获取当前用户的信息,获取所在球队数量
//    [self showLoadingView];
    
    
    [TeamEngine getTeamsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error){
        
        
//        [self hideLoadingView];

        if (error)
        {
            
            [self showMessage:[Util errorStringWithCode:error.code]];
            
        }
        else
        {
            
            self.joinTeamArr=result;
            
            
            if ([self.joinTeamArr count]==2)
            {
                [self showBackButton];
                
            }
            else if ([self.joinTeamArr count]==1)
            {
                
                if (self.isScoremanagerBool || self.isNearbyAndSearchBool)
                {
                    [self showBackButton];
                }
                else
                {
                    [self hideBackButton];
                }
                
                
                
//                if (self.isNearbyAndSearchBool)
//                {
//                    [self showBackButton];
//                }
//                else
//                {
//                    [self hideBackButton];
//                }
                
            }
            else if ([self.joinTeamArr count]==0)
            {
                
                
            }
            else
            {
                
            }
            
            
            
        }
        
        
        
        
        
    }];
    
    
    
    
    
    
}



- (IBAction)applyForJoinTeamClick:(id)sender
{
    
    //一个人只能加入2支球队
    [self showLoadingView];
    BmobUser *user = [BmobUser getCurrentUser];
    NSString *objectID = user.objectId;//[[BmobUser getCurrentUser] objectId];
    [TeamEngine getJoinedTeamsWithUserId:objectID block:^(id result, NSError *error) {
        
        [self hideLoadingView];
        
        NSMutableArray *array=[[NSMutableArray alloc]initWithArray:result];
        
        if ([array count]<=1)
        {
            UIButton *tmpButton = (UIButton *)sender;
            tmpButton.enabled = NO;
            [tmpButton setTitle:@"已申请" forState:UIControlStateNormal];
             //发送push该队队长
            [self applyPushWithTeam:self.teamInfo];
            
            [self performSelector:@selector(enableJoinTeamButton:) withObject:tmpButton afterDelay:30.0f];
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


-(void)enableJoinTeamButton:(UIButton *)button{
    button.enabled = YES;
    [button setTitle:@"申请入队" forState:UIControlStateNormal];
}

- (IBAction)getShareTeamClick:(id)sender
{
    
    [self hideSettingToolView];
    self.isSetting=NO;

    
    CHTumblrMenuView *menuView = [[CHTumblrMenuView alloc] init];
    [menuView addMenuItemWithTitle:@"短信" andIcon:[UIImage imageNamed:@"message.png"] andSelectedBlock:^{
        
        BDLog(@"短信 selected");
        
        
        [self showShareViewWithType:ShareTypeSMS];
        
//        [self shareBySMSClickHandler:sender];
        
        
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
        
        
//        [self weiboShareClickHandler];
    }];
    
    
    [menuView show];
    
    
    
    
    
    
}

-(void)showShareViewWithType:(ShareType)type
{
    
    
    
    self.shareTitle=@"团队总体数据";
    self.shareUrl=@"http://www.baidu.com";
    self.shareContent=[NSString stringWithFormat:@"团结就是力量,%@的总体表现是:%@",self.teamInfo.name,self.shareUrl];
    
    
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
    
    [ShareSDK shareContent:content
                      type:type
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            BDLog(@"分享成功!");
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
                            
                            
                            BDLog(@"分享失败!******%ld*******%@", (long)[error errorCode], [error errorDescription]);

                            
                        }
                    }];
}



//- (void)weiboShareClickHandler
//{
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
//    
//    //构造分享内容
//    id<ISSContent> publishContent = [ShareSDK content:CONTENT
//                                       defaultContent:@""
//                                                image:[ShareSDK imageWithPath:imagePath]
//                                                title:@"ShareSDK"
//                                                  url:@"http://www.sharesdk.cn"
//                                          description:NSLocalizedString(@"TEXT_TEST_MSG", @"这是一条测试信息")
//                                            mediaType:SSPublishContentMediaTypeNews];
//    
//    [ShareSDK clientShareContent:publishContent
//                            type:ShareTypeSinaWeibo
//                   statusBarTips:YES
//                          result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//                              
//                              if (state == SSPublishContentStateSuccess)
//                              {
//                                  BDLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功!"));
//                              }
//                              else if (state == SSPublishContentStateFail)
//                              {
//                                  BDLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"分享失败!"), [error errorCode], [error errorDescription]);
//                              }
//                          }];
//}



//- (void)shareBySMSClickHandler:(UIButton *)sender
//{
//    //创建分享内容
//    id<ISSContent> publishContent = [ShareSDK content:CONTENT
//                                       defaultContent:@""
//                                                image:nil
//                                                title:nil
//                                                  url:nil
//                                          description:nil
//                                            mediaType:SSPublishContentMediaTypeText];
//    
//    //创建弹出菜单容器
//    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
//    
//    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
//                                                         allowCallback:YES
//                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
//                                                          viewDelegate:nil
//                                               authManagerViewDelegate:nil];
//    
//    //在授权页面中添加关注官方微博
//    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
//                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
//                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
//                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
//                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
//                                    nil]];
//    
//    //显示分享菜单
//    [ShareSDK showShareViewWithType:ShareTypeSMS
//                          container:container
//                            content:publishContent
//                      statusBarTips:YES
//                        authOptions:authOptions
//                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
//                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
//                                                            qqButtonHidden:NO
//                                                     wxSessionButtonHidden:NO
//                                                    wxTimelineButtonHidden:NO
//                                                      showKeyboardOnAppear:NO
//                                                         shareViewDelegate:nil
//                                                       friendsViewDelegate:nil
//                                                     picViewerViewDelegate:nil]
//                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//                                 
//                                 if (state == SSPublishContentStateSuccess)
//                                 {
//                                     BDLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
//                                 }
//                                 else if (state == SSPublishContentStateFail)
//                                 {
//                                     BDLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
//                                 }
//                             }];
//}

- (IBAction)getSwitchTeamClick:(id)sender {
    
    
    [self hideSettingToolView];
    self.isSetting=NO;

    
    //切换球队
    [TeamEngine getSwitchTeamsWithTeamId:self.teamInfo.objectId UserId:[[BmobUser getCurrentUser] objectId]block:^(id result, NSError *error) {
        
        if (!error)
        {
            NSArray *array=[[NSArray alloc]init];
            array=result;
            
            self.teamInfo=nil;
            self.teamInfo= [array firstObject];
            ;
            
            
            BDLog(@"*******%@",self.teamInfo.objectId);
            
            
//            [self loadTheTeamView];
            
            
            [self showLoadingView];
            [self loadTheTeamViewWithHandler:^{
                
                [self hideLoadingView];
                
            }];

            
        }
        
        
    }];

    
    
    
}

- (IBAction)quitTheTeamClick:(id)sender {
    
    
    [self hideSettingToolView];
    self.isSetting=NO;

    
    
    //退出球队，如果是队长，要先更换队长，才可以退出？

    if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
    {
        
        NSString *message=[NSString stringWithFormat:@"你当前为球队%@的队长，退出球队请先到『球队资料』里面更换队长 或者 直接解散球队",self.teamInfo.name];
        self.captainQuitAlertview = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:@"前往更换队长",@"解散球队",nil];
        
        
        [self.captainQuitAlertview show];

        
    }
    else
    {
        
        NSString *message=[NSString stringWithFormat:@"你当前球队为%@，确定退出该球队？",self.teamInfo.name];
        self.memberQuitAlertview = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定",nil];
        
        
        [self.memberQuitAlertview show];

        
    }
    
    
    
    

    
}


#pragma marks -- UIAlertViewDelegate --
//根据被点击按钮的索引处理点击事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BDLog(@"clickButtonAtIndex:%ld",(long)buttonIndex);
    
    
    
    if (alertView == self.captainQuitAlertview)
    {
        
        
        
        
        if (buttonIndex==0)
        {
            
        }
        else if (buttonIndex==1)
        {
            
            
            //前往更改队长选项，跳转到球队资料编辑
            
            
            CreateTeamViewController *currentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateTeamViewController"];
            
            
            currentVC.teamInfo=self.teamInfo;
            currentVC.isCreateteamBoolStr=@"0";
            currentVC.title=@"球队资料编辑";
            
            
            [self.navigationController pushViewController:currentVC animated:YES];
            
            
            
            
        }
        
        else if (buttonIndex==2)
        {
            //删除球队
            
            [self showLoadingView];
            
            [TeamEngine getDeleteTeamsWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error) {
                
                
                [self hideLoadingView];
                
                if (!error)
                {
                    [self showMessage:@"解散球队成功！"];
                    
                    //如果2支球队，就切换到另外的球队，如果没球队，就跳转到『搜索球队』界面
                    [self checkTheJoinTeam];
                    
                    
                }
                else
                {
                    [self showMessage:@"解散球队失败！"];
                }
                
                
                
            }];
            
            
            
            
        }
        
        else
        {
            
        }

        
        
        
        
        
        
        
    }
    else if (alertView == self.memberQuitAlertview)
    {
        
        
        if (buttonIndex==0)
        {
            
        }
        else if (buttonIndex==1)
        {
            
            
            [TeamEngine getQuitTeamsWithTeamId:self.teamInfo.objectId UserId:[[BmobUser getCurrentObject] objectId]block:^(id result, NSError *error) {
                
                BDLog(@"******");
                if (!error)
                {
                    //如果2支球队，就切换到另外的球队，如果没球队，就跳转到『搜索球队』界面
                    
                    [self checkTheJoinTeam];
                    [self quitTeamPushWithTeam:self.teamInfo];
                    
                }
                else
                {
                    
                    
                }
                
                
            }];
            
            
            
        }
        else
        {
            
        }

        
        
        
    }
    else
    {
        
    }
    
    
    
    
    
}



-(void)checkTheJoinTeam
{
    
    //一个人只能加入2支球队
    [self showLoadingView];
    
    [TeamEngine getJoinedTeamsWithUserId:[[BmobUser getCurrentUser] objectId] block:^(id result, NSError *error) {
        
        [self hideLoadingView];
        
        NSMutableArray *array=[[NSMutableArray alloc]initWithArray:result];
        
        if ([array count]==0)
        {
            //跳转到『搜索』界面，Team_searchTeam
            
//            [self performSegueWithIdentifier:@"Team_searchTeam" sender:nil];
            
            
            TeamsViewController *teamSearchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamsViewController"];
            
            teamSearchVC.quitTeamBool=YES;
            
            [self.navigationController pushViewController:teamSearchVC animated:YES];

            
            
        }
        else if ([array count]==1)
        {
            
            [self getSwitchTeamClick:nil];
            
            
        }
        else
        {
            
        }
        
        
        
        
        
    }];

    
}



-(void)reloadTheTeamView
{
    
    
    [TeamEngine getInfoWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error){
        
        
        self.teamInfo=result;
//        [self loadTheTeamView];
        
        [self showLoadingView];
        
        [self loadTheTeamViewWithHandler:^{
            
            [self hideLoadingView];
            
        }];

        
        
        
    }];

}

//-(void)loadTheTeamView
- (void)loadTheTeamViewWithHandler:(void (^)())handler
{
    
    
//    if (handler) {
//        handler ();
//    }

//    [self showLoadingView];
    
    BDLog(@"*******%@",self.teamInfo.objectId);
    
    //球队总人数
    [TeamEngine getTeamMenberCountWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error){
        
        NSArray *teamMenberArr=[[NSArray alloc]init];
        teamMenberArr=result;
        
        self.teamMemberCountLabel.text=[NSString stringWithFormat:@"成员%@人",[NSNumber numberWithInteger:[teamMenberArr count]]];

        //判断当前用户是不是改球队成员，控制『申请入队按钮』
        BDLog(@"*********%@",[BmobUser getCurrentUser]);
        
        
        if ([teamMenberArr count]!=0)
        {
            for (int i=0; i<[teamMenberArr count]; i++)
            {
                UserInfo *footballer=[teamMenberArr objectAtIndex:i];
                
                if ([[[BmobUser getCurrentUser] objectId] isEqualToString:footballer.objectId])
                {
                    
                    self.applyForJoinButton.hidden=YES;
                    self.rightBtn.hidden=NO;
                    self.isInTheTeamBool=@"YES";
                    
                    
                    
                    
                    break;
                    
                }
                else
                {
                    self.applyForJoinButton.hidden=NO;
                    self.rightBtn.hidden=YES;
                    self.isInTheTeamBool=@"NO";
                    
                    
                    
                }
                
                
            }

        }
        else if ([teamMenberArr count]==0)
        {
            
            self.applyForJoinButton.hidden=NO;
            self.rightBtn.hidden=YES;
            self.isInTheTeamBool=@"NO";
        }
        else
        {
            
        }
        

        
        
        if (self.applyForJoinButton.hidden)
        {
            
            [self.introButton setFrame:CGRectMake(297, 37, 23, 46)];

        }
        else
        {
            
            [self.introButton setFrame:CGRectMake(297, 23, 23, 46)];

        }
        
        
//        [self hideLoadingView];

        
        if (handler) {
            handler ();
        }

        
        
        
    }];
    
    
    
    
    
    
    
    [self.teamAvatorImage sd_setImageWithURL:[NSURL URLWithString:self.teamInfo.avator.url] placeholderImage:[UIImage imageNamed:@"pic.png"] completed:nil];
    
    self.teamNameLabel.text=self.teamInfo.name;
    
    

    if ([self.teamInfo.captain.nickname length]!=0)
    {
        self.teamCaptain.text=[NSString stringWithFormat:@"队长：%@",self.teamInfo.captain.nickname];

    }
    else
    {
        self.teamCaptain.text=[NSString stringWithFormat:@"队长：%@",self.teamInfo.captain.username];

    }
    
    
    
    
    
    //城市
    if (self.teamInfo.city)
    {
        
        
        LocationInfo *locInfo = [[LocationInfoManager sharedManager] locationInfoOfCode:[NSNumber numberWithInteger:[self.teamInfo.city integerValue]]];
        
        if ([locInfo.provinceName isEqualToString:locInfo.cityName])
        {
            self.teamAddressLabel.text = [NSString stringWithFormat:@"区域：%@", locInfo.cityName];

        }
        else
        {
            self.teamAddressLabel.text = [NSString stringWithFormat:@"区域：%@%@", locInfo.provinceName, locInfo.cityName];

        }

        
        
        
    }else
    {
        self.teamAddressLabel.text = @"区域：暂无";
    }
    
    
    //地址
    if (self.teamInfo.found_time)
    {
        NSString *date=[NSString stringWithFormat:@"%@",self.teamInfo.found_time];
        self.teamDateLabel.text=[NSString stringWithFormat:@"成立时间：%@年",[date substringWithRange:NSMakeRange(0,4)]];
        
    }else
    {
        self.teamDateLabel.text = @"成立时间：暂无";
    }
    
    
    
    if ([self.teamInfo.about length]!=0)
    {
        self.introButton.hidden=NO;
        
        self.introTextview.text=self.teamInfo.about;
        
    }
    else
    {
        self.introButton.hidden=YES;
    }
    
    
    
    
    //球队参赛数据
    
    if (self.teamInfo.appearances){
        self.joinNumberLabel.text=[NSString stringWithFormat:@"%@",self.teamInfo.appearances];
    }
    if (self.teamInfo.appearancesTotal) {
        self.totalNumber1.text=[NSString stringWithFormat:@"%@",self.teamInfo.appearancesTotal];
    }
    
    
    
    
    if (self.teamInfo.win){
        self.winNumber.text=[NSString stringWithFormat:@"%@",self.teamInfo.win];
    }
    if (self.teamInfo.winTotal) {
        self.totalNumber2.text=[NSString stringWithFormat:@"%@",self.teamInfo.winTotal];
    }

    
    
    
    if (self.teamInfo.loss){
        self.lostNumber.text=[NSString stringWithFormat:@"%@",self.teamInfo.loss];
    }
    if (self.teamInfo.lossTotal) {
        self.totalNumber4.text=[NSString stringWithFormat:@"%@",self.teamInfo.lossTotal];
    }

    
    
    
    if (self.teamInfo.draw) {
        self.tieNumber.text=[NSString stringWithFormat:@"%@",self.teamInfo.draw];
    }
    if (self.teamInfo.drawTotal) {
        self.totalNumber3.text=[NSString stringWithFormat:@"%@",self.teamInfo.drawTotal];
    }
    

    
    if (self.teamInfo.goals) {
        self.goalNumber.text=[NSString stringWithFormat:@"%@",self.teamInfo.goals];
    }
    if (self.teamInfo.goalsTotal) {
        self.totalNumber5.text=[NSString stringWithFormat:@"%@",self.teamInfo.goalsTotal];
    }

    
    if (self.teamInfo.goals_against) {
        self.fumbleNumber.text=[NSString stringWithFormat:@"%@",self.teamInfo.goals_against];
    }
    if (self.teamInfo.goalsAgainstTotal) {
        self.totalNumber6.text=[NSString stringWithFormat:@"%@",self.teamInfo.goalsAgainstTotal];
    }

    
    if (self.teamInfo.goal_difference) {
        self.onlyWinNumber.text=[NSString stringWithFormat:@"%@",self.teamInfo.goal_difference];
    }
    if (self.teamInfo.goalDifferenceTotal) {
        self.totalNumber7.text=[NSString stringWithFormat:@"%@",self.teamInfo.goalDifferenceTotal];
    }


    
    [self loadTeamExploitsAndScheduleData];
    
    [self loadTeamLineup];
    
//    [self loadLeagueName];

    
    
}

-(NSArray *)rankTheArrWithStarttime:(NSMutableArray *)sortArray kind:(NSString *)kindNumber
{
    
    NSComparator cmptr = ^(Tournament *match1, Tournament *match2)
    {
        if ([kindNumber isEqualToString:@"0"])
        {
            
            //战绩的时间降序
            if ([match1.start_time isLaterThanDate:match2.start_time])
            {
                return (NSComparisonResult)NSOrderedAscending;//升序
                
            }
            else
            {
                return (NSComparisonResult)NSOrderedDescending;//降序
                
            }
        }
        else if ([kindNumber isEqualToString:@"1"])
        {
            
            //赛程时间升序
            if ([match1.start_time isEarlierThanDate:match2.start_time])
            {
                return (NSComparisonResult)NSOrderedAscending;//升序
                
            }
            else
            {
                return (NSComparisonResult)NSOrderedDescending;//降序
                
            }

            
        }
        

        
        
        return (NSComparisonResult)NSOrderedSame;
        
    };
    
    
    
    
         //第一种排序
         NSArray *array = [sortArray sortedArrayUsingComparator:cmptr];
    

//         BDLog(@"*********%@",array);
    
    
    
    return array;
}

#pragma mark - Data loader
//-(void)loadTeamExploitsAndScheduleData{
//    [TeamEngine getLastestTouramentWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error) {
//                                            if (!error) {
//                                                self.exploitsTotalArr=[[NSMutableArray alloc]init];
//                                                for (id obj in result) {
//                                                    [self.exploitsTotalArr addObject:obj];
//                                                }
//                                                [TeamEngine getNearestTouramentWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error) {
//                                                    if (!error) {
//                                                        self.self.scheduleTotalArr=[[NSMutableArray alloc]init];
//                                                        for (id obj in result) {
//                                                            [self.scheduleTotalArr addObject:obj];
//                                                        }
//                                                        [self loadLeagueName];
//                                                    }
////                                                    else{
////                                                        [self showMessage:[Util errorStringWithCode:error.code]];
////                                                    }
//                                                    
//                                                }];
////                                                [self loadLeagueName];
//                                            }else{
//                                                [self showMessage:[Util errorStringWithCode:error.code]];
//                                            }
//                                        }];
//    
//}

//获取tourament
- (void)loadTeamExploitsAndScheduleData
{


//    [self showLoadingView];

    //获取该球队的主场的比赛
    [TeamEngine getAllHomeTouramentWithTeamId:self.teamInfo.objectId limit:1000 block:^(id result, NSError *error)
    {

        NSMutableArray *allTeamTourament1Arr=[[NSMutableArray alloc]init];
        
        if (!error)
        {
            
            for (id obj in result)
            {
                //全部主场的比赛
                [allTeamTourament1Arr addObject: obj];
            }
            
            
            //获取该球队客场的比赛
            [TeamEngine getAllGusstTouramentWithTeamId:self.teamInfo.objectId limit:1000 block:^(id result, NSError *error) {
                
                if (!error)
                {

                    for (id obj in result)
                    {
                        //全部的比赛
                        [allTeamTourament1Arr addObject: obj];
                    }

                    BDLog(@"*********%lu",(unsigned long)[allTeamTourament1Arr count]);

                    
                    //tourament按照时间，时间降序排列，8-20、8-7、7-19
                    NSArray *allRankedTouramentArr=[[NSArray alloc]init];
                    allRankedTouramentArr=[self rankTheArrWithStarttime:allTeamTourament1Arr kind:@"0"];
                    
                    NSDate *serverDate=[NSDate dateFromServer];
                    
                    
                    self.scheduleTotalArr=[[NSMutableArray alloc]init];
                    self.exploitsTotalArr=[[NSMutableArray alloc]init];

//                    self.scheduleTotalArr=nil;
//                    self.exploitsTotalArr=nil;
                    
                    NSMutableArray *myScheduleTotalArr=[[NSMutableArray alloc]init];
                    for (Tournament *tourament in allRankedTouramentArr)
                    {
                        if ([tourament.start_time isLaterThanDate:serverDate])
                        {
                            
                            //赛程（未结束）
                            [myScheduleTotalArr addObject:tourament];
                        }
                        else
                        {
                            //战绩（已结束）
                            
                            [self.exploitsTotalArr addObject:tourament];
                            
                        }
                    }
                    
                    BDLog(@"exploitsTotalArr **********%lu",(unsigned long)[self.exploitsTotalArr count]);
                    
                    BDLog(@"myScheduleTotalArr **********%lu",(unsigned long)[myScheduleTotalArr count]);
                    //赛程，按照starttime排序,时间升序
                    if ([myScheduleTotalArr count]>=2)
                    {
                        //tourament按照时间，时间升序排列，10.1、10.2
                        NSArray *allRankedTouramentArr=[[NSArray alloc]init];
                        allRankedTouramentArr=[self rankTheArrWithStarttime:myScheduleTotalArr kind:@"1"];
                        
//                        self.scheduleTotalArr=nil;
                        
                        for (Tournament *match in allRankedTouramentArr)
                        {
                            [self.scheduleTotalArr addObject:match];
                        }
                    }else
                    {
                        self.scheduleTotalArr = myScheduleTotalArr;
                    }

                    BDLog(@"**********%lu",(unsigned long)[self.exploitsTotalArr count]);

                    BDLog(@"**********%lu",(unsigned long)[self.scheduleTotalArr count]);
                    [self loadLeagueName];
                }
                else
                {
                    [self showMessage:[Util errorStringWithCode:error.code]];
//                    [self hideLoadingView];

                }
                
                
                
            }];
        }
        else
        {
            [self showMessage:[Util errorStringWithCode:error.code]];
//            [self hideLoadingView];
        }
    }];
    
}






-(void)loadTeamLineup
{
//    [self showLoadingView];
    [TeamEngine getLineupWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error)
    {
        self.isLineupLoaded = YES;
//        [self hideLoadingView];
        if (!error)
        {
            self.lineup = result;
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData];
        }
        else
        {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }
    }];
}





-(void)loadLeagueName
{
    if ([self.exploitsTotalArr count]==0 && [self.scheduleTotalArr count]==0)
    {
        self.leagueName=@"暂无赛事信息";

    }
    else
    {
        
        
        
        
        
//先看最新的战绩、没有再选择赛程的所属联赛
        
        for (int i=0; i<[self.exploitsTotalArr count]; i++)
        {
            
            Tournament *tourament=[self.exploitsTotalArr objectAtIndex:i];
            
            if (tourament.league)
            {
                self.leagueName=tourament.league.name;//联赛名
                self.leagueId=tourament.league.objectId;
                
                break;
            }
            
            
            
        }

        
        
        if ([self.leagueName length]==0)
        {
            
            for (int i=0; i<[self.scheduleTotalArr count]; i++)
            {
                
                Tournament *tourament=[self.scheduleTotalArr objectAtIndex:i];
                
                if (tourament.league)
                {
                    self.leagueName=tourament.league.name;//联赛名
                    self.leagueId=tourament.league.objectId;
                    
                    break;
                }
                
                
                
            }


            
            
        }
        
        
        
        if ([self.leagueName length]==0)
        {
            self.leagueName=@"暂无赛事信息";
        }

        
        
        
        
        
        
        
        
    }
    
    
    
    [self.teamTableview reloadData];
    [self hideLoadingView];

    
    
    
    
    
}





- (void)applyPushWithTeam:(Team *)team
{
    if(!team.captain.username)
    {
        [self showMessage:@"球队未设置队长"];
        return;
    }
    Notice *msg = [[Notice alloc] init];
    BmobUser *user = [BmobUser getCurrentUser];
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:user];
    NSString *content = [NSString stringWithFormat:@"%@请求加入球队", selfUser.nickname ? selfUser.nickname : selfUser.username];
    msg.subtype = NoticeSubtypeApplyTeam;
    msg.targetId = [NSString stringWithFormat:@"%@&%@", team.objectId, selfUser.objectId];
    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    NSString *name = selfUser.nickname ? selfUser.nickname : selfUser.username;
    msg.title =[NSString stringWithFormat:@"%@&%@",name,team.name] ;//team.name;
    //    msg.content = content;
    msg.type = NoticeTypeTeam;
    [[NoticeManager sharedManager] pushNotice:msg toUsername:team.captain.username];
}

- (void)quitTeamPushWithTeam:(Team *)team
{
    if(!team.captain.username)
    {
        [self showMessage:@"球队未设置队长"];
        return;
    }
    Notice *msg = [[Notice alloc] init];
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    NSString *content = [NSString stringWithFormat:@"%@默默离开了球队", selfUser.nickname ? selfUser.nickname : selfUser.username];
    msg.subtype = NoticeSubtypeQuitTeam;
    msg.targetId = [NSString stringWithFormat:@"%@&%@", team.objectId, selfUser.objectId];
    msg.aps = [ApsInfo apsInfoWithAlert:content badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.title = team.name;
    //    msg.content = content;
    msg.type = NoticeTypeTeam;
    [[NoticeManager sharedManager] pushNotice:msg toUsername:team.captain.username];
}





#pragma mark - Popview

- (void)showSettingToolView
{
    
    self.settingToolView.hidden = NO;
    
    float rowHeight = 43;
    //判断加入了几支球队
    [self showLoadingView];
    [TeamEngine getJoinedTeamsWithUserId:[[BmobUser getCurrentUser] objectId] block:^(id result, NSError *error) {
    
        [self hideLoadingView];
        
        NSMutableArray *array=[[NSMutableArray alloc]initWithArray:result];
        
        if ([array count]==1)
        {
            
            //判断当前用户是不是队长，显示不同设置
            if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
            {
        
                [self.settingOptionView setFrame:CGRectMake(0.0, -172.0, 320.0, 215.0-rowHeight)];

                
                self.teamInfoView.hidden=NO;
                self.shareTeamView.hidden=YES;
                self.memberMangeView.hidden=NO;
                self.switchTeamView.hidden=YES;

                
        
                [self.teamInfoView setFrame:CGRectMake(0.0, 0.0, 320.0, 43.0)];
                [self.shareTeamView setFrame:CGRectMake(0.0, 43.0, 320.0, 215.0)];
                [self.memberMangeView setFrame:CGRectMake(0.0, 86.0-rowHeight, 320.0, 215.0)];
                [self.searchTeamView setFrame:CGRectMake(0.0, 129.0-rowHeight, 320.0, 215.0)];
                [self.quitTeamView setFrame:CGRectMake(0.0, 172.0-rowHeight, 320.0, 215.0)];

                
                
            }
            else
            {
            
                [self.settingOptionView setFrame:CGRectMake(0.0, -86.0, 320.0, 129.0-rowHeight)];

                
            self.teamInfoView.hidden=YES;
                self.shareTeamView.hidden=YES;
            self.memberMangeView.hidden=YES;
            self.switchTeamView.hidden=YES;

            
            [self.shareTeamView setFrame:CGRectMake(0.0, 0.0, 320.0, 43.0)];
            [self.searchTeamView setFrame:CGRectMake(0.0, 43.0-rowHeight, 320.0, 43.0)];
            [self.quitTeamView setFrame:CGRectMake(0.0, 86.0-rowHeight, 320.0, 43.0)];


            }
            
            
            [UIView animateWithDuration:0.4 animations:^{
                
                CGRect frame = self.settingOptionView.frame;
                frame.origin.y = 0;
                self.settingOptionView.frame  = frame;
                self.settingBgView.alpha = 0.3;
            } completion:nil];

            
            
        }
        else if ([array count]==2)
        {
    
            //判断当前用户是不是队长，显示不同设置
            if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
            {
                
                [self.settingOptionView setFrame:CGRectMake(0.0, -215.0, 320.0, 258.0-rowHeight)];

                
                self.teamInfoView.hidden=NO;
                self.shareTeamView.hidden=YES;
                self.memberMangeView.hidden=NO;
                self.switchTeamView.hidden=NO;

                
                [self.teamInfoView setFrame:CGRectMake(0.0, 0.0, 320.0, 43.0)];
                [self.shareTeamView setFrame:CGRectMake(0.0, 43.0, 320.0, 43.0)];
                [self.memberMangeView setFrame:CGRectMake(0.0, 86.0-rowHeight, 320.0, 43.0)];
                [self.searchTeamView setFrame:CGRectMake(0.0, 129.0-rowHeight, 320.0, 43.0)];
                [self.switchTeamView setFrame:CGRectMake(0.0, 172.0-rowHeight, 320.0, 43.0)];
                [self.quitTeamView setFrame:CGRectMake(0.0, 215.0-rowHeight, 320.0, 43.0)];
                
                
            }
            else
            {
                
                [self.settingOptionView setFrame:CGRectMake(0.0, -129.0, 320.0, 172.0-rowHeight)];
                
                self.teamInfoView.hidden=YES;
                self.shareTeamView.hidden=YES;
                self.memberMangeView.hidden=YES;
                self.switchTeamView.hidden=NO;

                
                [self.shareTeamView setFrame:CGRectMake(0.0, 0.0, 320.0, 43.0)];
                [self.searchTeamView setFrame:CGRectMake(0.0, 43.0-rowHeight, 320.0, 43.0)];
                [self.switchTeamView setFrame:CGRectMake(0.0, 86.0-rowHeight, 320.0, 43.0)];
                [self.quitTeamView setFrame:CGRectMake(0.0, 129.0-rowHeight, 320.0, 43.0)];

                
            }
            
            
            [UIView animateWithDuration:0.4 animations:^{
                
                CGRect frame = self.settingOptionView.frame;
                frame.origin.y = 0;
                self.settingOptionView.frame  = frame;
                self.settingBgView.alpha = 0.3;
            } completion:nil];

            
            
        }
        else
        {
            
        }
    
        
        
        
        
    }];

    
    
    
    
    
}

- (void)hideSettingToolView
{
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.settingOptionView.frame;
        frame.origin.y = - frame.size.height;
        self.settingOptionView.frame  = frame;
        self.settingBgView.alpha = 0;
    } completion:^(BOOL finished) {
        self.settingToolView.hidden = YES;
    }];
    
    
}





-(void)showTeamIntroview
{
    
    
    
    if ([self.isInTheTeamBool isEqualToString:@"YES"])
    {
            self.rightBtn.hidden=YES;
    
    }
    
    self.teamIntroView.hidden = NO;
    UIView *bgView = [self.teamIntroView viewWithTag:0xF0];
    UIView *contentView = [self.teamIntroView viewWithTag:0xF1];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = contentView.frame;
        frame.origin.x = self.teamIntroView.frame.size.width - frame.size.width;
        contentView.frame = frame;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 animations:^{
            bgView.alpha = 1.0;
        } completion:nil];
        
    }];
    
    

    
}

-(void)hideTeamIntroview
{

    
    
    UIView *bgView = [self.teamIntroView viewWithTag:0xF0];
    UIView *contentView = [self.teamIntroView viewWithTag:0xF1];
    [UIView animateWithDuration:0.2 animations:^{
        bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = contentView.frame;
            frame.origin.x = self.teamIntroView.frame.size.width;
            contentView.frame = frame;
        } completion:^(BOOL finished)
         {
             self.teamIntroView.hidden = YES;
             
            if ([self.isInTheTeamBool isEqualToString:@"YES"])
            {
                    self.rightBtn.hidden=NO;
            }

             
         }];
        
    }];
    
    
    
    

    
    
}







- (void)onTeamSetting:(UIButton *)sender
{
    
    self.isSetting = !self.isSetting;

    if (self.isSetting) {
        
        [self showSettingToolView];
        
    }else
    {
        [self hideSettingToolView];
    }

    
    
}


- (void)introButtonClick:(UIButton *)sender
{
    
//    //简介
//    self.isIntroClicking = !self.isIntroClicking;
//    
//    if (self.isIntroClicking) {
    
        [self showTeamIntroview];
        
//    }else
//    {
//        [self hideTeamIntroview];
//    }
    

    
    
    
    
    
}

- (IBAction)hideIntroviewButtonClick:(id)sender {
    
    self.isIntroClicking = YES;

    
    [self hideTeamIntroview];

    
}



#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //Team_formation
    if (indexPath.row==1)
    {
        
//        return [self cellForScheduleAtIndexPath:indexPath];
        
    }
    else if (indexPath.row==2)
    {
        
            if (self.isLineupLoaded && ![self.lineup isKindOfClass:[NSError class]])
            {
                    [self performSegueWithIdentifier:@"Team_formation" sender:nil];

            }

        
        
        
        
//        return [self cellForFormationAtIndexPath:indexPath];
        
    }
    else if (indexPath.row==3)
    {
        
//        return [self cellForCompetitionAtIndexPath:indexPath];
        
        [self toGoScoreboard];
    }
    
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.row==0)
    {
        
        return [self cellForExploitsAtIndexPath:indexPath];

    
    }
    else if (indexPath.row==1)
    {
        
        return [self cellForScheduleAtIndexPath:indexPath];

    }
    else if (indexPath.row==2)
    {
        
        return [self cellForFormationAtIndexPath:indexPath];

    }
    else if (indexPath.row==3)
    {
        
        return [self cellForCompetitionAtIndexPath:indexPath];


    }
    else
    {
        return nil;

    }
}


- (UITableViewCell *)cellForExploitsAtIndexPath:(NSIndexPath *)indexPath
{
    
        exploitsTableViewCell *cell = (exploitsTableViewCell *)[self.teamTableview dequeueReusableCellWithIdentifier:@"TeammanageCell1"];
        
        if (cell == nil)
        {
            cell = [[exploitsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeammanageCell1"];
        }
    
    cell.detailView.hidden=NO;
    cell.nullView.hidden=YES;

    
    
    if ([self.exploitsTotalArr count]==0)
    {
        cell.userInteractionEnabled=NO;
        
        //暂无战绩信息
        cell.detailView.hidden=YES;
        cell.nullView.hidden=NO;
        cell.nullLabel.text=@"暂无战绩信息";
        
    }
    else
    {
        
        Tournament *match2 = [self.exploitsTotalArr firstObject];
        
        cell.dataLabel.text = [DateUtil formatedDate:match2.start_time byDateFormat:@"MM/dd HH:mm"];
        
        
        cell.hostteamName.text=match2.home_court.name;
        
        cell.guestteamName.text=match2.opponent.name;
        
        
        if (match2.isVerify)
        {
            
            if (match2.score_h!=nil && match2.score_h2!=nil)
            {
                cell.scoreLabel.text=[NSString stringWithFormat:@"%@-%@",match2.score_h,match2.score_h2];
                
            }
            else
            {
                cell.scoreLabel.text=@"0-0";
                
            }

            
        }
        else
        {
            
            
            if ([self.teamInfo.objectId isEqualToString:match2.home_court.objectId])
            {
                
                
                //当前球队为主队，显示主队输入的比分
                if (match2.score_h!=nil && match2.score_h2!=nil)
                {
                    cell.scoreLabel.text=[NSString stringWithFormat:@"%@-%@",match2.score_h,match2.score_h2];
                    
                }
                else
                {
                    cell.scoreLabel.text=@"0-0";
                    
                }

                
            }
            else if ([self.teamInfo.objectId isEqualToString:match2.opponent.objectId])
            {
                
                //当前球队为客队，显示客队输入的比分
                if (match2.score_o!=nil && match2.score_o2!=nil)
                {
                    cell.scoreLabel.text=[NSString stringWithFormat:@"%@-%@",match2.score_o2,match2.score_o];
                    
                }
                else
                {
                    cell.scoreLabel.text=@"0-0";
                    
                }

                
                
                
            }
            else
            {
                
            }
            
            
            
            
            
        }
        
        

        
        
        
        
        
        cell.userInteractionEnabled=YES;
        
    }
    return cell;
    
}

- (UITableViewCell *)cellForScheduleAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    ScheduleTableViewCell *cell = (ScheduleTableViewCell *)[self.teamTableview dequeueReusableCellWithIdentifier:@"TeammanageCell2"];
    
    if (cell == nil)
    {
        cell = [[ScheduleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeammanageCell2"];
    }
    
    
    
    
    
    if ([self.scheduleTotalArr count]==0)
    {
        cell.userInteractionEnabled=NO;
        
        
        cell.datelabel.text = @"";
        
        cell.hostTeam.text = @"暂无赛程信息";
        
        cell.siteLabel.text = @"";

    }
    else
    {
        
        Tournament *match2 = [self.scheduleTotalArr firstObject];
        
        cell.datelabel.text = [DateUtil formatedDate:match2.start_time byDateFormat:@"MM/dd HH:mm"];
        
//        cell.hostTeam.text = match2.name;
        cell.hostTeam.text=[NSString stringWithFormat:@"%@-%@",match2.home_court.name,match2.opponent.name];

        
        cell.siteLabel.text = match2.site;
        
        cell.userInteractionEnabled=YES;

        
    }
    
    
    
    
    return cell;
    
}

- (UITableViewCell *)cellForFormationAtIndexPath:(NSIndexPath *)indexPath
{
    FormationTableViewCell *cell = (FormationTableViewCell *)[self.teamTableview dequeueReusableCellWithIdentifier:@"TeammanageCell3"];
    
    cell.lineup = self.lineup;
    
    cell.teamInfo=self.teamInfo;
    
    if (self.isLineupLoaded)
    {
        if (self.lineup)
        {
            cell.teamMemberScrollview.hidden = NO;
            cell.messageLabel.hidden = YES;
            cell.messageLabel.text = @"暂无阵容信息";

        }else
        {
            cell.teamMemberScrollview.hidden = NO;
            cell.messageLabel.hidden = YES;


        }
    }else
    {
        cell.teamMemberScrollview.hidden = YES;
        cell.messageLabel.hidden = NO;
        cell.messageLabel.text = @"正在加载阵容信息...";
        

    }
    
    
    
    
    
    
    return cell;
    
}


- (UITableViewCell *)cellForCompetitionAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    CompetitionInfoTableViewCell *cell = (CompetitionInfoTableViewCell *)[self.teamTableview dequeueReusableCellWithIdentifier:@"TeammanageCell4"];
    
    if (cell == nil)
    {
        cell = [[CompetitionInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TeammanageCell4"];
    }
    
    
    cell.compitionName.text=self.leagueName;
    
    if ([self.leagueName isEqualToString:@"暂无赛事信息"])
    {
        cell.userInteractionEnabled=NO;
    }
    else
    {
        cell.userInteractionEnabled=YES;
    }
    
    
    
    return cell;
    
    
}







#pragma mark UIScrollViewDelegate method
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int size  = self.view.frame.size.width;
    int page = self.teamDataScroll.contentOffset.x/size;
    self.pageControl.currentPage = page;
}


//#warning 1111

-(void)toGoScoreboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Match" bundle:[NSBundle mainBundle]];
//    ScoreboardViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"ScoreboardViewController"];
//    [svc setValue:self.leagueId forKey:@"leagueId"];
//    [svc setValue:self.leagueName forKey:@"leagueName"];
//    [svc setValue:self.leagueName forKey:@"title"];
//    [self.navigationController pushViewController:svc animated:YES];
    
    MatchDetailViewController *leagueVC = [storyboard instantiateViewControllerWithIdentifier:@"MatchDetailViewController"];
    
    leagueVC.leagueName=self.leagueName;
    
    leagueVC.leagueId=self.leagueId;//传联赛id
    
    leagueVC.isSearchLeagueBool=NO;
    
    [self.navigationController pushViewController:leagueVC animated:YES];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     
     if ([segue.identifier isEqualToString:@"Team_exploits"])
     {
         //战绩，按照endtime排序
         [segue.destinationViewController setValue:self.exploitsTotalArr forKey:@"exploitsArr"];
         
         [segue.destinationViewController setValue:self.isInTheTeamBool forKey:@"isInTheTeamBool"];
         [segue.destinationViewController setValue:[[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]] forKey:@"userInfo"];
         [segue.destinationViewController setValue:self.teamInfo forKey:@"team"];
         [segue.destinationViewController setValue:[NSNumber numberWithBool:!self.applyForJoinButton.hidden] forKey:@"isOtherTeam"];
         
     }
     else if ([segue.identifier isEqualToString:@"Team_schedule"])
     {
         
         [segue.destinationViewController setValue:self.scheduleTotalArr forKey:@"schedule"];
         [segue.destinationViewController setValue:[[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]] forKey:@"userInfo"];
         [segue.destinationViewController setValue:self.teamInfo forKey:@"team"];
          [segue.destinationViewController setValue:[NSNumber numberWithBool:!self.applyForJoinButton.hidden] forKey:@"isOtherTeam"];
         [segue.destinationViewController setValue:[NSNumber numberWithBool:YES] forKey:@"isForTeam"];
     }
     else if ([segue.identifier isEqualToString:@"Team_formation"])
     {
         [segue.destinationViewController setValue:self.teamInfo forKey:@"teamInfo"];
         if (self.lineup) {
             [segue.destinationViewController setValue:self.lineup forKey:@"lineup"];
         }
     }
     else if ([segue.identifier isEqualToString:@"Team_compition"])
     {
    
         [segue.destinationViewController setValue:self.leagueId forKey:@"leagueId"];

         [segue.destinationViewController setValue:self.leagueName forKey:@"title"];

     }
     else if ([segue.identifier isEqualToString:@"Team_teammateList"])
     {
         
         [segue.destinationViewController setValue:self.teamInfo forKey:@"teamInfo"];
         
     }
     else if ([segue.identifier isEqualToString:@"Team_teamMenberList"])
     {
         
         [segue.destinationViewController setValue:@"球队成员" forKey:@"title"];

         [segue.destinationViewController setValue:self.teamInfo forKey:@"teamInfo"];
         
     }

     else if ([segue.identifier isEqualToString:@"Team_teamEdit"])
     {
         
         [segue.destinationViewController setValue:self.teamInfo forKey:@"teamInfo"];

         [segue.destinationViewController setValue:@"0" forKey:@"isCreateteamBoolStr"];

         [segue.destinationViewController setValue:@"球队资料编辑" forKey:@"title"];
         
     }
     else if ([segue.identifier isEqualToString:@"Team_searchTeam"])
     {
         
         [segue.destinationViewController setValue:@"创建/搜索球队" forKey:@"title"];
         
         [segue.destinationViewController setValue:@"1" forKey:@"isSearchBoolStr"];

         
     }else
     {
         
     }
    
     
     
     
     
     
     
     
 }






@end

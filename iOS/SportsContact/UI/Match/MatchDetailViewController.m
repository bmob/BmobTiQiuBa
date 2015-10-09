//
//  MatchDetailViewController.m
//  SportsContact
//
//  Created by Nero on 8/14/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "MatchDetailViewController.h"
#import "Util.h"


#import "ScoreboardViewController.h"
#import "ShooterboardViewController.h"
#import "LeagueresultViewController.h"
#import "LeaguescheduleViewController.h"


#import "CHTumblrMenuView.h"
#import <ShareSDK/ShareSDK.h>


#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"





@interface MatchDetailViewController ()
{
    float viewHight;
}

@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (strong, nonatomic)  NSString *shareTitle;
@property (strong, nonatomic)  NSString *shareContent;
@property (strong, nonatomic)  NSString *shareUrl;




//scrollview
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic)  NSMutableArray *sliderViewArray;
@property (strong, nonatomic) IBOutlet UIView *scoreboardView;
@property (strong, nonatomic) IBOutlet UIView *shooterboardView;
@property (strong, nonatomic) IBOutlet UIView *leagueresultView;
@property (strong, nonatomic) IBOutlet UIView *leaguescheduleView;




@end



@implementation MatchDetailViewController

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
    
    
    if (self.isSearchLeagueBool)
    {
        [self hideBackButton];
        
        [self showBackRootButton];

    }

    
    
    
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"zf.png"] forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"zf_.png"] forState:UIControlStateHighlighted];

    self.shareButton.hidden=NO;
    
    
    
//    [self.pageControl addTarget:self action:@selector(turnPage) forControlEvents:UIControlEventValueChanged]; // 触摸mypagecontrol触发change这个方法事件

    
//    self.pageControl.currentPage=0;
    self.title=@"联赛积分榜";
    
    self.shareTitle=[NSString stringWithFormat:@"%@联赛积分榜",self.leagueName];

    self.shareContent=[NSString stringWithFormat:@"%@最新积分榜出炉了，欢迎查看。",self.leagueName];

    self.shareUrl=[NSString stringWithFormat:@"http://tq.codenow.cn/share/LeagueData?league=%@",self.leagueId];
    
    
    
    self.sliderViewArray = [[NSMutableArray alloc] init];
    [self.sliderViewArray addObject:self.scoreboardView];
    [self.sliderViewArray addObject:self.shooterboardView];
    [self.sliderViewArray addObject:self.leagueresultView];
    [self.sliderViewArray addObject:self.leaguescheduleView];
    
    
    
    viewHight=self.view.frame.size.height-64.0;
    
    for (int i=0; i<[self.sliderViewArray count]; i++)
    {
        UIView *containView=[self.sliderViewArray objectAtIndex:i];
        containView.frame = CGRectMake((320 * i), 0, 320, viewHight);
    }
    
    [self.scrollView setContentSize:CGSizeMake(320 * [self.sliderViewArray count], 0)]; //  +上第1页和第4页  原理：4-[1-2-3-4]-1
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    [self.scrollView scrollRectToVisible:CGRectMake(0,0,320,0) animated:NO]; // 默认从序号1位置放第1页 ，序号0位置位置放第4页
    
    
    
//    [self showLoadingView];
    
    //积分榜页面、射手榜页面、联赛结果页面、联赛赛程表页 的ViewController
    
    ScoreboardViewController *scoreboardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ScoreboardViewController"];
    scoreboardVC.leagueId=self.leagueId;
    [self addChildViewController:scoreboardVC];
    scoreboardVC.view.frame = self.scoreboardView.bounds;
    scoreboardVC.leagueName=self.leagueName;
    [self.scoreboardView addSubview:scoreboardVC.view];
    
    
    ShooterboardViewController *shootboardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShooterboardViewController"];
    shootboardVC.leagueId=self.leagueId;
    [self addChildViewController:shootboardVC];
    shootboardVC.view.frame = self.shooterboardView.bounds;
    shootboardVC.leagueName=self.leagueName;
    [self.shooterboardView addSubview:shootboardVC.view];
    
    
    LeagueresultViewController *leagueresultVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LeagueresultViewController"];
    leagueresultVC.leagueId=self.leagueId;
    [self addChildViewController:leagueresultVC];
    leagueresultVC.view.frame = self.leagueresultView.bounds;
    [self.leagueresultView addSubview:leagueresultVC.view];
    
    
    LeaguescheduleViewController *leaguescheduleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LeaguescheduleViewController"];
    leaguescheduleVC.leagueId = self.leagueId;
    [self addChildViewController:leaguescheduleVC];
    leaguescheduleVC.view.frame = self.leaguescheduleView.bounds;
    [self.leaguescheduleView addSubview:leaguescheduleVC.view];

    
    
    
//    [self hideLoadingView];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
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
    
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:self.shareContent
                                       defaultContent:nil
                                                image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@"res2.jpg"] quality:1]
                                                title:self.shareTitle
                                                  url:self.shareUrl
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    
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
                                     BDLog(@"发布失败!error code == %ld, error code == %@", (unsigned long)[error errorCode], [error errorDescription]);
                                 }
                             }];
    
    
}






//// pagecontrol 选择器的方法
//- (void)turnPage
//{
//    
//    int page = self.pageControl.currentPage; // 获取当前的page
//    [self.scrollView scrollRectToVisible:CGRectMake(320*(page+1),0,320,viewHight) animated:NO]; // 触摸pagecontroller那个点点 往后翻一页 +1
//}

#pragma mark scrollviewDelegate
// scrollview 委托函数
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pagewidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pagewidth/([self.sliderViewArray count]+2))/pagewidth)+1;
//    page --;  // 默认从第二页开始
    
    self.pageControl.currentPage = page;
    
    
    if (self.pageControl.currentPage==0 || self.pageControl.currentPage==1)
    {
        self.shareButton.hidden=NO;
    }
    else
    {
        self.shareButton.hidden=YES;
    }
    

    
    
    switch (self.pageControl.currentPage)
    {
            
        case 0:
            self.title=@"联赛积分榜";
        
        self.shareTitle=[NSString stringWithFormat:@"%@联赛积分榜",self.leagueName];
        
        self.shareContent=[NSString stringWithFormat:@"%@最新积分榜出炉了，欢迎查看。",self.leagueName];
        
        self.shareUrl=[NSString stringWithFormat:@"http://tq.codenow.cn/share/LeagueData?league=%@",self.leagueId];

            break;
            
        case 1:
            self.title=@"联赛射手榜";
        
        self.shareTitle=[NSString stringWithFormat:@"%@联赛射手榜",self.leagueName];
        
        self.shareContent=[NSString stringWithFormat:@"%@最新射手榜出炉了，一起来膜拜男神吧。",self.leagueName];
        
        self.shareUrl=[NSString stringWithFormat:@"http://tq.codenow.cn/share/playerScoreData?league=%@",self.leagueId];

            break;
            
        case 2:
            self.title=@"联赛战绩表";
            break;
            
        case 3:
            self.title=@"联赛赛程表";
            break;

            
        default:
            break;
    }

    
    
    
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    
    
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

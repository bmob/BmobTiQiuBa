//
//  MatchReportViewController.m
//  SportsContact
//
//  Created by bobo on 14/11/11.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "MatchReportViewController.h"
#import "CCoverflowCollectionViewLayout.h"
#import "MatchEngine.h"
#import "TeamEngine.h"
#import "DateUtil.h"
#import "ViewUtil.h"
#import "CHTumblrMenuView.h"
#import <ShareSDK/ShareSDK.h>


#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"

#define TITLE @"测试_Title"
#define CONTENT @"测试_Content"
#define URL @"http://www.baidu.com"




@interface MatchReportViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *homeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *opponentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *leagueLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) Tournament *match;
@property (nonatomic, strong) NSArray *playerScoreArray;
@property (nonatomic, strong) NSArray *goalPlayerArray;
@property (nonatomic, strong) NSArray *assistPlayerArray;

@property (nonatomic, weak) UITableView *playerTableView;
@property (nonatomic, weak) UITableView *goalPlayerTableView;
@property (nonatomic, weak) UITableView *assistPlayerTableView;




@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic)  NSString *shareTitle;
@property (strong, nonatomic)  NSString *shareContent;
@property (strong, nonatomic)  NSString *shareUrl;




@end

@implementation MatchReportViewController

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
//    [self.collectionView setContentOffset:CGPointMake(80, 0) animated:YES];
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"zf.png"] forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"zf_.png"] forState:UIControlStateHighlighted];

    [self loadMatchData];
    
    CCoverflowCollectionViewLayout *layout = (id)self.collectionView.collectionViewLayout;
    if ([ViewUtil screenHeight] > 480.0)
    {
        layout.cellSize = (CGSize){ 200.0f, 300.0f };
    }else
    {
        layout.cellSize = (CGSize){ 200.0f, 230.0f };
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)loadMatchData
{
    [self showLoadingView];
    [MatchEngine getMatchWithMatchId:self.tournamentId block:^(id result, NSError *error) {
        if (error) {
            [self hideLoadingView];
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            self.match = result;
            self.homeNameLabel.text = self.match.home_court.name;
            self.opponentNameLabel.text = self.match.opponent.name;
            NSString *addressString = self.match.start_time ? [NSString stringWithFormat:@"%@  ", [DateUtil formatedDate:self.match.start_time byDateFormat:@"yyyy.MM.dd"]] : @"";
            self.addressLabel.text = [addressString stringByAppendingFormat:@"%@",self.match.site ? self.match.site : @""];
            NSString *typeString = self.match.league.name ? [NSString stringWithFormat:@"%@ - ", self.match.league.name] : @"";
            self.leagueLabel.text = [typeString stringByAppendingFormat:@"%@", tournamentTypeStringFromEnum(self.match.nature.integerValue)];
            
            if(self.teamId)
            {
                BOOL isHomeCourt = [self.teamId isEqualToString:self.match.home_court.objectId];
                if (isHomeCourt) {
                    if (self.match.score_h && self.match.score_h2) {
                        self.scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [self.match.score_h intValue], [self.match.score_h2 intValue]];
                    }else{
                        self.scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [@"0" intValue], [@"0" intValue]];
                    }
                }else{
                    if (self.match.score_o2 && self.match.score_o) {
                        self.scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [self.match.score_o2 intValue], [self.match.score_o intValue]];
                    }else{
                        self.scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [@"0" intValue], [@"0" intValue]];
                    }
                }
//                if (isHomeCourt || (self.match.score_h && self.match.score_h2))
//                {
//                    self.scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [self.match.score_h intValue], [self.match.score_h2 intValue]];
//                }else
//                {
//                    self.scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [self.match.score_o2 intValue], [self.match.score_o intValue]];
//                }
            }else
            {
                if (self.match.score_h && self.match.score_h2) {
                     self.scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [self.match.score_h intValue], [self.match.score_h2 intValue]];
                }else
                {
                     self.scoreLabel.text = [NSString stringWithFormat:@"%d - %d", [self.match.score_o2 intValue], [self.match.score_o intValue]];
                }
            }
            [self loadPalyersScoreArray];
        }
    }];
}

- (void)loadPalyersScoreArray
{
    [MatchEngine getPlayerScoreWithTournament:self.match.objectId teamId:self.teamId block:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (error)
         {
            [self showMessage:[Util errorStringWithCode:error.code]];
         }else
         {
             self.playerScoreArray = result;
             [self setUpPlayersData];
         }
     }];
}

- (void)setUpPlayersData
{
    NSMutableArray *goalPlayerArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *assistPlayerArray = [NSMutableArray arrayWithCapacity:0];;
    for (PlayerScore *playScore in self.playerScoreArray) {
        if ([playScore.goals integerValue] > 0) {
            [goalPlayerArray addObject:playScore];
        }
        if ([playScore.assists integerValue] > 0) {
            [assistPlayerArray addObject:playScore];
        }
    }
    self.goalPlayerArray = [self sortArrayWithArray:goalPlayerArray kind:0];
    self.assistPlayerArray = [self sortArrayWithArray:assistPlayerArray kind:1];
    [self.playerTableView reloadData];
    [self.goalPlayerTableView reloadData];
    [self.assistPlayerTableView reloadData];
}

-(NSArray *)sortArrayWithArray:(NSMutableArray *)array kind:(NSInteger)kind
{
    NSComparator cmptr = ^(PlayerScore *playScore1, PlayerScore *playScore2)
    {
        NSInteger num1 = kind == 0 ? [playScore1.goals integerValue] : [playScore1.assists integerValue];
        NSInteger num2 = kind == 0 ? [playScore2.goals integerValue] : [playScore2.assists integerValue];
        if (num1 > num2)
        {
            return (NSComparisonResult)NSOrderedAscending;//升序
        }
        else
        {
            return (NSComparisonResult)NSOrderedDescending;//降序
            
        }
    };
    NSArray *sortArray = [array sortedArrayUsingComparator:cmptr];
    return sortArray;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.goalPlayerTableView) {
        return [self.goalPlayerArray count];
    }else if(tableView == self.assistPlayerTableView)
    {
        return [self.assistPlayerArray count];
    }else if(tableView == self.playerTableView)
    {
        return [self.playerScoreArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UILabel *nameLabel = (id)[cell.contentView viewWithTag:0xF2];
    UILabel *numLabel = (id)[cell.contentView viewWithTag:0xF3];
    NSArray *playArray = nil;
    if (tableView == self.goalPlayerTableView) {
        playArray = self.goalPlayerArray ;
        numLabel.hidden = NO;
    }else if(tableView == self.assistPlayerTableView)
    {
        playArray =  self.assistPlayerArray;
        numLabel.hidden = NO;
    }else if(tableView == self.playerTableView)
    {
        playArray = self.playerScoreArray ;
        numLabel.hidden = YES;
    }
    
    
    if(playArray == nil)
    {
        nameLabel.text = @"";
        numLabel.text = @"";
    }else
    {
        PlayerScore *player = [playArray objectAtIndex:indexPath.row];
        nameLabel.text = player.player.nickname ? player.player.nickname : player.player.username;
        if (tableView == self.goalPlayerTableView)
        {
            numLabel.text = [NSString stringWithFormat:@"%d", player.goals.intValue];
        }else if(tableView == self.assistPlayerTableView)
        {
            numLabel.text = [NSString stringWithFormat:@"%d", player.assists.intValue];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    [cell.contentView viewWithTag:0xF0].frame = cell.contentView.bounds;
    switch (indexPath.row) {
        case 0:
        {
            self.goalPlayerTableView = (id)[cell.contentView viewWithTag:0xF0];
            UILabel *titleLabel = (id)[self.goalPlayerTableView.tableHeaderView viewWithTag:0xF1];
            titleLabel.text = @"射手榜";
        }
            break;
        case 1:
        {
            self.assistPlayerTableView = (id)[cell.contentView viewWithTag:0xF0];
            UILabel *titleLabel = (id)[self.assistPlayerTableView.tableHeaderView viewWithTag:0xF1];
            titleLabel.text = @"助攻榜";
        }
            break;
        case 2:
        {
            self.playerTableView = (id)[cell.contentView viewWithTag:0xF0];
            UILabel *titleLabel = (id)[self.playerTableView.tableHeaderView viewWithTag:0xF1];
            titleLabel.text = @"出场名单";
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BDLog(@"scrollView contentOffset %@", NSStringFromCGPoint(scrollView.contentOffset));
}












#pragma mark - share

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
    
    
    self.shareTitle=@"比赛报告";
    self.shareContent=[NSString stringWithFormat:@"昨天已经过去，未来继续拼搏,%@VS%@比赛圆满结束了，我们一起来看精彩记录吧!",self.match.home_court.name,self.match.opponent.name];
    self.shareUrl=[NSString stringWithFormat:@"http://tq.codenow.cn/share/GameData?game=%@&team=%@",self.match.objectId,self.match.home_court.objectId];
    
    if (type == ShareTypeSMS || type == ShareTypeSinaWeibo) {
        self.shareContent = [NSString stringWithFormat:@"%@ %@",self.shareContent,self.shareUrl];
    }
    
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
                                     BDLog(@"发布失败!error code == %ld, error code == %@",(long) [error errorCode], [error errorDescription]);
                                 }
                             }];
    
    
}



@end

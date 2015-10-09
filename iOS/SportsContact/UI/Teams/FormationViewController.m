//
//  FormationViewController.m
//  SportsContact
//
//  Created by Nero on 7/22/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "FormationViewController.h"
#import "Util.h"
#import "ViewUtil.h"
#import "TeamEngine.h"
#import "LineupItemView.h"
#import "NoticeManager.h"
#import "CHTumblrMenuView.h"
#import <ShareSDK/ShareSDK.h>


#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"
//#define TITLE @"测试_Title"
//#define CONTENT @"测试_Content"
//#define URL @"http://www.baidu.com"


//2-5，2-5，1-4

//后卫
#define LineupBackMax 5
#define LineupBackMin 2
//中场
#define LineupStrikerMax 5
#define LineupStrikerMin 2
//前锋
#define LineupForwardMax 4
#define LineupForwardMin 1

@interface FormationViewController () <UITableViewDelegate, UITableViewDataSource, LineupItemViewDelegate>


@property (nonatomic) BOOL isCaptainBool;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UIView *freeMembersView;
@property (weak, nonatomic) IBOutlet UIButton *backerButton;
@property (weak, nonatomic) IBOutlet UIButton *strikerButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UIView *popToolView;
@property (weak, nonatomic) IBOutlet UIPickerView *valuePicker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *pitchView;
@property (weak, nonatomic) IBOutlet UITableView *freeMembersTableView;

@property (nonatomic, assign) PositioningType settingType;
@property (nonatomic, weak) LineupItemView *settingItem;

//守门员
@property (nonatomic, strong) LineupItemView *goalkeeperView;
//后卫
@property (nonatomic, strong) NSMutableArray *backItemViews;
//中场
@property (nonatomic, strong) NSMutableArray *strikerItemViews;
//前锋
@property (nonatomic, strong) NSMutableArray *forwardItemViews;

@property (nonatomic, strong) NSArray *teamMembers;
//空闲人员
@property (nonatomic, strong) NSMutableArray *freeMembers;

//@property (nonatomic, strong) UserInfo *goalkeeper;
//@property (nonatomic, strong) NSMutableArray *backMembers;
//@property (nonatomic, strong) NSMutableArray *strikerMembers;
//@property (nonatomic, strong) NSMutableArray *forwardMembers;

@property (nonatomic) NSInteger backCountNum;
@property (nonatomic) NSInteger strikerCountNum;
@property (nonatomic) NSInteger forwardCountNum;
@property (nonatomic) NSInteger buttonTag;
@property (nonatomic) NSInteger pickerRow;
@property (nonatomic, strong) NSArray *countArr;
@property (nonatomic, strong) NSArray *finalCountArr;



@property (strong, nonatomic)  NSString *shareTitle;
@property (strong, nonatomic)  NSString *shareContent;
@property (strong, nonatomic)  NSString *shareUrl;



@end

@implementation FormationViewController

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
    
    
    if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
    {
        self.isCaptainBool=YES;
    }
    else
    {
        self.isCaptainBool=NO;
    }

    
    
    
    // Do any additional setup after loading the view.
//    self.countArr = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",nil];
    if (![ViewUtil is4Inch])
    {
        [self.scrollView setContentSize:CGSizeMake(320.0, 506.0)];
    }
    
    
    self.backCountNum = self.lineup ? [(NSArray*)self.lineup.back count] : 4;
    self.strikerCountNum = self.lineup ? [(NSArray*)self.lineup.striker count] : 4;
    self.forwardCountNum = self.lineup ? [(NSArray*)self.lineup.forward count] : 2;
    [self.backerButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.backCountNum] forState:UIControlStateNormal];
    [self.strikerButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.strikerCountNum] forState:UIControlStateNormal];
    [self.forwardButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.forwardCountNum] forState:UIControlStateNormal];
    
    
    //topBarList
    UIView *toolView = [self.popToolView viewWithTag:0xF0];
    [ViewUtil addSingleTapGestureForView:toolView target:self action:@selector(hidePopToolView)];
    

    
    if (self.isCaptainBool)
    {
        UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
        [rButton setTitle:@"发布" forState:UIControlStateNormal];
        [rButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
        

    }
    
    
    
    self.backItemViews = [NSMutableArray arrayWithCapacity:0];
    self.strikerItemViews = [NSMutableArray arrayWithCapacity:0];
    self.forwardItemViews = [NSMutableArray arrayWithCapacity:0];
    
    self.goalkeeperView = [[LineupItemView alloc] initWithFrame:CGRectMake((self.pitchView.bounds.size.width - 60.0) / 2.0, 4.0, 60, 60)];
    self.goalkeeperView.delegate = self;
    [self.pitchView addSubview:self.goalkeeperView];
    
    
    [ViewUtil addSingleTapGestureForView:[self.freeMembersView viewWithTag:0xF0] target:self action:@selector(hideFreeMembersView)];
    
    [self reloadLineupView];
    [self loadTeamMembers];
    if (!self.lineup)
    {
        [self loadTeamLineup];
    }
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

#pragma mark - Private mothed

-(void)loadTeamLineup
{
    [self showLoadingView];
    [TeamEngine getLineupWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error)
     {
         [self hideLoadingView];
         if (!error)
         {
             self.lineup = result;
             [self reloadLineupView];
         }
         else
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }
     }];
}


- (void)loadTeamMembers
{
    [self showLoadingView];
    [TeamEngine getTeamMembersWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error)
    {
        [self hideLoadingView];
        if (error)
        {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            self.teamMembers = result;
            self.freeMembers = [NSMutableArray arrayWithArray:result];
            [self reloadFreeMembers];
        }
        
    }];
}

- (void)reloadFreeMembers
{
    NSMutableArray *freeMembers = [NSMutableArray arrayWithArray:self.teamMembers];
    if (self.goalkeeperView.userInfo) {
        [freeMembers removeObject:self.goalkeeperView.userInfo];
    }
    for (LineupItemView *itemView in self.backItemViews) {
        if (itemView.userInfo) {
            [freeMembers removeObject:itemView.userInfo];
        }
    }
    for (LineupItemView *itemView in self.strikerItemViews) {
        if (itemView.userInfo) {
            [freeMembers removeObject:itemView.userInfo];
        }
    }
    for (LineupItemView *itemView in self.forwardItemViews) {
        if (itemView.userInfo) {
            [freeMembers removeObject:itemView.userInfo];
        }
    }
    self.freeMembers = freeMembers;
    [self.freeMembersTableView reloadData];
}

- (void)reloadLineupItemViewWithPositioningType:(PositioningType )positioningType
{
    NSMutableArray *array = nil;
     NSInteger count = 0;
    float y = 0;
    switch (positioningType) {
        case PositioningTypeBack:
            array = self.backItemViews;
            count = self.backCountNum;
            y = self.pitchView.bounds.size.height * 1.0/4.0 + 18.0;
            break;
        case PositioningTypeMidfielder:
            array = self.strikerItemViews;
            count = self.strikerCountNum;
            y = self.pitchView.bounds.size.height / 2.0 + 18.0;
            break;
        case PositioningTypeForward:
            array = self.forwardItemViews;
            count = self.forwardCountNum;
            y = self.pitchView.bounds.size.height * 3.0/4.0+ 18.0;
            break;
            
        default:
            break;
    }
    int diff = (int) (count - [array count]);
    if (diff > 0)
    {
        for (int i = 0;  i < diff; i ++) {
            LineupItemView *view = [[LineupItemView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
            [array addObject:view];
            [self.pitchView addSubview:view];
        }
    }else if (diff < 0)
    {
        for (int i = 0;  i < -diff; i ++)
        {
            UIView *view = [array lastObject];
            [view removeFromSuperview];
            [array removeObject:view];
        }
    }
    float space = self.pitchView.bounds.size.width / count;
    for (int i = 0; i < [array count]; i ++) {
        LineupItemView *itemView = [array objectAtIndex:i];
        itemView.delegate = self;
        float x = space * i + space / 2.0;
        itemView.center = CGPointMake(x, y);
    }
    
    [self reloadFreeMembers];
    
}

- (void)showFreeMembersView
{
//    self.freeMembersTableView.superview.hidden = NO;
    self.freeMembersView.hidden = NO;
    UIView *bgView = [self.freeMembersView viewWithTag:0xF0];
    UIView *contentView = [self.freeMembersView viewWithTag:0xF1];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = contentView.frame;
        frame.origin.x = self.freeMembersView.frame.size.width - frame.size.width;
        contentView.frame = frame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
             bgView.alpha = 1.0;
        } completion:nil];
    }];
}

- (void)hideFreeMembersView
{
    
    UIView *bgView = [self.freeMembersView viewWithTag:0xF0];
    UIView *contentView = [self.freeMembersView viewWithTag:0xF1];
    [UIView animateWithDuration:0.2 animations:^{
        bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = contentView.frame;
            frame.origin.x = self.freeMembersView.frame.size.width;
            contentView.frame = frame;
        } completion:^(BOOL finished)
        {
             self.freeMembersView.hidden = YES;
        }];
       
    }];
}

- (void)showPopToolView
{
    self.popToolView.frame = self.tabBarController.view.bounds;
    [self.tabBarController.view addSubview:self.popToolView];
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
}

- (NSInteger )maxOfLineupItemWithPositioningType:(PositioningType )positioningType
{
    switch (positioningType) {
        case PositioningTypeBack:
        {
//            NSInteger max = self.backCountNum + self.freeMembers.count;
//            max = max > 5 ? 5 : max;
            NSInteger max = LineupBackMax;
            max = max > (10 - self.strikerCountNum - self.forwardCountNum) ?(10 - self.strikerCountNum - self.forwardCountNum) : max;
            return max;
        }
            break;
        case PositioningTypeMidfielder:
        {
//            NSInteger max = self.strikerCountNum + self.freeMembers.count;
//            max = max > 5 ? 5 : max;
            NSInteger max = LineupStrikerMax;
            max = max > (10 - self.backCountNum - self.forwardCountNum) ?(10 - self.backCountNum - self.forwardCountNum) : max;
            return max;
        }
            break;
        case PositioningTypeForward:
        {
//            NSInteger max = self.forwardCountNum + self.freeMembers.count;
//            max = max > 5 ? 5 : max;
            NSInteger max = LineupForwardMax;
            max = max > (10 - self.backCountNum - self.strikerCountNum) ?(10 - self.backCountNum - self.strikerCountNum) : max;
            return max;
        }
            break;
            
        default:
            return 1;
            break;
    }
}

- (void)reloadLineupView
{
    [self reloadLineupItemViewWithPositioningType:PositioningTypeBack];
    [self reloadLineupItemViewWithPositioningType:PositioningTypeMidfielder];
    [self reloadLineupItemViewWithPositioningType:PositioningTypeForward];
    if (self.lineup.goalkeeper) {
        self.goalkeeperView.userInfo = self.lineup.goalkeeper;
    }
    for (int i = 0; i < [(NSArray *)self.lineup.back count]; i ++)
    {
        id user = [(NSArray *)self.lineup.back objectAtIndex:i];
        [[self.backItemViews objectAtIndex:i] setUserInfo:user];
    }
    for (int i = 0; i < [(NSArray *)self.lineup.striker count]; i ++)
    {
        id user = [(NSArray *)self.lineup.striker objectAtIndex:i];
        [[self.strikerItemViews objectAtIndex:i] setUserInfo:user];
    }
    for (int i = 0; i < [(NSArray *)self.lineup.forward count]; i ++)
    {
        id user = [(NSArray *)self.lineup.forward objectAtIndex:i];
        [[self.forwardItemViews objectAtIndex:i] setUserInfo:user];
    }
}

- (void)addLineupPubPush
{
    UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
    Notice *msg = [[Notice alloc] init];
//    msg.aps = [ApsInfo apsInfoWithAlert:@"队长提交了球队阵容" badge:0 sound:nil];
    msg.aps = [ApsInfo apsInfoWithAlert:@"更新了首发阵容" badge:0 sound:nil];
    msg.time = [[NSDate date] timeIntervalSince1970];
    msg.belongId = selfUser.username;
    msg.targetId = self.teamInfo.objectId;
    msg.title = self.teamInfo.name;
    //    msg.content = content;
    msg.type = NoticeTypeTeam;
    msg.subtype = NoticeSubtypeTeamLineupPub;
    
    [[NoticeManager sharedManager] pushNotice:msg toTeam:self.teamInfo.objectId];
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

#pragma mark - Data order

//计算更新的后卫增量数组
- (NSArray *)backerAddArray
{
    NSMutableArray *backerAddArray = [NSMutableArray arrayWithCapacity:0];
    for (LineupItemView *view in self.backItemViews)
    {
        if (view.userInfo)
        {
            BOOL exist = NO;
            for (UserInfo *user in (NSArray *)self.lineup.back)
            {
                if ([user.objectId isEqualToString:view.userInfo.objectId])
                {
                    exist = YES;
                    break ;
                }
            }
            if (exist)
            {
                continue ;
            }
            [backerAddArray addObject:view.userInfo.objectId];
        }
    }
    
    return backerAddArray;
}

- (NSArray *)backerRmArray
{
   NSMutableArray *backerRmArray = [NSMutableArray arrayWithCapacity:0];
    for (UserInfo *user in (NSArray *)self.lineup.back)
    {
        
            BOOL exist = NO;
            for (LineupItemView *view in self.backItemViews)
            {
                if (view.userInfo.objectId && [user.objectId isEqualToString:view.userInfo.objectId])
                {
                    exist = YES;
                    break ;
                }
            }
            if (exist)
            {
                continue ;
            }
            [backerRmArray addObject:user.objectId];
    }
    
    return backerRmArray;
}

//计算更新的中场增量数组
- (NSArray *)strikerAddArray
{
    NSMutableArray *strikerAddArray = [NSMutableArray arrayWithCapacity:0];
    for (LineupItemView *view in self.strikerItemViews)
    {
        if (view.userInfo)
        {
            BOOL exist = NO;
            for (UserInfo *user in (NSArray *)self.lineup.striker)
            {
                if ([user.objectId isEqualToString:view.userInfo.objectId])
                {
                    exist = YES;
                    break ;
                }
            }
            if (exist)
            {
                continue ;
            }
            [strikerAddArray addObject:view.userInfo.objectId];
        }
    }
    
    return strikerAddArray;
}
- (NSArray *)strikerRmArray
{
    NSMutableArray *strikerRmArray = [NSMutableArray arrayWithCapacity:0];
    for (UserInfo *user in (NSArray *)self.lineup.striker)
    {
        
        BOOL exist = NO;
        for (LineupItemView *view in self.strikerItemViews)
        {
            if (view.userInfo.objectId && [user.objectId isEqualToString:view.userInfo.objectId])
            {
                exist = YES;
                break ;
            }
        }
        if (exist)
        {
            continue ;
        }
        [strikerRmArray addObject:user.objectId];
    }
    
    return strikerRmArray;
}

//计算更新的前锋增量数组
- (NSArray *)forwardAddArray
{
    NSMutableArray *forwardAddArray = [NSMutableArray arrayWithCapacity:0];
    for (LineupItemView *view in self.forwardItemViews)
    {
        if (view.userInfo)
        {
            BOOL exist = NO;
            for (UserInfo *user in (NSArray *)self.lineup.forward)
            {
                if ([user.objectId isEqualToString:view.userInfo.objectId])
                {
                    exist = YES;
                    break ;
                }
            }
            if (exist)
            {
                continue ;
            }
            [forwardAddArray addObject:view.userInfo.objectId];
        }
    }
    
    return forwardAddArray;
}
- (NSArray *)forwardRmArray
{
    NSMutableArray *forwardRmArray = [NSMutableArray arrayWithCapacity:0];
    for (UserInfo *user in (NSArray *)self.lineup.forward)
    {
        
        BOOL exist = NO;
        for (LineupItemView *view in self.forwardItemViews)
        {
            if (view.userInfo.objectId && [user.objectId isEqualToString:view.userInfo.objectId])
            {
                exist = YES;
                break ;
            }
        }
        if (exist)
        {
            continue ;
        }
        [forwardRmArray addObject:user.objectId];
    }
    
    return forwardRmArray;
}


#pragma mark - Event handler

-(void)onSave:(id)sender
{
    
    NSArray *backerAddArray = [self backerAddArray];
    NSArray *backerRmArray = [self backerRmArray];
    NSArray *strikerAddArray = [self strikerAddArray];
    NSArray *strikerRmArray = [self strikerRmArray];
    NSArray *forwardAddArray = [self forwardAddArray];
    NSArray *forwardRmArray = [self forwardRmArray];
 
    
    if (self.lineup)
    {
        BmobObject *lineup = [BmobObject objectWithoutDatatWithClassName:kTableLineup objectId:self.lineup.objectId];
        if (self.goalkeeperView.userInfo)
        {
            [lineup setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.goalkeeperView.userInfo.objectId] forKey:@"goalkeeper"];
        }
        BmobRelation *backRelation = [BmobRelation relation];
        for (NSString *userId in backerAddArray)
        {
            [backRelation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
        }
        [lineup addRelation:backRelation forKey:@"back"];
        
        BmobRelation *strikerRelation = [BmobRelation relation];
        for (NSString *userId in strikerAddArray) {
            [strikerRelation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
        }
        
        [lineup addRelation:strikerRelation forKey:@"striker"];
        
        BmobRelation *forwardRelation = [BmobRelation relation];
        for (NSString *userId in forwardAddArray) {
            [forwardRelation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
        }
        
        [lineup addRelation:forwardRelation forKey:@"forward"];
        
        [lineup updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful)
            {
                BmobRelation *backRmRelation = [BmobRelation relation];
                for (NSString *userId in backerRmArray)
                {
                    [backRmRelation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
                }
                [lineup addRelation:backRmRelation forKey:@"back"];
                
                BmobRelation *strikerRmRelation = [BmobRelation relation];
                for (NSString *userId in strikerRmArray)
                {
                    [strikerRmRelation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
                }
                [lineup addRelation:strikerRmRelation forKey:@"striker"];
                
                BmobRelation *forwardRmRelation = [BmobRelation relation];
                for (NSString *userId in forwardRmArray)
                {
                    [forwardRmRelation removeObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
                }
                [lineup addRelation:forwardRmRelation forKey:@"forward"];
                
                [lineup updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                {
                    [self showMessage:@"成功保存"];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    [self addLineupPubPush];

                }];
            }else
            {
                [self showMessage:[Util errorStringWithCode:error.code]];
            }
        }];
        
    }else
    {
        BmobObject *lineup = [BmobObject objectWithClassName:kTableLineup];
        [lineup setObject:[BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.teamInfo.objectId] forKey:@"team"];
        if (self.goalkeeperView.userInfo)
        {
            [lineup setObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:self.goalkeeperView.userInfo.objectId] forKey:@"goalkeeper"];
        }
        BmobRelation *backRelation = [BmobRelation relation];
        for (NSString *userId in backerAddArray)
        {
            [backRelation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
        }
        [lineup addRelation:backRelation forKey:@"back"];
        
        BmobRelation *strikerRelation = [BmobRelation relation];
        for (NSString *userId in strikerAddArray) {
            [strikerRelation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
        }
        [lineup addRelation:strikerRelation forKey:@"striker"];
        
        BmobRelation *forwardRelation = [BmobRelation relation];
        for (NSString *userId in forwardAddArray) {
            [forwardRelation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
        }
        [lineup addRelation:forwardRelation forKey:@"forward"];
        [lineup saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful)
            {
                self.lineup = [[Lineup alloc] initWithDictionary:lineup];
                [self showMessage:@"成功保存"];
                [self addLineupPubPush];
                [self.navigationController popViewControllerAnimated:YES];

            }else
            {
                [self showMessage:[Util errorStringWithCode:error.code]];
            }
        }];
    }
    
    

}

- (void)updateRelationOfLineup:(BmobObject *)lineup withResultBlock:(BmobBooleanResultBlock)block;
{
    NSMutableArray *backUserIdArray = [NSMutableArray arrayWithCapacity:0];
    for (LineupItemView *view in self.backItemViews) {
        if (view.userInfo)
        {
            [backUserIdArray addObject:view.userInfo.objectId];
        }
    }
    
    BmobRelation *relation = [BmobRelation relation];
    for (NSString *userId in backUserIdArray) {
        [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:userId]];
    }
    
    [lineup addRelation:relation forKey:@"back"];
    //异步更新obj的数据
    [lineup updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        BDLog(@"error %@",[error description]);
    }];
    
}

- (IBAction)backBtnClick:(id)sender {
    
    if (self.isCaptainBool)
    {
        self.settingType = PositioningTypeBack;
        [self.valuePicker reloadAllComponents];
        [self.valuePicker selectRow:self.backCountNum inComponent:0 animated:YES];
        self.pickerRow = self.backCountNum;
        [self showPopToolView];

    }
    
}

- (IBAction)strikerBtnClick:(id)sender {
    
    if (self.isCaptainBool)
    {
        self.settingType = PositioningTypeMidfielder;
        [self.valuePicker reloadAllComponents];
        [self.valuePicker selectRow:self.strikerCountNum inComponent:0 animated:YES];
        self.pickerRow = self.strikerCountNum;
        [self showPopToolView];

        
    }
}


- (IBAction)forwardBtnClick:(id)sender {
    
    if (self.isCaptainBool)
    {
        self.settingType = PositioningTypeForward;
        [self.valuePicker reloadAllComponents];
        [self.valuePicker selectRow:self.forwardCountNum inComponent:0 animated:NO];
        self.pickerRow = self.forwardCountNum;
        [self showPopToolView];

    }
    
}

#pragma mark - LineupItemViewDelegate

- (void)onClickAtlineupItemView:(LineupItemView *)lineupItemView
{
    if (self.isCaptainBool)
    {
        [self showFreeMembersView];
        self.settingItem = lineupItemView;

    }
    
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.freeMembers count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = @"清除";
    if (indexPath.row > 0) {
        UserInfo *member = [self.freeMembers objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = member.nickname;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 0) {
        UserInfo *member = [self.freeMembers objectAtIndex:indexPath.row - 1];
        self.settingItem.userInfo = member;
    }else
    {
        self.settingItem.userInfo = nil;
    }
    [self hideFreeMembersView];
    [self reloadFreeMembers];
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self maxOfLineupItemWithPositioningType:self.settingType] + 1;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", (long)row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickerRow = row;
}

#pragma mark pickerDelegate
- (IBAction)onPickerSure:(id)sender {
    switch (self.settingType)
    {
        case PositioningTypeBack:
            self.backCountNum = self.pickerRow;
            [self.backerButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.backCountNum] forState:UIControlStateNormal];
            break;
        case PositioningTypeMidfielder:
            self.strikerCountNum = self.pickerRow;
            [self.strikerButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.strikerCountNum] forState:UIControlStateNormal];
            break;
        case PositioningTypeForward:
            self.forwardCountNum = self.pickerRow;
            [self.forwardButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.forwardCountNum] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    [self reloadLineupItemViewWithPositioningType:self.settingType];
    [self hidePopToolView];
}

- (IBAction)onPickerCancel:(id)sender {
    
    [self hidePopToolView];
    
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
    
    self.shareTitle=@"球队阵容";
    self.shareUrl=[NSString stringWithFormat:@"http://tq.codenow.cn/share/GameLineup?team=%@",self.teamInfo.objectId];
    self.shareContent=[NSString stringWithFormat:@"『%@』球队的阵容是:%@",self.teamInfo.name,self.shareUrl];

    
    
    
    UIImage *image = [self getNormalImage:self.view];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    NSString *imagePath= [self saveToDisk:image];
    
    
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
//    id<ISSContent> publishContent = [ShareSDK content:CONTENT
//                                       defaultContent:@""
//                                                image:[ShareSDK imageWithPath:imagePath]
//                                                title:nil
//                                                  url:nil
//                                          description:nil
//                                            mediaType:SSPublishContentMediaTypeText];
    
    id<ISSContent> publishContent = [ShareSDK content:self.shareContent
                                       defaultContent:nil
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:self.shareTitle
                                                  url:self.shareUrl
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];

    
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
                                     BDLog(@"发表成功！");
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     BDLog(@"发表失败！");
                                 }
                             }];

    
}


//获取当前屏幕内容
- (UIImage *)getNormalImage:(UIView *)view{
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [UIScreen mainScreen].bounds.size.height-66;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSString *)saveToDisk:(UIImage *)image{
    
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    BDLog(@"保存路径：%@",dir);
    
    NSString *path = [NSString stringWithFormat:@"%@/pic_%f.png",dir,[NSDate timeIntervalSinceReferenceDate]];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];
    [data writeToFile:path atomically:YES];
    
    BDLog(@"保存完毕");
    
    return path;
}





@end

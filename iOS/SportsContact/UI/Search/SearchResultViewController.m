//
//  SearchResultViewController.m
//  SportsContact
//
//  Created by bobo on 14/11/22.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "SearchResultViewController.h"
#import "Util.h"
#import "InfoEngine.h"
#import "TeamEngine.h"
#import <UIImageView+WebCache.h>
#import "NoticeManager.h"

@interface SearchResultViewController ()

@property (nonatomic, strong) NSArray *teammates;
@property (nonatomic, strong) NSMutableArray *selectedRows;
@property (nonatomic ,strong) NSArray *friends;

@end

@implementation SearchResultViewController

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
//             if ([self.friends count]!=0 )
//             {
//                 //区别队友，好友
//                 [self loadTeammatesList];
//             }
             [self loadTeammatesList];
//             else
//             {
//                 UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-25.0, 320.0, 50.0f)];
//                 warningLabel.text = @"暂无好友！";
//                 warningLabel.textColor = [UIColor blackColor];
//                 warningLabel.textAlignment = NSTextAlignmentCenter;
//                 warningLabel.font = [UIFont boldSystemFontOfSize:20.0f];
//                 [self.view addSubview:warningLabel];
//             }
         }
     }];
}

-(void)loadTeammatesList
{
    if(self.teamInfo)
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

#pragma Event handler
-(void)onSure:(id)sender
{
    if (self.viewType == UserInfoViewTypeTeam) {
        //邀请球员入队，发送通知，同意再添加成功
        if ([self.selectedRows count] > 0)
        {
            for (NSNumber *row in self.selectedRows)
            {
                UserInfo *user = [self.result objectAtIndex:[row integerValue]];
                Notice *msg = [[Notice alloc] init];
                NSString *toUsername = nil;
                UserInfo *selfUser = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
                NSString *content = nil;
//                content = [NSString stringWithFormat:@"%@队长邀请您加入球队", self.teamInfo.name];
                content = [NSString stringWithFormat:@"邀请您加入%@", self.teamInfo.name];
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
    }else
    {
        if ([self.selectedRows count] > 0)
        {
            __block int count = (int)[self.selectedRows count];
            __block int successCount = 0;
            if (count > 0 )
            {
                 [self showLoadingView];
            }
            for (NSNumber *row in self.selectedRows)
            {
                UserInfo *user = [self.result objectAtIndex:[row integerValue]];
                BmobUser *curUser = [BmobUser getCurrentUser];
                BmobRelation *relation = [BmobRelation relation];
                [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:user.objectId]];
                [curUser addRelation:relation forKey:@"friends"];
               
                [curUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    
                    if (isSuccessful)
                    {
                        successCount ++;
                        [self addFriendPushWithUser:user];
                    }else
                    {
                        BDLog(@"add friend error %@",error);
                    }
                    count --;
                    if (count <= 0) {
                        [self addFriendCompleteWithSuccessCount:successCount];
                    }
                    
                }];
            }
        }
        
    }
    
}

- (void)addFriendCompleteWithSuccessCount:(int)successCount
{
    [self hideLoadingView];
    if (successCount > 0) {
        [self showMessage:[NSString stringWithFormat:@"成功添加%d名好友", successCount]];
        [self performRunnable:^{
            [self.navigationController popViewControllerAnimated:YES];
        } afterDelay:1.5f];
    }else
    {
        [self showMessage:@"好友添加失败！"];
    }
}


- (void)addFriendPushWithUser:(UserInfo *)user
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
    
    [[NoticeManager sharedManager] pushNotice:msg toUsername:user.username];
}



#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.result count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendsCell"];
    
    UserInfo *user = [self.result objectAtIndex:[indexPath row]];
    
    UIImageView *avatarImageView = (id)[cell.contentView viewWithTag:0xF0];
    
    [avatarImageView.layer setCornerRadius:avatarImageView.bounds.size.width/2.0f];
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avator.url] placeholderImage:[UIImage imageNamed:@"head.png"] completed:NULL];
    
    UILabel *nicknameLabel = (id)[cell.contentView viewWithTag:0xF1];
    if ([user.nickname length]!=0)
    {
        nicknameLabel.text = user.nickname;
    }
    else
    {
        nicknameLabel.text=user.username;
    }
    
    cell.userInteractionEnabled = YES;
    //显示好友or队友
    UILabel *relatedTypeLabel = (id)[cell.contentView viewWithTag:0xF2];
    relatedTypeLabel.text = @"";
    if (self.viewType == UserInfoViewTypeTeam) {
        for (UserInfo *friend in self.friends)
        {
            if ([user.objectId isEqualToString:friend.objectId])
            {
                relatedTypeLabel.text = @"好友";
                if (self.viewType == UserInfoViewTypeInfo) {
                    cell.userInteractionEnabled = NO;
                }
                break;
            }
        }
        for (UserInfo *teammate in self.teammates)
        {
            if ([user.objectId isEqualToString:teammate.objectId])
            {
                relatedTypeLabel.text = @"队友";
                if (self.viewType == UserInfoViewTypeTeam) {
                    cell.userInteractionEnabled = NO;
                }
                break;
            }
        }
    }else
    {
        for (UserInfo *friend in self.friends)
        {
            if ([user.objectId isEqualToString:friend.objectId])
            {
                relatedTypeLabel.text = @"好友";
                if (self.viewType == UserInfoViewTypeInfo) {
                    cell.userInteractionEnabled = NO;
                }
                break;
            }
        }
    }
    
    UIImageView *choseView = (id)[cell.contentView viewWithTag:0xF3];
    if ([self.selectedRows indexOfObject:@(indexPath.row)] == NSNotFound) {
        [choseView setImage:[UIImage imageNamed:@"addTM_chose.png"]];
    }else
    {
        [choseView setImage:[UIImage imageNamed:@"addTM_chose_.png"]];
    }
    
    UIButton *btn = (id)[cell.contentView viewWithTag:0xF5];
    NSIndexPath *indexPathCopy = [indexPath copy];
    __weak SearchResultViewController *wself = self;
    [self embeddedClickEvent:btn setBindingRunnable:^{
        if ([wself.selectedRows indexOfObject:@(indexPathCopy.row)] == NSNotFound)
        {
            [wself.selectedRows addObject:@(indexPathCopy.row)];
        }else
        {
            [wself.selectedRows removeObject:@(indexPathCopy.row)];
        }
        if ([wself.selectedRows count] > 0) {
            [wself enableRightButton];
        }else
        {
            [wself disenableRightButton];
        }
        [wself.tableView reloadRowsAtIndexPaths:@[indexPathCopy] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    [btn addTarget:self action:@selector(onEmbeddedClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Info" bundle:[NSBundle mainBundle]];
    UserInfo *user = [self.result objectAtIndex:[indexPath row]];
    UserInfoViewController *userInfo = [storyboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    [userInfo setValue:user forKey:@"userInfo"];
    [userInfo setValue:[NSNumber numberWithInteger:self.viewType] forKey:@"viewType"];
    BOOL isFriend = NO;
    for (UserInfo *friend in self.friends)
    {
        if ([user.objectId isEqualToString:friend.objectId])
        {
            isFriend = YES;
            break;
        }
    }
    [userInfo setValue:[NSNumber numberWithBool:isFriend] forKey:@"isFriend"];
    if (self.teamInfo) {
        [userInfo setValue:@[self.teamInfo] forKey:@"ownTeams"];
    }
    [self.navigationController pushViewController:userInfo animated:YES];
//    if ([self.selectedRows indexOfObject:@(indexPath.row)] == NSNotFound)
//    {
//        [self.selectedRows addObject:@(indexPath.row)];
//    }else
//    {
//        [self.selectedRows removeObject:@(indexPath.row)];
//    }
//    if ([self.selectedRows count] > 0) {
//        [self enableRightButton];
//    }else
//    {
//        [self disenableRightButton];
//    }
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end

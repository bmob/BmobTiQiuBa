//
//  FriendsViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-17.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "FriendsViewController.h"
#import "InfoEngine.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Util.h"
#import "UserSearchViewController.h"

@interface FriendsViewController ()

@property (nonatomic ,strong) NSArray *friends;

@end

@implementation FriendsViewController

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
    
    
    UIButton *rightBtn = [self rightButtonWithImage:[UIImage imageNamed:@"btn_add"] hightlightedImage:[UIImage imageNamed:@"btn_add_hl"]];
    [rightBtn addTarget:self action:@selector(onAddFriends:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.title = @"我的好友";
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadFriends];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)loadFriends
{
    [self showLoadingView];
    [InfoEngine getFriendsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error) {
        [self hideLoadingView];
        if (error)
        {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }else
        {
            self.friends = result;
            [self.tableView reloadData];
            if ([self.friends count] <= 0) {
                [self showMessage:@"暂无好友，点击右上角添加好友！"];
            }
        }
    }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friends_cell"];
    UserInfo *user = [self.friends objectAtIndex:[indexPath row]];
    UIImageView *avatarImageView = (id)[cell.contentView viewWithTag:0xF0];
    [avatarImageView.layer setCornerRadius:avatarImageView.bounds.size.width/2.0f];
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avator.url] placeholderImage:[UIImage defaultAvatarImage] completed:nil];
    UILabel *nicknameLabel = (id)[cell.contentView viewWithTag:0xF1];
    nicknameLabel.text = user.nickname ? user.nickname : user.username;
//    UILabel *relatedTypeLabel = (id)[cell.contentView viewWithTag:0xF2];
    
//#warning set related text
//    relatedTypeLabel.text = @"朋友";
//    for ([user.team objectId]) {
//        <#statements#>
//    }
//    if (user.team && [user.team.objectId isEqualToString:[[[BmobUser getCurrentUser] objectForKey:@"team"] objectId]]) {
//        relatedTypeLabel.text = @"队友";
//    }else
//    {
//         relatedTypeLabel.text = @"朋友";
//    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"push_info"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UserInfo *user = [self.friends objectAtIndex:[indexPath row]];
        
        [segue.destinationViewController setValue:user forKey:@"userInfo"];
        [segue.destinationViewController setValue:[NSNumber numberWithInteger:UserInfoViewTypeInfo] forKey:@"viewType"];
        [segue.destinationViewController setValue:[NSNumber numberWithBool:YES] forKey:@"isFriend"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)onAddFriends:(id)sender
{
    [InfoEngine getFriendsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error)
     {
         if (!error)
         {
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:[NSBundle mainBundle]];
             UserSearchViewController *searchViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserSearchViewController"];
             searchViewController.viewType = UserInfoViewTypeInfo;
             searchViewController.friends = result;
             [self.navigationController pushViewController:searchViewController animated:YES];
         }else
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }
     }];
}
@end

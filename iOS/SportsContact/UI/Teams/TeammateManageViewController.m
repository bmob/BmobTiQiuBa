//
//  TeammateManageViewController.m
//  SportsContact
//
//  Created by Nero on 7/30/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "TeammateManageViewController.h"

#import <BmobSDK/Bmob.h>
#import <BmobSDK/BmobUser.h>

#import "DataDef.h"
#import <UIImageView+WebCache.h>
#import "Util.h"

#import "UserSearchViewController.h"
#import "UserInfoViewController.h"


#import "TeamEngine.h"
#import "InfoEngine.h"


@interface TeammateManageViewController ()


@property (nonatomic,strong) Team *teamInfo;
@property (nonatomic ,strong) NSMutableArray *teammateArr;
@property (weak, nonatomic) IBOutlet UITableView *teammateTableview;

@property (nonatomic) BOOL isInTheTeamBool;


@end



@implementation TeammateManageViewController

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

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
    {
        
        //队长编辑权限
        UIButton *rightBtn = [self rightButtonWithImage:[UIImage imageNamed:@"btn_add"] hightlightedImage:[UIImage imageNamed:@"btn_add_hl"]];
        [rightBtn addTarget:self action:@selector(onSetting:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        
        
    }
    else
    {
        
    }
    
    
    
    
    
    self.teammateArr = [NSMutableArray array];
    
    
    
    //    BmobObject *team = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.teamInfo.objectId];
    //    //新建relation对象
    //    BmobRelation *relation = [BmobRelation relation];
    //    //relation添加id为25fb9b4a61的用户
    //    [relation addObject:[BmobUser objectWithoutDatatWithClassName:nil objectId:@"fwXuDDDP"]];   //obj 添加关联关系到footballer列中
    //    [team addRelation:relation forKey:@"footballer"];
    //    //异步更新team的数据
    //    [team updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    //     {
    //         BDLog(@"error %@",[error description]);
    //
    //
    //
    //     }];
    
    
    
    
    //    [self showLoadingView];
    //    BDLog(@"********%@  %@",self.teamInfo.objectId,self.teamInfo.name);
    //
    //    BmobQuery *bquery = [BmobQuery queryForUser];
    //    [bquery orderByDescending:@"updatedAt"];
    //    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:kTableTeam objectId:self.teamInfo.objectId];
    //    [bquery whereObjectKey:@"footballer" relatedTo:obj];
    //    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
    //
    //
    //        BDLog(@"************%lu",(unsigned long)[array count]);
    //
    //
    //        self.teammateArr=array;
    //        [self.teammateTableview reloadData];
    //
    //        [self hideLoadingView];
    //
    //
    //    }];
    
    
    
    
    [self showLoadingView];
    
    
    //获取球队全部成员
    [TeamEngine getTeamMembersWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error) {
        
        
        
        for (UserInfo *user in result)
        {
            
            if ([[[BmobUser getCurrentUser] objectId] isEqualToString:user.objectId])
            {
                
                self.isInTheTeamBool=YES;
                break;
            }
            else
            {
                self.isInTheTeamBool=NO;
            }
            
            
        }
        
        
        
        
        if ([self.title isEqualToString:@"球队成员"])
        {
            
            self.teammateArr=result;
            
            
            if ([self.teammateArr count]!=0)
            {
                [self.teammateTableview reloadData];
                
            }
            else
            {
                [self showMessage:@"暂无成员列表！"];
            }
            
            
            
            
        }
        else if([self.title isEqualToString:@"我的球队"])
        {
            
            
            
            
            self.teammateArr=result;
            
            [self.teammateTableview reloadData];
            
            if ([self.teammateArr count]==1)
            {
                [self showMessage:@"暂无其他队友，点击右上角添加队友！"];
            }
            
            
            
        }
        else
        {
            
        }
        
        
        
        
        
        
        
        [self hideLoadingView];
        
        
        
    }];
    
    
    
    
    
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


-(void)onSetting:(id)sender
{
    [InfoEngine getFriendsWithUser:[BmobUser getCurrentUser] block:^(id result, NSError *error)
     {
         if (!error)
         {
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:[NSBundle mainBundle]];
             UserSearchViewController *searchViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserSearchViewController"];
             searchViewController.viewType = UserInfoViewTypeTeam;
             searchViewController.teamInfo = self.teamInfo;
             searchViewController.friends = result;
             [self.navigationController pushViewController:searchViewController animated:YES];
         }else
         {
             [self showMessage:[Util errorStringWithCode:error.code]];
         }
     }];
    
}


#pragma mark tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.teammateArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserInfo *user=[self.teammateArr objectAtIndex:[indexPath row]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"teammateCell"];
    UIImageView *avatarImageView = (id)[cell.contentView viewWithTag:0xF0];
    [avatarImageView.layer setCornerRadius:avatarImageView.bounds.size.width/2.0f];
    
    BmobFile *imageFile=user.avator;
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageFile.url] completed:nil];

    
    
    UILabel *numberLabel = (id)[cell.contentView viewWithTag:0xF3];
    numberLabel.text=[NSString stringWithFormat:@"%ld",(long)(indexPath.row+1)];
    
    UILabel *nicknameLabel = (id)[cell.contentView viewWithTag:0xF1];
    if (user.nickname)
    {
        nicknameLabel.text=user.nickname;
    }
    else
    {
        nicknameLabel.text=user.username;
    }

    
    
    
    
    
    
 

    
    
    
    UILabel *menberLabel = (id)[cell.contentView viewWithTag:0xF2];
    
    menberLabel.textColor=[UIColor lightGrayColor];

    if ([self.title isEqualToString:@"球队成员"])
    {

        if (self.isInTheTeamBool)
        {
            menberLabel.hidden=NO;
            

            if ([user.objectId isEqualToString:self.teamInfo.captain.objectId])
            {
                menberLabel.text=@"队长";
                
                [menberLabel setTextColor:UIColorFromRGB(0xFFAE01)];
            }
            else
            {
                menberLabel.text=@"队友";
            }

            

        }
        else
        {
            
            
            if ([user.objectId isEqualToString:self.teamInfo.captain.objectId])
            {
                menberLabel.hidden=NO;

                menberLabel.text=@"队长";
                [menberLabel setTextColor:UIColorFromRGB(0xFFAE01)];

                

            }
            else
            {
                menberLabel.hidden=YES;

            }


        }
        
        
        

        
    }
    else if([self.title isEqualToString:@"我的球队"])
    {
        menberLabel.hidden=NO;
        
        menberLabel.text=@"队友";
        
        
        
    }
    else
    {
        
    }

    
    
    
    //自己的不可点
    if ([[[BmobUser getCurrentUser] objectId] isEqualToString:user.objectId])
    {
        cell.userInteractionEnabled=NO;
        
        menberLabel.hidden=NO;
        
        menberLabel.text=@"自己";
        [menberLabel setTextColor:UIColorFromRGB(0xFFAE01)];


        
    }
    else
    {
        cell.userInteractionEnabled=YES;
        
        
    }

    
    
    
    
    
    

    return cell;

    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *centerStoryboard = [UIStoryboard storyboardWithName:@"Info" bundle:[NSBundle mainBundle]];
    UserInfoViewController *userViewController = [centerStoryboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    UserInfo *user = [self.teammateArr objectAtIndex:[indexPath row]];
    userViewController.userInfo = user;
    userViewController.isTeammate = YES;
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
            if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
            {
                userViewController.viewType = UserInfoViewTypeTeam;
                userViewController.ownTeams = @[self.teamInfo];
            }else
            {
                userViewController.viewType = UserInfoViewTypeInfo;
            }
            [self.navigationController pushViewController:userViewController animated:YES];
        }else
        {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }
    }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    

    
//    if ([segue.identifier isEqualToString:@"push_teammateInfo"])
//    {
//        NSIndexPath *indexPath = [self.teammateTableview indexPathForSelectedRow];
//        UserInfo *user = [self.teammateArr objectAtIndex:[indexPath row]];
//        
//        [segue.destinationViewController setValue:user forKey:@"userInfo"];
//        [segue.destinationViewController setValue:[NSNumber numberWithBool:YES] forKey:@"isForOthers"];
//        [segue.destinationViewController setValue:[NSNumber numberWithBool:YES] forKey:@"isFriend"];
//        
//        [segue.destinationViewController setValue:[NSNumber numberWithBool:YES] forKey:@"isTeammateClickPush"];
//        
//        [segue.destinationViewController setValue:self.teamInfo.objectId forKey:@"teamId"];
//
//        [segue.destinationViewController setValue:user.objectId forKey:@"footballerId"];
//
//
//        
//        if ([[[BmobUser getCurrentUser] objectId] isEqualToString:self.teamInfo.captain.objectId])
//        {
//            [segue.destinationViewController setValue:[NSNumber numberWithBool:YES] forKey:@"isCaptionClickPush"];
//        }
//        else
//        {
//            [segue.destinationViewController setValue:[NSNumber numberWithBool:NO] forKey:@"isCaptionClickPush"];
//        }
//        
//        
//        
//        
//        
//    }

    
    

    
}



@end

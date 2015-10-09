//
//  ChangeCaptainViewController.m
//  SportsContact
//
//  Created by Nero on 8/9/14.
//  Copyright (c) 2014 CAF. All rights reserved.
//

#import "ChangeCaptainViewController.h"
#import "Util.h"
#import "TeamEngine.h"
#import <UIImageView+WebCache.h>



@interface ChangeCaptainViewController ()


@property (nonatomic,strong) UserInfo *userInfo;
@property (nonatomic,strong) Team *teamInfo;
@property (nonatomic ,strong) NSArray *teammateArr;

@property (nonatomic ,strong) NSString *idString;
@property (nonatomic ,strong) NSString *captainName;



@property (weak, nonatomic) IBOutlet UITableView *teammateTableview;


@property (nonatomic) NSInteger selectIndex;
@property (nonatomic) BOOL isSelectedBool;



@end

@implementation ChangeCaptainViewController

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
    
    self.isSelectedBool=NO;
    
    [self loadTeamMenberList];
    
    
    UIButton *rButton = [self rightButtonWithColor:UIColorFromRGB(0xFFAE01) hightlightedColor:UIColorFromRGB(0xFFCF66)];
    [rButton setTitle:@"保存" forState:UIControlStateNormal];
    [rButton addTarget:self action:@selector(onSave:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadTeamMenberList
{
    
    [self showLoadingView];
    [TeamEngine getTeamMenberCountWithTeamId:self.teamInfo.objectId block:^(id result, NSError *error) {
        
        self.teammateArr=result;
        [self.teammateTableview reloadData];

        [self hideLoadingView];
        
    }];
    
    
}


- (void)onSave:(id)sender
{
    
    //修改球队信息，换队长
    [TeamEngine changeCaptainWithteamId:self.teamInfo.objectId captainUserid:self.idString block:^(id result, NSError *error) {
        
        
        if (!error)
        {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(valueSelection:changeCaptainId:)])
            {
            
//                [self.delegate valueSelection:self changeCaptainId:self.idString];
                [self.delegate valueSelection:self changeCaptainId:self.captainName];

                
                [self.navigationController popViewControllerAnimated:YES];
                
                [self showMessage:@"更换队长成功！"];
                
            }
            
        }
        else
        {
            [self showMessage:@"更换队长失败！"];
        }

        
        
        
        
    }];
    
    
    
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.userInfo=[self.teammateArr objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeCaptainCell"];
    
    
    
    UIImageView *avatarImageView = (id)[cell.contentView viewWithTag:0xF0];
    [avatarImageView.layer setCornerRadius:avatarImageView.bounds.size.width/2.0f];
    BmobFile *imageFile=self.userInfo.avator;
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageFile.url] completed:nil];
    
    
    UIImageView *line1 = (id)[cell.contentView viewWithTag:0xF4];
    UIImageView *line2 = (id)[cell.contentView viewWithTag:0xF5];
    
    BOOL isLast = indexPath.row == [self.teammateArr count]-1;
    line1.hidden = isLast;
    line2.hidden = !isLast;
    
    
    
    UILabel *nicknameLabel = (id)[cell.contentView viewWithTag:0xF2];
    if ([self.userInfo.nickname length]!=0)
    {
        nicknameLabel.text =self.userInfo.nickname;
    }
    else
    {
        nicknameLabel.text =self.userInfo.username;
    }
    
    
    
    
    UIImageView *choseView = (id)[cell.contentView viewWithTag:0xF3];
    if (self.isSelectedBool)
    {
        
        if (self.selectIndex == indexPath.row)
        {
            choseView.hidden = NO;
            
            self.idString=self.userInfo.objectId;
            
            if (self.userInfo.nickname)
            {
                self.captainName=self.userInfo.nickname;
            }
            else
            {
                self.captainName=self.userInfo.username;
            }
            
        }
        else
        {
            choseView.hidden = YES;

        }
        
        
    }
    else
    {
        
//        UserInfo *user=[self.teammateArr objectAtIndex:indexPath.row];
        BDLog(@"**********%@***********%@",self.teamInfo.captain.objectId,self.userInfo.objectId);
        
        if ([self.teamInfo.captain.objectId isEqualToString:self.userInfo.objectId])
        {
            choseView.hidden = NO;
        }else
        {
            choseView.hidden = YES;
        }

        
    }
    
    
    
    
    
    
    
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.teammateArr count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.isSelectedBool=YES;
    
    self.selectIndex = indexPath.row;
    
    [self.teammateTableview reloadData];
    
    
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

//
//  UserSearchViewController.m
//  SportsContact
//
//  Created by bobo on 14/11/22.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "UserSearchViewController.h"
#import "TeamEngine.h"
#import "InfoEngine.h"
#import "UserInfoViewController.h"
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import <TencentOpenAPI/QQApi.h>

#import <AGCommon/UINavigationBar+Common.h>
#import <AGCommon/UIImage+Common.h>
#import <AGCommon/UIDevice+Common.h>
#import <ShareSDK/ShareSDK.h>
#import <AGCommon/NSString+Common.h>

/**
 *  设置类型
 */
typedef NS_OPTIONS(NSInteger, SearchType) {
    SearchTypeFriends = 0,
    SearchTypeQQ,
    SearchTypeMPhone,
    SearchTypeWeixin,
    SearchTypeNum
};

static NSString *gSearchTypeTitleArray[SearchTypeNum] = {@"添加好友",@"添加QQ好友",@"添加手机联系人",@"添加微信好友"};
static NSString *gSearchTypeIconArray[SearchTypeNum] = {@"addTM_icon4.png",@"icon_qq.png",@"icon_phone.png",@"icon_wechat.png"};

@interface UserSearchViewController () <ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *dataSource;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;


@property (strong, nonatomic)  NSString *shareTitle;
@property (strong, nonatomic)  NSString *shareContent;
@property (strong, nonatomic)  NSString *shareUrl;



@end

@implementation UserSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.viewType == UserInfoViewTypeTeam) {
        self.dataSource = @[@(SearchTypeFriends), @(SearchTypeQQ), @(SearchTypeMPhone), @(SearchTypeWeixin)];
    }else
    {
         self.dataSource = @[@(SearchTypeMPhone), @(SearchTypeWeixin), @(SearchTypeQQ)];
    }
    
    // Do any additional setup after loading the view.
    
    
    if (self.viewType == UserInfoViewTypeTeam)
    {
        
        self.shareTitle=@"『踢球吧』球队邀请码";
        self.shareUrl=@"http://tq.codenow.cn/share/Download";
//        self.shareContent=[NSString stringWithFormat:@"%@邀请你加入球队，球队邀请码：%@  ,_链接：%@",self.teamInfo.name,self.teamInfo.objectId,self.shareUrl];
        
        UserInfo *userInfo = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
        NSString *name = userInfo.nickname?userInfo.nickname:userInfo.username;
        
        self.shareContent=[NSString stringWithFormat:@"%@邀请您下载踢球吧，加入%@队。请在注册时填写球队注册码%@。踢球吧，记录你的比赛！下载地址:%@",name,self.teamInfo.name,self.teamInfo.reg_code,self.shareUrl];
        
        
    }
    else if (self.viewType == UserInfoViewTypeInfo)
    {
        
        //个人中心进入
        
        self.shareTitle=@"『踢球吧』";
        self.shareUrl=@"http://tq.codenow.cn/share/Download";
//        self.shareContent=[NSString stringWithFormat:@"『踢球吧』欢迎你的加入！_链接：%@",self.shareUrl];
        
        UserInfo *userInfo = [[UserInfo alloc] initWithDictionary:[BmobUser getCurrentUser]];
        NSString *name = userInfo.nickname?userInfo.nickname:userInfo.username;
        self.shareContent=[NSString stringWithFormat:@"%@邀请您加入踢球吧，与他并肩战斗。踢球吧，记录你的比赛！下载地址:%@",name,self.shareUrl];

    }
    else
    {
        
        
    }
    
    
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private method
- (void)pushToUserInfoViewControllerWithUserInfo:(UserInfo *)aUserInfo
{
    BOOL isFriend = NO;
    for (UserInfo *user in self.friends)
    {
        if([user.username isEqualToString:aUserInfo.username])
        {
            isFriend = YES;
            break ;
        }
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Info" bundle:[NSBundle mainBundle]];
    UserInfoViewController *userInfo = [storyboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    [userInfo setValue:aUserInfo forKey:@"userInfo"];
    [userInfo setValue:[NSNumber numberWithInteger:self.viewType] forKey:@"viewType"];
    [userInfo setValue:[NSNumber numberWithBool:isFriend] forKey:@"isFriend"];
    if (self.teamInfo) {
         [userInfo setValue:@[self.teamInfo] forKey:@"ownTeams"];
    }
    [self.navigationController pushViewController:userInfo animated:YES];
}

- (void)showSendMessageUIWithRecipient:(NSString *)recipient
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    BDLog(@"can send SMS [%d]", [messageClass canSendText]);
    
    if (messageClass != nil)
    {
        if ([messageClass canSendText])
        {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            
            //发送球队的邀请码
            //            picker.body = @"邀请好友！";
            picker.body = self.shareContent;//self.teamInfo.objectId;
            picker.recipients = nil;
//            picker.recipients = [NSArray arrayWithObject:recipient];
            [self presentViewController:picker animated:YES completion:nil];
        } else {
            [self showMessage:@"设备没有短信功能"];
        }
    } else {
        [self showMessage:@"iOS版本过低，iOS4.0以上才支持程序内发送短信"];
    }
    
}


#pragma mark - Navigation
//
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"push_friends"])
    {
        [segue.destinationViewController setValue:self.teamInfo forKey:@"teamInfo"];
        [segue.destinationViewController setValue:self.friends forKey:@"friends"];
    }else if ([segue.identifier isEqualToString:@"push_result"])
    {
        [segue.destinationViewController setValue:@(self.viewType) forKey:@"viewType"];
        if (self.teamInfo) {
            [segue.destinationViewController setValue:self.teamInfo forKey:@"teamInfo"];
        }
        [segue.destinationViewController setValue:self.friends forKey:@"friends"];
        [segue.destinationViewController setValue:sender forKey:@"result"];
        
    }
}

#pragma mark  - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UIImageView *imageView = (id)[cell.contentView viewWithTag:0xF0];
    NSInteger type = [self.dataSource[indexPath.row] integerValue];
    imageView.image = [UIImage imageNamed:gSearchTypeIconArray[type]];
    UILabel *label = (id)[cell.contentView viewWithTag:0xF1];
    label.text = gSearchTypeTitleArray[type];
    
    UIView *line = [cell.contentView viewWithTag:0xF2];
    if (indexPath.row == [self.dataSource count] - 1) {
        line.frame = CGRectMake(0, 41, 320, 1);
    }else
    {
        line.frame = CGRectMake(60, 41, 260, 1);
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch ([self.dataSource[indexPath.row] integerValue]) {
        case SearchTypeFriends:
            [self performSegueWithIdentifier:@"push_friends" sender:nil];
            break;
        case SearchTypeQQ:
            [self onQQ:nil];
            break;
        case SearchTypeMPhone:
            [self onPhone:nil];
            break;
        case SearchTypeWeixin:
            [self onWechat:nil];
            break;
            
        default:
            break;
    }
}

#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onSearch:nil];
    return YES;
}

#pragma mark - Event handler

- (IBAction)onSearch:(id)sender {
    [self.searchTextField resignFirstResponder];
    if ([self.searchTextField.text length] <= 0) {
        [self showMessage:@"请输入搜索关键字"];
        return ;
    }
    [InfoEngine searchUserWithKey:self.searchTextField.text block:^(id result, NSError *error) {
        if(!error)
        {
            if ([(NSArray*)result count] > 0) {
                [self performSegueWithIdentifier:@"push_result" sender:result];
                
            }else
            {
                [self showMessage:@"暂无搜索结果"];
            }
            
        }else
        {
            [self showMessage:[Util errorStringWithCode:error.code]];
        }
    }];
}


- (IBAction)onPhone:(id)sender
{
//    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
//    peoplePicker.peoplePickerDelegate = self;
//    [self presentViewController:peoplePicker animated:YES completion:nil];
    
    [self showSendMessageUIWithRecipient:nil];
    
}
- (IBAction)onWechat:(id)sender
{
    //发送球队邀请码
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
                      type:ShareTypeWeixiSession
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            BDLog(@"success");
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"知道了"
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
}

- (IBAction)onQQ:(id)sender
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"demo.jpg"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:data];
    id<ISSContent> content = [ShareSDK content:self.shareContent
                                defaultContent:nil
                                         image:[ShareSDK jpegImageWithImage:image quality:0.8]
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
                      type:ShareTypeQQ
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            BDLog(@"success");
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            BDLog(@"fail");
                        }
                    }];
    
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self dismissViewControllerAnimated:YES completion:^{
        ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
        __block NSInteger count = ABMultiValueGetCount(phoneMulti);
        for (int i = 0; i < ABMultiValueGetCount(phoneMulti); i++) {
            
            NSString *aPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneMulti, i);
            __block BOOL isHasPhone = NO;
            __block BOOL hasPush = NO;
            if ([Util isValidOfPhoneNumber:aPhone])
            {
                isHasPhone = YES;
                [self showLoadingView];
                [InfoEngine getInfoWithUsername:aPhone block:^(id result, NSError *error)
                 {
                     count --;
                     [self hideLoadingView];
                     if (!error)
                     {
                         if (result && !hasPush)
                         {
                             if (!hasPush)
                             {
                                 hasPush = YES;
                                 [self pushToUserInfoViewControllerWithUserInfo:result];
                             }
                         }else
                         {
                             
                         }
                     }
                     
                     if (count <= 0)
                     {
                         if (!isHasPhone) {
                             [self showMessage:@"未获取有效手机号码！"];
                         }
                         if (!hasPush) {
                             [self showSendMessageUIWithRecipient:aPhone];
                         }
                     }
                     
                 }];
            }else
            {
                count --;
            }
            
        }
       
    }];
    return NO;
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}


#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    switch (result)
    {
        case MessageComposeResultCancelled:
            [self showMessage:@"已取消短信"];
            break;
        case MessageComposeResultSent:
            [self showMessage:@"短信已经发送！"];
            break;
        case MessageComposeResultFailed:
            [self showMessage:@"短信发送失败！"];
            break;
        default:
            [self showMessage:@"短信发送失败！"];
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end

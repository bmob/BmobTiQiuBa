//
//  FriendsSearchViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-28.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "FriendsSearchViewController.h"
#import "InfoEngine.h"
#import "UserInfoViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Util.h"


#import <TencentOpenAPI/QQApi.h>
#import <AGCommon/UINavigationBar+Common.h>
#import <AGCommon/UIImage+Common.h>
#import <AGCommon/UIDevice+Common.h>
#import <ShareSDK/ShareSDK.h>
#import <AGCommon/NSString+Common.h>

#define SHARE_TITLE @"踢球吧"
#define SHARE_CONTENT @"下载地址：http://tq.codenow.cn/share/Download"
#define SHARE_URL @"http://tq.codenow.cn/share/Download"



@interface FriendsSearchViewController () <ABPeoplePickerNavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic ,strong) NSArray *friends;

@end

@implementation FriendsSearchViewController

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
    self.title = @"添加好友";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushToUserInfoViewControllerWithUserInfo:(UserInfo *)aUserInfo
{
    BOOL isFriend = NO;
    for (UserInfo *user in self.friends)
    {
        if([user.username isEqualToString:aUserInfo.username])
        {
            isFriend = YES;
        }
    }
    UserInfoViewController *userInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    [userInfo setValue:aUserInfo forKey:@"userInfo"];
    [userInfo setValue:[NSNumber numberWithBool:YES] forKey:@"isForOthers"];
    [userInfo setValue:[NSNumber numberWithBool:isFriend] forKey:@"isFriend"];
    [self.navigationController pushViewController:userInfo animated:YES];
}

- (void)showSendMessageUIWithRecipient:(NSString *)recipient
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    NSLog(@"can send SMS [%d]", [messageClass canSendText]);
    
    if (messageClass != nil)
    {
        if ([messageClass canSendText])
        {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            picker.body = @"邀请好友！";
            picker.recipients = [NSArray arrayWithObject:recipient];
            [self presentViewController:picker animated:YES completion:nil];
        } else {
            [self showMessage:@"设备没有短信功能"];
        }
    } else {
        [self showMessage:@"iOS版本过低，iOS4.0以上才支持程序内发送短信"];
    }

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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onSearch:nil];
    return YES;
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
            __block BOOL hasPush = NO;
            if ([Util isValidOfPhoneNumber:aPhone])
            {
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
#pragma mark - Event handler

- (IBAction)onSearch:(id)sender
{
    [self.searchTextField resignFirstResponder];
    if (self.searchTextField.text && ![self.searchTextField.text isEqualToString:@""])
    {
        [self showLoadingView];
        [InfoEngine getInfoWithUsername:self.searchTextField.text block:^(id result, NSError *error)
        {
            [self hideLoadingView];
            if (error)
            {
                [self showMessage:error.localizedDescription];
            }else
            {
                if (result)
                {
                    [self pushToUserInfoViewControllerWithUserInfo:result];
                }else
                {
                    [self showMessage:@"该用户不存在！"];
                }
            }
        }];
        
    }else
    {
        [self showMessage:@"请输入搜索内容！"];
    }
}
- (IBAction)onPhone:(id)sender
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self presentViewController:peoplePicker animated:YES completion:nil];
    
}

- (IBAction)onWechat:(id)sender
{
    id<ISSContent> content = [ShareSDK content:SHARE_CONTENT
                                defaultContent:nil
                                         image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@"res2.jpg"] quality:1]
                                         title:SHARE_TITLE
                                           url:SHARE_URL
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
                            NSLog(@"success");
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
    
    id<ISSContent> content = [ShareSDK content:SHARE_CONTENT
                                defaultContent:nil
                                         image:[ShareSDK jpegImageWithImage:image quality:0.8]
                                         title:SHARE_TITLE
                                           url:SHARE_URL
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
                            NSLog(@"success");
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            NSLog(@"fail");
                        }
                    }];
}



@end

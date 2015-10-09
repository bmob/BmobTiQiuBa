//
//  LoginViewController.m
//  SportsContact
//
//  Created by bobo on 14-7-9.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginEngine.h"
#import "ViewUtil.h"
#import "NoticeManager.h"
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobQuery.h>

#import "MainNavigationController.h"


#import <ShareSDK/ShareSDK.h>


//#import "WXApi.h"
//#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>


@interface LoginViewController ()

@end

@implementation LoginViewController

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
//    [LoginEngine loginWithUsername:@"ssss9" password:@"123456" block:^(id result, NSError *error)
//    {
//        if (error)
//        {
//            BDLog(@"Error :%@", [Util errorStringWithCode:error.code]);
//        }else
//        {
//            UserInfo *user = result;
//            BDLog(@"Login username :%@", user.username);
//        }
//    }];
    // Do any additional setup after loading the view.
    


//    self.loginButton.backgroundColor=[ViewUtil hexStringToColor:@"f47900"];
//    self.qqLoginButton.backgroundColor=[ViewUtil hexStringToColor:@"555c64"];
    

    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES];
    
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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









- (IBAction)onSelectedLoginQQ:(id)sender
{
    
    
    [ShareSDK authWithType:ShareTypeQQSpace  options:nil result:^(SSAuthState state, id<ICMErrorInfo> error)
     {
        
        if (state == SSAuthStateSuccess)
        {
            
            id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:ShareTypeQQSpace];
            
            NSDictionary *responseDictionary = @{@"access_token":[credential token],@"uid":[credential uid],@"expirationDate":[credential expired]};
                                       
            //通过授权信息注册登录
            [self showLoadingView];
            [BmobUser loginInBackgroundWithAuthorDictionary:responseDictionary
                                                           platform:BmobSNSPlatformQQ
                                                              block:^(BmobUser *user, NSError *error)
            {
                                                                                     
                [self hideLoadingView];
                
                
                
                
                [(MainNavigationController *)self.navigationController pushContentViewControllerAnimated:YES];
                
                if ([BmobUser getCurrentUser])
                {
                    [NoticeManager updatePushProfile];
                    [[NoticeManager sharedManager] bindDB];
                    
                    [self showMessage:@"登陆成功！"];
                    
                    
                    
                }
                
                
                
                
                
            }];


            
            
            
            
            
            //授权成功之后，第一次，要提取QQ信息，注册Bmobuser
            //                [ShareSDK getUserInfoWithType:ShareTypeQQ
            //                                  authOptions:nil
            //                                       result:^(BOOL result1, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error)
            //                 {
            //
            //                     BDLog(@"************%@",[userInfo nickname]);
            //
            //                     if (result1)
            //                     {
            //
            //                         //提取QQ的信息，注册用户
            //
            //                         [LoginEngine getUserinfoWithPhoenumber:[userInfo nickname] block:^(id result, NSError *error) {
            //
            //                             NSMutableArray *array=[[NSMutableArray alloc]init];
            //                             array=result;
            //
            //                             if ([array count]==0)
            //                             {
            //
            //                                 //提交用户注册信息
            //
            //
            //
            //
            //                                 [self showMessage:@"欢迎注册"];
            //
            //                             }
            //                             else
            //                             {
            //
            //
            //                                 [self showMessage:@"欢迎回来"];
            //
            //                             }
            //
            //
            //                             
            //                         }];
            //                         
            //                         
            //                     }
            //                     else
            //                     {
            //                         
            //                     }
            //                     
            //                     
            //                     
            //                     
            //                     
            //                 }];

            
            
            
            
        }
        else if (state == SSAuthStateFail)
        {
            
//            BDLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);

            [self showMessage:@"登陆失败！"];
        }
        else
        {
            
        }
         
         
         
        
        
    }];

    
    
    
    
    
//    [ShareSDK getUserInfoWithType:ShareTypeQQSpace
//                      authOptions:nil
//                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
//                               
//                               BDLog(@"*********%@",[error errorDescription]);
//                               
//                               if (result)
//                               {
////                                   PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
////                                   [query whereKey:@"uid" equalTo:[userInfo uid]];
////                                   [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
////                                       
////                                       if ([objects count] == 0)
////                                       {
////                                           PFObject *newUser = [PFObject objectWithClassName:@"UserInfo"];
////                                           [newUser setObject:[userInfo uid] forKey:@"uid"];
////                                           [newUser setObject:[userInfo nickname] forKey:@"name"];
////                                           [newUser setObject:[userInfo profileImage] forKey:@"icon"];
////                                           [newUser saveInBackground];
////                                           
////                                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"欢迎注册" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
////                                           [alertView show];
////                                           [alertView release];
////                                       }
////                                       else
////                                       {
////                                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"欢迎回来" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
////                                           [alertView show];
////                                           [alertView release];
////                                       }
////                                   }];
////                                   
////                                   MainViewController *mainVC = [[[MainViewController alloc] init] autorelease];
////                                   [self.navigationController pushViewController:mainVC animated:YES];
//                                   
//                               }
//                               
//                           }];

    
    
}





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
	if ([segue.identifier isEqualToString:@"LoginDetail"])
	{
        
	}
    
    
}















@end
